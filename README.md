# Optimization Models for Needle Placement in 3D-Printed HDR-BT Masks

This repository contains the research code, anonymized DICOM-RT examples,
optimization-model inputs, and result figures supporting:

> Mirzavand Boroujeni, N., Richard, J.-P. P., Sterling, D., and Wilke, C.
> *Optimization models for needle placement in 3D-printed masks for
> high-dose-rate brachytherapy.*

The research considers placement of straight treatment channels in
patient-specific, 3D-printed surface masks for high-dose-rate brachytherapy
(HDR-BT) of superficial skin cancer. It includes:

- MATLAB scripts for DICOM-RT geometry, contour visualization, voxelization,
  dwell-position generation, and dose-rate calculations;
- Julia/Gurobi models for fixed-needle selection, free-needle phase 1, and
  maximum coverage;
- Julia/Gurobi variants for clustering 3-D points into constrained
  infinite lines or finite line segments; and
- anonymized example data and manuscript result figures for nasal and ear
  cases.

This is research and reproducibility code, **not clinical treatment-planning
software**.

## Repository layout

| Path | Contents |
| --- | --- |
| `data/DICOM_FILES/` | Anonymized DICOM-RT structure sets and needle plans for two nasal cases and one ear case. |
| `data/RAW DATA /` | MATLAB voxel, dwell-point, and source-endpoint inputs. |
| `data/README.md` | DICOM data description, anonymization, governance, and source attribution. |
| `scripts/DICOM_files_reader/` | MATLAB DICOM-RT structure and needle readers. |
| `scripts/Body_organs_redear_codes/` | MATLAB contour, slice, volume, and voxelization helpers. |
| `scripts/Polyhydron_generation/` | MATLAB convex-polyhedron generation from dwell points. |
| `scripts/Dose_calculation_codes/` | MATLAB dwell-position generation and dose calculations. |
| `scripts/Math_Methods/` | Julia optimization models and constrained clustering variants. |
| `results/figures/` | Tracked figures for the nasal and ear cases and clustering variants. |
| `results/tables/` | Tracked dose-metric and solution-time result tables. |
| `AUTHORS` | Project authors and contact information. |
| `LICENSE` | MIT License text. |

The `output/` directories below the Julia method folders are intentionally
ignored by Git. They are created or populated when a model is run.

## Data

### DICOM-RT examples

`data/DICOM_FILES/` contains three anonymized RT structure sets and three
anonymized needle plans:

| Clinical example | RT structure set | RT plan / needle file |
| --- | --- | --- |
| Ear case | `RS_anon_roi_ear_case_body_structure.dcm` | `ear_needles.dcm` |
| Nasal case 1 | `RS_anon_roi_nose_1_case_body_structure.dcm` | `nose1_needles.dcm` |
| Nasal case 2 | `RS_anon_roi_nose_2_case_body_structure.dcm` | `nose_2_needles.dcm` |

Read `data/README.md` before using the DICOM files. It documents the
anonymization process, removal or transformation of identifiers and metadata,
and intended research-only use.

### MATLAB raw inputs

The `data/RAW DATA /` directory contains:

| File | Purpose |
| --- | --- |
| `Selected_dwell_points.xlsx` | Three-dimensional selected dwell locations used by the polyhedron and point-source-dose scripts. |
| `body_voxels.xlsx` | Three-dimensional voxel locations used by the line-source dose script. |
| `start_point_directions_on_needles.csv` | One active-source start point per dwell position. |
| `end_point_directions_on_needles.csv` | One active-source end point per dwell position. |

`dwell_position_creation.m` can generate the start/end source-point CSVs,
middle-point CSV, and needle-number CSV from its embedded needle endpoints.

### Julia optimization inputs

Each Julia model stores its inputs in its own `data/` directory. Do not mix
inputs between models unless the dimensions and parameter files have been
updated accordingly.

| Method | Input files |
| --- | --- |
| Fixed needle | `dose_matrix.csv`, `dwell_to_needle.csv`, `incompatible_needles.csv` |
| Free needle phase 1 | `dose_matrix.csv` |
| Maximum coverage | `candidate_needle_coverage.csv`, `candidate_needle_coverage_weights.csv`, `candidate_needle_intersections.csv` |
| Clustering variants | `input_points.csv`, `constraint_normals.csv`, `constraint_offsets.csv`, `constraint_signs.csv` |

