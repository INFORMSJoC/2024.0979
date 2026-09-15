# Free Needle Phase 1

## Run

Install Julia and a valid Gurobi license, then run:

```bash
julia free_needle_phase_1.jl
```

## Input and parameters

The only active input is `data/dose_matrix.csv`, whose rows are voxels and whose columns are dwell positions. Replace it for a new case, then edit `free_needle_phase_1_parameters.jl` to set voxel ranges, dose bounds, penalty weights, `MAX_DWELL_TIME`, and `MAX_CANDIDATE_DWELL_POSITIONS` (`I_max`).


Results are written to `output/dwell_times.csv` and `output/candidate_dwell_positions.csv`. The latter contains the `I_max` largest dwell times, as required for the candidate dwell-position set in the subsequent phase.

Before the first run, install the required Julia packages globally:

```julia
using Pkg
Pkg.add(["CSV", "DataFrames", "JuMP", "Gurobi"])
```

Then run the model command shown above from its model folder.
