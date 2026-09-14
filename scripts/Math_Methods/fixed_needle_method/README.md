# Fixed Needle Method

## Run

1. Install Julia and a valid Gurobi license.
2. From this directory, run:

   ```bash
   julia fixed_needle_method.jl
   ```

The code writes `output/dwell_times.csv` and `output/selected_needle_indices.csv`.

## Replace parameters for a new case

Edit `fixed_needle_parameters.jl` to set the desired:

- number of candidate needles;
- tumor and organ voxel ranges;
- prescribed lower and upper dose bounds;
- underdose and overdose penalty weights;
- maximum dwell time;
- maximum number of selected needles; and
- solver time limit.

## Replace input files for a new case

Put the replacement files in `data/`, retaining these names:

| File | Required contents |
|---|---|
| `dose_matrix.csv` | Numeric dose-rate matrix. Rows are voxels and columns are dwell positions. |
| `dwell_to_needle.csv` | One integer needle ID per row. Its row count must equal the number of columns in `dose_matrix.csv`; every ID must be between `1` and `NEEDLE_COUNT`. |
| `incompatible_needles.csv` | Comma-separated `NEEDLE_COUNT` × `NEEDLE_COUNT` square matrix. Entry `(i, j)` must be `1` when needles `i` and `j` cannot both be selected, otherwise `0`. |

After replacing data, update the voxel range constants and `NEEDLE_COUNT` so they match the new files. The model uses a physical needle binary variable for each needle ID and maps each dwell position to that variable through `dwell_to_needle.csv`.

Before the first run, install the required Julia packages globally:

```julia
using Pkg
Pkg.add(["CSV", "DataFrames", "JuMP", "Gurobi"])
```

Then run the model command shown above from its model folder.