## Software requirements

### MATLAB

Use a current desktop MATLAB release. The DICOM, plotting, numerical, Excel,
and file I/O functions used by the MATLAB scripts require MATLAB and an
installation with DICOM support. The polyhedron script also uses the Symbolic
Math Toolbox.

Install MATLAB from <https://www.mathworks.com/downloads/>, then confirm
available products from the MATLAB Command Window:

```matlab
ver
which dicominfo
which syms
```

The scripts use functions including `dicominfo`, `xlsread`, `xlswrite`,
`csvread`, and `csvwrite`. The latter three are legacy MATLAB APIs and may
produce compatibility warnings in newer releases.

### Julia and Gurobi

The Julia optimization models require:

- Julia;
- Gurobi and a valid Gurobi license;
- the Julia packages `CSV`, `DataFrames`, `DelimitedFiles`, `Gurobi`, `JuMP`,
  `LinearAlgebra`, and `Random`.

Install Julia from <https://julialang.org/downloads/> and Gurobi from
<https://www.gurobi.com/downloads/>. After activating the Gurobi license, run
the following once from a Julia session:

```julia
using Pkg
Pkg.add([
    "CSV",
    "DataFrames",
    "DelimitedFiles",
    "Gurobi",
    "JuMP",
    "LinearAlgebra",
    "Random",
])
```

Confirm that the solver interface loads:

```julia
using JuMP, Gurobi
println("JuMP and Gurobi.jl loaded successfully.")
```

The mathematical-programming scripts will not solve without a valid Gurobi
license.

## MATLAB workflows

The MATLAB scripts were retained in their original research form. Several
contain case-specific filenames or relative paths such as `RAW_DATA/...`.
Before running a script, set its file path to the applicable file under
`data/DICOM_FILES/` or `data/RAW DATA /`, or run it from a working directory
for which its relative paths resolve correctly.

Add the repository scripts to the MATLAB path:

```matlab
repository_root = "/path/to/2024.0979.1";
addpath(genpath(fullfile(repository_root, "scripts")));
```

### Read DICOM structures

`scripts/DICOM_files_reader/read_structures.m` reads an RT structure set,
iterates through ROI contour sequences, and plots contour coordinates in
three dimensions.

1. In the script, set the `dicominfo(...)` filename to a selected structure
   set under `data/DICOM_FILES/`.
2. Run:

   ```matlab
   run("scripts/DICOM_files_reader/read_structures.m")
   ```

### Read or inspect needles

`scripts/DICOM_files_reader/read_needles.m` contains an example set of needle
endpoints and creates 0.1 cm-spaced dwell positions along each needle. It
writes these files to the MATLAB current folder:

- `start_point_directions_on_needles.csv`;
- `end_point_directions_on_needles.csv`;
- `middle_point_directions_on_needles.csv`; and
- `needle_number.csv`.

For an RT plan, `scripts/Dose_calculation_codes/dwell_position_creation.m`
uses `dicominfo` to read channels and brachytherapy control points from the
configured needle-plan DICOM file, estimates the channel direction, and
derives source endpoints.

### Work with body structures and voxels

`scripts/Body_organs_redear_codes/` contains the MATLAB helpers used to
extract, visualize, and voxelize RT structure contours:

| File | Role |
| --- | --- |
| `BrachyBasicInfo.m` | Reads basic RT-structure-set metadata, ROI counts, colors, bounds, and slice information. |
| `BrachyGetSlice.m` | Retrieves the coordinates for an individual contour slice. |
| `BrachyPlotContourSlice.m` | Plots selected contour regions on a slice. |
| `BrachyPlotContourVolume.m` | Plots selected contours as a three-dimensional volume. |
| `BrachyPlotVoxelizedSlice.m` | Plots voxelized regions on a slice. |
| `BrachyPlotVoxelizedVolume.m` | Plots voxelized regions in three dimensions. |
| `BrachyVoxelizeNew.m` | Runs the voxelization workflow. |
| `BrachyVoxelizeSlice.m` | Voxelizes a single structure contour slice. |

These functions depend on variables and geometry derived from the DICOM
structure-set workflow, so run them after loading the appropriate case data.

### Generate a dwell-point polyhedron

`scripts/Polyhydron_generation/polyhydrons_of_structures.m` reads selected
dwell points, computes their convex hull, derives plane equations using
symbolic variables, and plots the resulting polyhedron. Configure its
`filename` variable to:

