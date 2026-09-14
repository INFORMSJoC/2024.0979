# Infinite-Line Nonconvex QCQP: Quadratic-Cone Refinement

**Formulation:** An infinite-line fit using the quadratic-cone refinement
pattern from the second Python optimization implementation. The cone-like
quadratic constraints do not make the full formulation convex.

Run from this folder:

```sh
julia run_clustering.jl
```

This project implements Algorithm 1: random valid initialization, alternating constrained line-fitting and binary reassignment, and selection of the best result across restarts. Line fitting is a nonconvex QCQP (`NonConvex = 2`); it is not a convex or SOCP formulation.

**Line domain:** The line parameter is unrestricted.

For another case, replace `data/input_points.csv` and update the needed fields in
`PARAMETERS` in `parameters.jl`: `cluster_count`, `restart_count`,
`maximum_iterations`, `minimum_cluster_size`, `random_seed`, `data_file`,
`coordinate_offset`, and `anchor_padding`. Keep this version when the fitted
line must be unrestricted.

Inputs are in `data/`; results are written to `output/`.

Before the first run, install the required Julia packages globally:

```julia
using Pkg
Pkg.add(["JuMP", "Gurobi"])
```

Then run `julia run_clustering.jl` from this model folder.
