
struct FittedLine
    anchor::Vector{Float64}
    direction::Vector{Float64}
    parameter_lower::Float64
    parameter_upper::Float64
end

function line_parameter_bounds(model::Model, parameters::ClusteringParameters, formulation::Symbol, point_count::Int)
    if formulation == :infinite
        return nothing, nothing
    elseif formulation == :fixed
        return parameters.fixed_parameter_lower, parameters.fixed_parameter_upper
    elseif formulation == :lower_bound
        return parameters.parameter_lower_bound, nothing
    elseif formulation == :variable
        @variable(model, parameters.endpoint_lower_limit <= lower_endpoint <= parameters.endpoint_upper_limit)
        @variable(model, parameters.endpoint_lower_limit <= upper_endpoint <= parameters.endpoint_upper_limit)
        @constraint(model, lower_endpoint <= upper_endpoint)
        return lower_endpoint, upper_endpoint
    elseif formulation == :two_sided_bounds
        @variable(model, parameters.endpoint_lower_limit <= lower_endpoint <= parameters.endpoint_upper_limit)
        @variable(model, parameters.endpoint_lower_limit <= upper_endpoint <= parameters.endpoint_upper_limit)
        @constraint(model, lower_endpoint <= upper_endpoint)
        return lower_endpoint, upper_endpoint
    elseif formulation == :two_sided_bounds_with_minimum_length
        @variable(model, parameters.endpoint_lower_limit <= lower_endpoint <= parameters.endpoint_upper_limit)
        @variable(model, parameters.endpoint_lower_limit <= upper_endpoint <= parameters.endpoint_upper_limit)
        @constraint(model, lower_endpoint + parameters.minimum_segment_length <= upper_endpoint)
        return lower_endpoint, upper_endpoint
    end
    error("Unknown formulation: $formulation")
end

function fit_constrained_line(points::Matrix{Float64}, parameters::ClusteringParameters, formulation::Symbol)
    point_count, dimension = size(points)
    dimension == 3 || error("Only three-dimensional point data are supported.")
    model = direct_model(Gurobi.Optimizer())
    set_attribute(model, "OutputFlag", 0)
    set_attribute(model, "NonConvex", 2)
    coordinate_lower = vec(minimum(points, dims = 1)) .- parameters.anchor_padding
    coordinate_upper = vec(maximum(points, dims = 1)) .+ parameters.anchor_padding
    @variable(model, coordinate_lower[coordinate] <= anchor[coordinate = 1:dimension] <= coordinate_upper[coordinate])
    @variable(model, direction[1:dimension])
    @variable(model, point_parameter[1:point_count])
    @variable(model, point_on_line[1:dimension, 1:point_count])
    parameter_lower, parameter_upper = line_parameter_bounds(model, parameters, formulation, point_count)
    if parameter_lower !== nothing
        @constraint(model, [index = 1:point_count], point_parameter[index] >= parameter_lower)
    end
    if parameter_upper !== nothing
        @constraint(model, [index = 1:point_count], point_parameter[index] <= parameter_upper)
    end
    @constraint(model, sum(direction[coordinate]^2 for coordinate in 1:dimension) == 1.0)
    @constraint(model, [coordinate = 1:dimension, index = 1:point_count], point_on_line[coordinate, index] == point_parameter[index] * direction[coordinate])
    @objective(model, Min, sum((points[index, coordinate] - anchor[coordinate] - point_on_line[coordinate, index])^2 for index in 1:point_count, coordinate in 1:dimension))
    optimize!(model)
    has_values(model) || error("Line-fitting QCQP did not produce a feasible solution: $(termination_status(model)).")
    lower_value = parameter_lower === nothing ? -Inf : parameter_lower isa Number ? Float64(parameter_lower) : value(parameter_lower)
    upper_value = parameter_upper === nothing ? Inf : parameter_upper isa Number ? Float64(parameter_upper) : value(parameter_upper)
    return FittedLine(value.(anchor), value.(direction), lower_value, upper_value)
end

function squared_distance(point::AbstractVector{<:Real}, line::FittedLine)
    parameter = dot(point .- line.anchor, line.direction)
    parameter = clamp(parameter, line.parameter_lower, line.parameter_upper)
    residual = point .- (line.anchor .+ parameter .* line.direction)
    return sum(abs2, residual)
end