```text
data/RAW DATA /Selected_dwell_points.xlsx
```

before running it.

### Calculate dose

| Script | Source model | Required primary inputs | Generated output |
| --- | --- | --- | --- |
| `linear_dose_computation.m` | Finite line source | `body_voxels.xlsx`, source start points, source end points | `dose_received_by_voxels.csv` |
| `point_source_dose_calculatio.m` | Point source | `body_voxels.xlsx`, `Selected_dwell_points.xlsx` | `dose_received_by_voxels_point_source.csv` |

Both scripts define a local `Dose_Computation` function and write results to
their current MATLAB directory. Configure their `RAW_DATA/...` filenames to
the corresponding paths in `data/RAW DATA /` before execution.

## Julia optimization workflows

Run each Julia workflow from its own method directory. This is important
because the scripts resolve their `data/` and `output/` locations relative to
that directory.

### Fixed-needle method

Directory:

```text
scripts/Math_Methods/fixed_needle_method/
```

Run:

```bash
julia fixed_needle_method.jl
```

The model selects needles and dwell times subject to dose constraints,
incompatibility constraints, dwell-time limits, and a maximum needle count.
Edit `fixed_needle_parameters.jl` when replacing its data. Outputs are:

- `output/dwell_times.csv`
- `output/selected_needle_indices.csv`

See
[`scripts/Math_Methods/fixed_needle_method/README.md`](scripts/Math_Methods/fixed_needle_method/README.md)
for input-shape requirements.

### Free-needle phase 1

Directory:

```text
scripts/Math_Methods/free needle phase 1/
```

Run:

```bash
julia free_needle_phase_1.jl
```

This phase optimizes dwell times from its dose matrix and retains the
largest-dwell-time candidate positions for later phases. Edit
`free_needle_phase_1_parameters.jl` for voxel ranges, dose bounds, penalty
weights, maximum dwell time, and the number of retained candidates. Outputs
are:

- `output/dwell_times.csv`
- `output/candidate_dwell_positions.csv`

See
[`scripts/Math_Methods/free needle phase 1/README-free-needle-phase-1.md`](scripts/Math_Methods/free%20needle%20phase%201/README-free-needle-phase-1.md)
for details.

### Maximum coverage method

Directory:

```text
scripts/Math_Methods/Maximum Coverage method/
```

Run:

```bash
julia maximum_coverage_method.jl
```

The model selects at most `MAX_SELECTED_NEEDLES` candidate needles using
coverage weights and candidate-needle intersection constraints. Update
`maximum_coverage_parameters.jl` and replace the files in `data/` for a new
case. Results are written to `output/`.

See
[`scripts/Math_Methods/Maximum Coverage method/README.md`](scripts/Math_Methods/Maximum%20Coverage%20method/README.md)
for the coverage-matrix definition.

## Constrained line-clustering variants

The clustering models are in:

```text
scripts/Math_Methods/kmeans_clustering_method_variants/
```

Every variant is self-contained and includes:

- `run_clustering.jl` — entry point;
- `line_fitter.jl` — the model-specific fitting formulation;
- `problem_data.jl` — input loading and shared geometric data;
- `parameters.jl` — model parameters;
- `data/` — point and constraint CSV inputs; and
- `output/` — generated results.

Run any variant from its own directory:

```bash
julia run_clustering.jl
```


## Results

The repository includes tracked manuscript figures under `results/figures/`:

- body-structure and clinical-needle visualizations for the ear case and both
  nasal cases;
- fixed-needle and free-needle configuration figures;
- dose-volume histogram figures for clinical, fixed-needle, maximum-coverage,
  and clustering-approach solutions;
- five clustering-variant configuration figures; and
- combined all-case plots.

`results/tables/` contains figures summarizing dose metrics across clustering
models and solution times for each model.




## Authors

- Nasim Mirzavand Boroujeni
  (`nasimmirzavand1373@gmail.com`)
- Jean-Philippe Richard
  (`jrichar@umn.edu`)
- David Sterling
  (`sterl035@umn.edu`)
- Christopher T. Wilke
  (`wilkect@upmc.edu`)

## License

The source code is distributed under the MIT License. See `LICENSE`.

The DICOM data and external software dependencies, including MATLAB and
Gurobi, remain subject to their own licenses, governance, and use
requirements.
