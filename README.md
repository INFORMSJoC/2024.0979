[![INFORMS Journal on Computing Logo](https://INFORMSJoC.github.io/logos/INFORMS_Journal_on_Computing_Header.jpg)](https://pubsonline.informs.org/journal/ijoc)

# Optimization Models for Needle Placement in 3D-Printed Masks for High-Dose-Rate Brachytherapy

This archive is distributed under the [MIT License](LICENSE).

The software, data documentation, and experiment materials in this repository
are a snapshot associated with the paper [*Optimization models for needle
placement in 3D-printed masks for high-dose-rate brachytherapy*](https://arxiv.org/abs/2503.06000)
by Nasim Mirzavand Boroujeni, Jean-Philippe Richard, David Sterling, and
Christopher T. Wilke.

## Cite

To cite the contents of this repository, cite the associated paper and this
software repository:

- Paper: <https://arxiv.org/abs/2503.06000>
- Repository: <https://github.com/Nasim1373/2024.0979.1>

Use the following BibTeX entries:

```bibtex
@misc{MirzavandBoroujeniEtAl2025,
  author        = {Nasim Mirzavand Boroujeni and Jean-Philippe Richard and David Sterling and Christopher T. Wilke},
  title         = {{Optimization Models for Needle Placement in 3D-Printed Masks for High-Dose-Rate Brachytherapy}},
  year          = {2025},
  eprint        = {2503.06000},
  archiveprefix = {arXiv},
  url           = {https://arxiv.org/abs/2503.06000}
}

@misc{MirzavandBoroujeniEtAlRepository,
  author = {Nasim Mirzavand Boroujeni and Jean-Philippe Richard and David Sterling and Christopher T. Wilke},
  title  = {{Optimization Models for Needle Placement in 3D-Printed Masks for High-Dose-Rate Brachytherapy: Code Repository}},
  url    = {https://github.com/Nasim1373/2024.0979.1},
  note   = {Research code and reproducibility materials}
}
```

## Software installation

### MATLAB

Install a current desktop MATLAB release from
<https://www.mathworks.com/downloads/>:

1. Download and open the installer for your operating system.
2. Sign in with the MathWorks account associated with your license.
3. Install **MATLAB** and ensure that DICOM support is available.
4. Install the **Symbolic Math Toolbox** for the polyhedron-construction
   script.

Confirm the MATLAB installation and required functions from the MATLAB Command
Window:

```matlab
ver
which dicominfo
which syms
```

The MATLAB code uses `dicominfo`, `xlsread`, `xlswrite`, `csvread`, and
`csvwrite`. Some current MATLAB releases may display compatibility warnings
for the legacy Excel and CSV functions.

### Julia and Gurobi

The Julia optimization models require Julia, Gurobi, a valid Gurobi license,
and the Julia packages `CSV`, `DataFrames`, `DelimitedFiles`, `Gurobi`,
`JuMP`, `LinearAlgebra`, and `Random`.

1. Install Julia from <https://julialang.org/downloads/>.
2. Install Gurobi from <https://www.gurobi.com/downloads/>.
3. Request and activate a **full academic Gurobi license** through
   <https://www.gurobi.com/academia/academic-program-and-licenses/>. The
   large-scale models in this repository may exceed the limits of restricted
   or size-limited licenses.
4. In a Julia session, install the required packages:

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

5. Confirm that Julia can access the solver interface:

   ```julia
   using JuMP, Gurobi
   println("JuMP and Gurobi.jl loaded successfully.")
   ```

The Julia mathematical-programming models cannot solve without a valid Gurobi
license. Use a full academic license when solving the large-scale models.

## Description

This repository contains research implementations for placing straight
treatment channels in patient-specific, 3D-printed surface masks for
high-dose-rate brachytherapy (HDR-BT) of superficial skin cancer. The
repository includes:

- MATLAB code for DICOM-RT geometry, contour visualization, voxelization,
  dwell-position creation, and dose calculations;
- Julia/Gurobi formulations for fixed-needle selection, free-needle phase 1,
  and maximum coverage; and
- Julia/Gurobi variants for clustering three-dimensional points into
  constrained infinite lines or finite line segments.

This is research and reproducibility code, **not clinical
treatment-planning software**. Do not use it for patient care.

## Repository layout

| Path | Contents |
| --- | --- |
| `data/DICOM_FILES/` | Sample anonymized DICOM-RT structure sets and needle plans. |
| `data/RAW DATA /` | Sample voxel, dwell-point, and source-endpoint data. |
| `data/README.md` | DICOM data description, anonymization, governance, and source attribution. |
| `scripts/DICOM_files_reader/` | DICOM-RT structure and needle scripts. |
| `scripts/Body_Organs_Redear_Codes/` | Body-structure contour, slice, volume, and voxelization helpers. |
| `scripts/Polyhydron_generation/` | Convex-polyhedron construction from dwell points. |
| `scripts/Dose_Calculation_Codes/` and `scripts/Dose_calculation_codes/` | Dose-calculation and dwell-position scripts. |
| `scripts/Math_Methods/` | Optimization formulations and constrained clustering variants. |
| `AUTHORS` | Project authors and contact information. |
| `LICENSE` | MIT License text. |

## Sample data and replacement requirement

All data files supplied with this repository are **sample research inputs**.
They illustrate the required file organization and data shapes for the
included examples. For a different desired case, replace the applicable
sample input file with your own data and update the corresponding
case-specific parameters, ranges, or filenames in the relevant script.

Replacement data must preserve the format expected by the selected method.
In particular, retain the required number of coordinate columns, matrix
orientation, compatible row and column counts, and valid index ranges.

### Sample DICOM-RT data

`data/DICOM_FILES/` provides sample anonymized DICOM-RT files for one ear
case and two nasal cases:

| Sample case | Structure set | Needle plan |
| --- | --- | --- |
| Ear | `RS_anon_roi_ear_case_body_structure.dcm` | `ear_needles.dcm` |
| Nasal 1 | `RS_anon_roi_nose_1_case_body_structure.dcm` | `nose1_needles.dcm` |
| Nasal 2 | `RS_anon_roi_nose_2_case_body_structure.dcm` | `nose_2_needles.dcm` |

Replace the selected structure-set and needle-plan sample files with the
anonymized files for your desired case. Consult `data/README.md` for the
anonymization, governance, and research-use conditions that apply to the
provided examples.

### Sample MATLAB data

`data/RAW DATA /` provides the following sample inputs:

| Sample file | Expected contents | Replace for a desired case |
| --- | --- | --- |
| `Selected_dwell_points.xlsx` | Three-dimensional selected dwell-point coordinates. | Replace with the desired dwell-point coordinate workbook. |
| `body_voxels.xlsx` | Three-dimensional body-voxel coordinates. | Replace with the desired voxel coordinate workbook. |
| `start_point_directions_on_needles.csv` | One active-source start point per dwell position. | Replace with source start points matching the desired dwell positions. |
| `end_point_directions_on_needles.csv` | One active-source end point per dwell position. | Replace with source end points matching the desired dwell positions. |

Use matching coordinate units and dimensions across any dwell-point,
source-endpoint, and voxel files used together.

### Sample Julia optimization data

Every Julia formulation has a method-specific `data/` directory. The files in
those directories are samples and must be replaced by compatible inputs for a
new desired case.

| Method family | Sample input files | Replacement requirement |
| --- | --- | --- |
| Fixed needle | `dose_matrix.csv`, `dwell_to_needle.csv`, `incompatible_needles.csv` | Replace all three with compatible dose, dwell-to-needle, and incompatibility data. |
| Free needle phase 1 | `dose_matrix.csv` | Replace with a voxel-by-dwell-position dose-rate matrix. |
| Maximum coverage | `candidate_needle_coverage.csv`, `candidate_needle_coverage_weights.csv`, `candidate_needle_intersections.csv` | Replace all matrices for the desired candidate-needle set. |
| Clustering variants | `input_points.csv`, `constraint_normals.csv`, `constraint_offsets.csv`, `constraint_signs.csv` | Replace all point and constraint files together for the desired geometry. |

Do not combine samples from different method folders without also checking
the associated parameter definitions and matrix dimensions.

## MATLAB components

### DICOM structure reader

`scripts/DICOM_files_reader/read_structures.m` processes the configured RT
structure set, iterates through region-of-interest contour sequences, and
visualizes the contour coordinates in three dimensions. Replace the
configured sample DICOM structure-set filename with the anonymized structure
set for the desired case.

### Needle and dwell-position scripts

`scripts/DICOM_files_reader/read_needles.m` contains sample needle endpoints
and derives dwell positions at 0.1 cm intervals along each needle. Replace
the embedded endpoint sample with the desired needle geometry.

`scripts/Dose_calculation_codes/dwell_position_creation.m` processes the
configured sample needle-plan DICOM file, extracts brachytherapy control
points, estimates needle directions, and derives source endpoints. Replace
the configured sample DICOM filename with the needle plan for the desired
case.

### Body-structure and voxel helpers

`scripts/Body_Organs_Redear_Codes/` contains MATLAB helper functions for
contour extraction, visualization, and voxelization:

| File | Role |
| --- | --- |
| `BrachyBasicInfo.m` | Obtains RT-structure-set metadata, region counts, colors, bounds, and slice information. |
| `BrachyGetSlice.m` | Retrieves coordinates for an individual contour slice. |
| `BrachyPlotContourSlice.m` | Visualizes selected contour regions on a slice. |
| `BrachyPlotContourVolume.m` | Visualizes selected contours as a three-dimensional volume. |
| `BrachyPlotVoxelizedSlice.m` | Visualizes voxelized regions on a slice. |
| `BrachyPlotVoxelizedVolume.m` | Visualizes voxelized regions in three dimensions. |
| `BrachyVoxelizeNew.m` | Contains the voxelization workflow. |
| `BrachyVoxelizeSlice.m` | Voxelizes a single structure-contour slice. |

Replace the sample DICOM and geometry data used by these helpers with data
for the desired case.

### Polyhedron construction

`scripts/Polyhydron_generation/polyhydrons_of_structures.m` constructs a
convex polyhedron from selected dwell points, computes the convex hull, and
derives plane normals and offsets using symbolic equations. Replace the
sample `Selected_dwell_points.xlsx` file with the selected dwell-point
workbook for the desired case.

### Dose calculations

| Script | Source representation | Sample inputs to replace |
| --- | --- | --- |
| `scripts/Dose_Calculation_Codes/linear_dose_computation.m` | Finite line source | Body voxels and source start/end points. |
| `scripts/Dose_Calculation_Codes/point_source_dose_calculatio.m` | Point source | Body voxels and selected dwell points. |

The two scripts contain local dose-computation definitions. Replace every
sample coordinate file used by the selected dose model with compatible data
from the desired case.

## Julia optimization components

### Fixed-needle method

`scripts/Math_Methods/fixed_needle_method/` defines a mixed-integer model
that selects needles and dwell times subject to dose constraints,
incompatibility constraints, dwell-time limits, and a maximum needle count.

Replace the sample files in its `data/` directory and revise
`fixed_needle_parameters.jl` so the needle count, voxel ranges, dose bounds,
penalty weights, dwell-time limit, and selection limit match the desired
case.

See
[`scripts/Math_Methods/fixed_needle_method/README.md`](scripts/Math_Methods/fixed_needle_method/README.md)
for its detailed data format.

### Free-needle phase 1

`scripts/Math_Methods/free needle phase 1/` contains the first free-needle
phase, which optimizes dwell times from a dose matrix and identifies
candidate dwell positions.

Replace `data/dose_matrix.csv` with the desired voxel-by-dwell-position
dose-rate matrix. Revise `free_needle_phase_1_parameters.jl` so its voxel
ranges, dose bounds, penalty weights, dwell-time limit, and candidate count
match the replacement data.

See
[`scripts/Math_Methods/free needle phase 1/README-free-needle-phase-1.md`](scripts/Math_Methods/free%20needle%20phase%201/README-free-needle-phase-1.md)
for its detailed data format.

### Maximum-coverage method

`scripts/Math_Methods/Maximum Coverage method/` defines a model for selecting
candidate needles using coverage weights and candidate-needle intersection
constraints.

Replace the three sample coverage and intersection matrices in its `data/`
directory with matrices for the desired candidate-needle set. Revise
`maximum_coverage_parameters.jl` to match the replacement data.

See
[`scripts/Math_Methods/Maximum Coverage method/README.md`](scripts/Math_Methods/Maximum%20Coverage%20method/README.md)
for the coverage-matrix definition.

## Constrained line-clustering variants

The clustering formulations are in:

```text
scripts/Math_Methods/kmeans_clustering_method_variants/
```

Each variant contains `run_clustering.jl`, `line_fitter.jl`,
`problem_data.jl`, `parameters.jl`, and a `data/` directory with sample
three-dimensional points and constraint data. Replace every sample CSV in
the selected variant's `data/` directory and revise `parameters.jl` for the
desired geometry.

| Folder | Line representation | Formulation |
| --- | --- | --- |
| `infinite_line_nonconvex_qcqp` | Infinite line | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_fixed_bounds` | Finite segment with fixed bounds | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_fixed_parameter_bounds` | Finite segment with fixed parameter bounds | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_variable_bounds` | Finite segment with variable lower and upper bounds | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_lower_bound` | Finite segment with a determined lower bound and fixed upper bound | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_two_sided_bounds` | Finite segment with determined lower and upper bounds | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_two_sided_bounds_minimum_length` | Finite segment with two-sided bounds and a minimum length | Nonconvex QCQP |
| `infinite_line_nonconvex_qcqp_alternating_refinement` | Infinite line with alternating refinement | Nonconvex QCQP |
| `infinite_line_nonconvex_qcqp_quadratic_cone_refinement` | Infinite line with quadratic-cone refinement | Nonconvex QCQP |

See
[`scripts/Math_Methods/kmeans_clustering_method_variants/README.md`](scripts/Math_Methods/kmeans_clustering_method_variants/README.md)
for the variant directory structure.

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

The DICOM examples and external dependencies remain subject to their own
licenses, governance, and use requirements.
