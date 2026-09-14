include(joinpath(@__DIR__, "..", "package_loading.jl"))

include(joinpath(@__DIR__, "parameters.jl"))
include(joinpath(@__DIR__, "problem_data.jl"))
include(joinpath(@__DIR__, "line_fitter.jl"))

function random_valid_assignments(point_count::Int, parameters::ClusteringParameters, rng::AbstractRNG)
    assignments = zeros(Int, point_count)
    permutation = randperm(rng, point_count)
    required = parameters.cluster_count * parameters.minimum_cluster_size
    for cluster in 1:parameters.cluster_count
        first_index = (cluster - 1) * parameters.minimum_cluster_size + 1
        last_index = cluster * parameters.minimum_cluster_size
        assignments[permutation[first_index:last_index]] .= cluster
    end
    for index in permutation[(required + 1):end]
        assignments[index] = rand(rng, 1:parameters.cluster_count)
    end
    return assignments
end

function fit_all_lines(points::Matrix{Float64}, assignments::Vector{Int}, parameters::ClusteringParameters, formulation::Symbol)
    lines = Vector{FittedLine}(undef, parameters.cluster_count)
    for cluster in 1:parameters.cluster_count
        cluster_points = points[assignments .== cluster, :]
        lines[cluster] = fit_constrained_line(cluster_points, parameters, formulation)
    end
    return lines
end

function reassign_points(points::Matrix{Float64}, lines::Vector{FittedLine}, parameters::ClusteringParameters)
    point_count = size(points, 1)
    costs = [squared_distance(view(points, index, :), lines[cluster]) for index in 1:point_count, cluster in 1:parameters.cluster_count]
    model = direct_model(Gurobi.Optimizer())
    set_attribute(model, "OutputFlag", 0)
    @variable(model, assignment[1:point_count, 1:parameters.cluster_count], Bin)
    @constraint(model, [index = 1:point_count], sum(assignment[index, cluster] for cluster in 1:parameters.cluster_count) == 1)
    @constraint(model, [cluster = 1:parameters.cluster_count], sum(assignment[index, cluster] for index in 1:point_count) >= parameters.minimum_cluster_size)
    @objective(model, Min, sum(costs[index, cluster] * assignment[index, cluster] for index in 1:point_count, cluster in 1:parameters.cluster_count))
    optimize!(model)
    has_values(model) || error("Binary reassignment did not produce a feasible solution: $(termination_status(model)).")
    return [argmax(value.(assignment[index, :])) for index in 1:point_count]
end

function objective_value(points::Matrix{Float64}, assignments::Vector{Int}, lines::Vector{FittedLine})
    return sum(squared_distance(view(points, index, :), lines[assignments[index]]) for index in axes(points, 1))
end

function run_algorithm(parameters::ClusteringParameters, formulation::Symbol)
    data = load_problem_data(parameters)
    rng = MersenneTwister(parameters.random_seed)
    best_objective = Inf
    best_assignments = Int[]
    best_lines = FittedLine[]
    for restart in 1:parameters.restart_count
        assignments = random_valid_assignments(size(data.points, 1), parameters, rng)
        for iteration in 1:parameters.maximum_iterations
            lines = fit_all_lines(data.points, assignments, parameters, formulation)
            reassigned = reassign_points(data.points, lines, parameters)
            reassigned == assignments && break
            assignments = reassigned
        end
        lines = fit_all_lines(data.points, assignments, parameters, formulation)
        current_objective = objective_value(data.points, assignments, lines)
        if current_objective < best_objective
            best_objective = current_objective
            best_assignments = assignments
            best_lines = lines
        end
    end
    return best_objective, best_assignments, best_lines
end

function write_results(output_directory::String, objective::Float64, assignments::Vector{Int}, lines::Vector{FittedLine})
    mkpath(output_directory)
    writedlm(joinpath(output_directory, "best_objective.csv"), [objective])
    writedlm(joinpath(output_directory, "best_assignments.csv"), assignments)
    writedlm(joinpath(output_directory, "line_anchors.csv"), reduce(vcat, permutedims.(getfield.(lines, :anchor))))
    writedlm(joinpath(output_directory, "line_directions.csv"), reduce(vcat, permutedims.(getfield.(lines, :direction))))
    writedlm(joinpath(output_directory, "line_parameter_bounds.csv"), [[line.parameter_lower line.parameter_upper] for line in lines] |> x -> reduce(vcat, x))
end

function main()
    objective, assignments, lines = run_algorithm(PARAMETERS, FORMULATION)
    write_results(joinpath(@__DIR__, "output"), objective, assignments, lines)
    println("Best objective: $objective")
end

const FORMULATION = :variable

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
