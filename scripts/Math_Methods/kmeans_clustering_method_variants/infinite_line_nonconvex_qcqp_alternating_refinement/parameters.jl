struct ClusteringParameters
    cluster_count::Int
    restart_count::Int
    maximum_iterations::Int
    minimum_cluster_size::Int
    random_seed::Int
    data_file::String
    coordinate_offset::Vector{Float64}
    anchor_padding::Float64
    fixed_parameter_lower::Float64
    fixed_parameter_upper::Float64
    parameter_lower_bound::Float64
    endpoint_lower_limit::Float64
    endpoint_upper_limit::Float64
    minimum_segment_length::Float64
end

const PARAMETERS = ClusteringParameters(
    6,
    10,
    130,
    2,
    20260913,
    joinpath(@__DIR__, "data", "input_points.csv"),
    [0.0, 40.0, 0.0],
    10.0,
    -300.0,
    0.0,
    -300.0,
    -300.0,
    300.0,
    1.55,
)
