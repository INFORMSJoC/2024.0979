const DATA_DIRECTORY = joinpath(@__DIR__, "data")
const OUTPUT_DIRECTORY = joinpath(@__DIR__, "output")
const COVERAGE_WEIGHT_FILE = joinpath(DATA_DIRECTORY, "candidate_needle_coverage_weights.csv")
const INTERSECTION_MATRIX_FILE = joinpath(DATA_DIRECTORY, "candidate_needle_intersections.csv")
const COVERAGE_MATRIX_FILE = joinpath(DATA_DIRECTORY, "candidate_needle_coverage.csv")

const MAX_SELECTED_NEEDLES = 6
