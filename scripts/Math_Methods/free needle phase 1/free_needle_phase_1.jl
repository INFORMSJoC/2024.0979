include(joinpath(@__DIR__, "..", "package_loading.jl"))

include("free_needle_phase_1_parameters.jl")

dose_rate = Matrix(CSV.read(DOSE_RATE_FILE, DataFrame; header = false))
available_voxel_count, dwell_position_count = size(dose_rate)
available_voxel_count >= MODELED_VOXEL_COUNT ||
    error("The dose matrix has fewer than $MODELED_VOXEL_COUNT modeled voxels.")

lower_dose = zeros(MODELED_VOXEL_COUNT)
upper_dose = zeros(MODELED_VOXEL_COUNT)
underdose_penalty = zeros(MODELED_VOXEL_COUNT)
overdose_penalty = zeros(MODELED_VOXEL_COUNT)

for voxel in TUMOR_VOXEL_START:TUMOR_VOXEL_END
    lower_dose[voxel] = TUMOR_LOWER_DOSE
    upper_dose[voxel] = TUMOR_UPPER_DOSE
    underdose_penalty[voxel] = TUMOR_UNDERDOSE_PENALTY
    overdose_penalty[voxel] = TUMOR_OVERDOSE_PENALTY
end

for voxel in ORGAN_VOXEL_START:MODELED_VOXEL_COUNT
    upper_dose[voxel] = ORGAN_UPPER_DOSE
    overdose_penalty[voxel] = ORGAN_OVERDOSE_PENALTY
end

model = Model(Gurobi.Optimizer)
set_attribute(model, "OutputFlag", 1)

@variable(model, 0 <= dwell_time[1:dwell_position_count] <= MAX_DWELL_TIME)
@variable(model, delivered_dose[1:MODELED_VOXEL_COUNT] >= 0)

# These epigraph variables represent the original piecewise-linear penalty functions.
@variable(model, underdose[1:MODELED_VOXEL_COUNT] >= 0)
@variable(model, overdose[1:MODELED_VOXEL_COUNT] >= 0)

# (6): dose delivered to each modeled voxel.
@constraint(
    model,
    dose_definition[voxel in 1:MODELED_VOXEL_COUNT],
    delivered_dose[voxel] ==
    sum(dose_rate[voxel, dwell_position] * dwell_time[dwell_position]
        for dwell_position in 1:dwell_position_count),
)
@constraint(
    model,
    underdose_definition[voxel in 1:MODELED_VOXEL_COUNT],
    underdose[voxel] >= lower_dose[voxel] - delivered_dose[voxel],
)
@constraint(
    model,
    overdose_definition[voxel in 1:MODELED_VOXEL_COUNT],
    overdose[voxel] >= delivered_dose[voxel] - upper_dose[voxel],
)

@objective(
    model,
    Min,
    sum(
        underdose_penalty[voxel] * underdose[voxel] +
        overdose_penalty[voxel] * overdose[voxel]
        for voxel in 1:MODELED_VOXEL_COUNT
    ),
)

optimize!(model)
has_values(model) ||
    error("The solver returned no feasible solution: $(termination_status(model))")

dwell_times = value.(dwell_time)
ranked_dwell_positions = sortperm(dwell_times; rev = true)
candidate_count = min(MAX_CANDIDATE_DWELL_POSITIONS, dwell_position_count)
candidate_dwell_positions = ranked_dwell_positions[1:candidate_count]

mkpath(OUTPUT_DIRECTORY)
CSV.write(
    joinpath(OUTPUT_DIRECTORY, "dwell_times.csv"),
    DataFrame(dwell_position = 1:dwell_position_count, dwell_time = dwell_times),
)
CSV.write(
    joinpath(OUTPUT_DIRECTORY, "candidate_dwell_positions.csv"),
    DataFrame(
        rank = 1:candidate_count,
        dwell_position = candidate_dwell_positions,
        dwell_time = dwell_times[candidate_dwell_positions],
    ),
)
