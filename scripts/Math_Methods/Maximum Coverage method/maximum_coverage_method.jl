include(joinpath(@__DIR__, "..", "package_loading.jl"))

include("maximum_coverage_parameters.jl")

coverage_weight = vec(
    Matrix(CSV.read(COVERAGE_WEIGHT_FILE, DataFrame; header = false)),
)
intersection_matrix = Matrix(
    CSV.read(INTERSECTION_MATRIX_FILE, DataFrame; header = false),
)
coverage_matrix = Matrix(CSV.read(COVERAGE_MATRIX_FILE, DataFrame; header = false))

candidate_needle_count = length(coverage_weight)
size(intersection_matrix) == (candidate_needle_count, candidate_needle_count) ||
    error("The intersection matrix must be square with one row and column per candidate needle.")
all(value -> value == 0 || value == 1, intersection_matrix) ||
    error("The intersection matrix must contain only 0 and 1 values.")
size(coverage_matrix, 1) == candidate_needle_count ||
    error("The coverage matrix must have one row per candidate needle.")
all(value -> value == 0 || value == 1, coverage_matrix) ||
    error("The coverage matrix must contain only 0 and 1 values.")

candidate_dwell_position_count = size(coverage_matrix, 2)

model = Model(Gurobi.Optimizer)
set_attribute(model, "OutputFlag", 1)

@variable(model, needle_selected[1:candidate_needle_count], Bin)

# maximize the cumulative dwell time covered by selected candidate needles.
@objective(
    model,
    Max,
    sum(coverage_weight[needle] * needle_selected[needle]
        for needle in 1:candidate_needle_count),
)

# each candidate dwell position is covered by at most one selected needle.
@constraint(
    model,
    dwell_position_coverage[dwell_position in 1:candidate_dwell_position_count],
    sum(
        coverage_matrix[needle, dwell_position] * needle_selected[needle]
        for needle in 1:candidate_needle_count
    ) <= 1,
)

# intersecting candidate needles cannot both be selected.
@constraint(
    model,
    nonintersecting_needles[
        first_needle in 1:(candidate_needle_count - 1),
        second_needle in (first_needle + 1):candidate_needle_count;
        intersection_matrix[first_needle, second_needle] == 1
    ],
    needle_selected[first_needle] + needle_selected[second_needle] <= 1,
)

# select no more than N_max candidate needles.
@constraint(
    model,
    needle_limit,
    sum(needle_selected[needle] for needle in 1:candidate_needle_count) <=
    MAX_SELECTED_NEEDLES,
)

optimize!(model)
has_values(model) ||
    error("The solver returned no feasible solution: $(termination_status(model))")

selected_needles = [
    needle for needle in 1:candidate_needle_count
    if value(needle_selected[needle]) >= 0.5
]

mkpath(OUTPUT_DIRECTORY)
CSV.write(
    joinpath(OUTPUT_DIRECTORY, "selected_needle_indices.csv"),
    DataFrame(
        candidate_needle = selected_needles,
        coverage_weight = coverage_weight[selected_needles],
    ),
)
