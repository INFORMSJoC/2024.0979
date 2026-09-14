# Finite-Segment Nonconvex QCQP: Two-Sided Bounds

**Formulation:** A finite segment whose lower and upper endpoints are both
decision variables within the configured limits.

Run from this folder:

```sh
julia run_clustering.jl
```

This project implements Algorithm 1: random valid initialization, alternating constrained line-fitting and binary reassignment, and selection of the best result across restarts. Line fitting is a nonconvex QCQP (`NonConvex = 2`); it is not a convex or SOCP formulation.

**Line domain:** Both line endpoints are decision variables within the configured two-sided limits.

For another case, replace `data/input_points.csv` and update the needed fields in
`PARAMETERS` in `parameters.jl`: `cluster_count`, `restart_count`,
`maximum_iterations`, `minimum_cluster_size`, `random_seed`, `data_file`,
`coordinate_offset`, `anchor_padding`, `endpoint_lower_limit`, and
`endpoint_upper_limit`. Keep this version when both segment limits should be
determined during fitting.

Inputs are in `data/`; results are written to `output/`.

Before the first run, install the required Julia packages globally:

```julia
using Pkg
Pkg.add(["JuMP", "Gurobi"])
```

Then run `julia run_clustering.jl` from this model folder.
