include(joinpath(@__DIR__, "..", "package_loading.jl"))

include("fixed_needle_parameters.jl")

dose_rate = DataFrame(CSV.File(DOSE_RATE_FILE, header = false))
incompatible_needles = DataFrame(
    CSV.File(INCOMPATIBILITY_MATRIX_FILE, header = false),
)
dwell_to_needle = DataFrame(
    CSV.File(DWELL_TO_NEEDLE_FILE, header = false),
)

needle_count = NEEDLE_COUNT
dwell_position_count = size(dose_rate, 2)
voxel_count = size(dose_rate, 1)

upper_dose = zeros(voxel_count)
lower_dose = zeros(voxel_count)
underdose_penalty = zeros(voxel_count)
overdose_penalty = zeros(voxel_count)

for voxel in TUMOR_VOXEL_START:TUMOR_VOXEL_END
    upper_dose[voxel] = TUMOR_UPPER_DOSE
    lower_dose[voxel] = TUMOR_LOWER_DOSE
    underdose_penalty[voxel] = TUMOR_UNDERDOSE_PENALTY
    overdose_penalty[voxel] = TUMOR_OVERDOSE_PENALTY
end

for voxel in ORGAN_VOXEL_START:ORGAN_VOXEL_END
    upper_dose[voxel] = ORGAN_UPPER_DOSE
    overdose_penalty[voxel] = ORGAN_OVERDOSE_PENALTY
end

model = Model(Gurobi.Optimizer)
set_optimizer_attribute(model, "OutputFlag", 1)
set_optimizer_attribute(model, "TimeLimit", SOLVER_TIME_LIMIT_SECONDS)

needle_selected = Dict()
dwell_time = Dict()
delivered_dose = Dict()
underdose = Dict()
overdose = Dict()

for needle in 1:needle_count
    needle_selected[needle] = @variable(model, binary = true)
    set_name(needle_selected[needle], "needle_selected[$needle]")
end

for dwell_position in 1:dwell_position_count
    dwell_time[dwell_position] = @variable(model, lower_bound = 0)
    set_name(dwell_time[dwell_position], "dwell_time[$dwell_position]")
end

for voxel in 1:voxel_count
    delivered_dose[voxel] = @variable(model, lower_bound = 0)
    set_name(delivered_dose[voxel], "delivered_dose[$voxel]")

    underdose[voxel] = @variable(model, lower_bound = 0)
    set_name(underdose[voxel], "underdose[$voxel]")

    overdose[voxel] = @variable(model, lower_bound = 0)
    set_name(overdose[voxel], "overdose[$voxel]")
end

for voxel in 1:voxel_count
    # (5b): dose delivered to each voxel.
    @constraint(
        model,
        sum(
            dose_rate[voxel, dwell_position] * dwell_time[dwell_position]
            for dwell_position in 1:dwell_position_count
        ) == delivered_dose[voxel],
    )
    @constraint(
        model,
        delivered_dose[voxel] >= lower_dose[voxel] - underdose[voxel],
    )
    @constraint(
        model,
        delivered_dose[voxel] <= upper_dose[voxel] + overdose[voxel],
    )
end

for first_needle in 1:needle_count
    for second_needle in 1:needle_count
        if first_needle != second_needle &&
            incompatible_needles[first_needle, second_needle] == 1
            # (5e): incompatible needles cannot both be selected.
            @constraint(
                model,
                needle_selected[first_needle] + needle_selected[second_needle] <= 1,
            )
        end
    end
end

for dwell_position in 1:dwell_position_count
    # (5c): a dwell time is positive only when its needle is selected.
    @constraint(
        model,
        dwell_time[dwell_position] <=
        MAX_DWELL_TIME * needle_selected[dwell_to_needle[dwell_position, 1]],
    )
end

# (5d): use no more than six needles.
@constraint(
    model,
    sum(needle_selected[needle] for needle in 1:needle_count) <= MAX_SELECTED_NEEDLES,
)

@objective(
    model,
    Min,
    sum(
        underdose_penalty[voxel] * underdose[voxel] +
        overdose_penalty[voxel] * overdose[voxel]
        for voxel in 1:voxel_count
    ),
)

optimize!(model)
has_values(model) ||
    error("The solver returned no feasible solution: $(termination_status(model))")

mkpath(OUTPUT_DIRECTORY)
writedlm(
    joinpath(OUTPUT_DIRECTORY, "dwell_times.csv"),
    [value(dwell_time[dwell_position]) for dwell_position in 1:dwell_position_count],
    ',',
)
writedlm(
    joinpath(OUTPUT_DIRECTORY, "selected_needle_indices.csv"),
    [needle for needle in 1:needle_count if value(needle_selected[needle]) >= 0.5],
    ',',
)
