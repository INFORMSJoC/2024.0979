
struct ProblemData
    points::Matrix{Float64}
end

function load_problem_data(parameters::ClusteringParameters)
    raw_points = readdlm(parameters.data_file, ',', Float64)
    points = Matrix{Float64}(raw_points)
    size(points, 2) == 3 || error("Expected three coordinate columns in $(parameters.data_file).")
    points .+= reshape(parameters.coordinate_offset, 1, :)
    size(points, 1) >= parameters.cluster_count * parameters.minimum_cluster_size ||
        error("The data set is too small for the configured minimum cluster size.")
    return ProblemData(points)
end
