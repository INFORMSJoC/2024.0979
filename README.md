# Optimization Models for Needle Placement in 3D-Printed HDR-BT Masks

This repository contains research code and anonymized DICOM-RT data supporting
the manuscript:

> Mirzavand Boroujeni, N., Richard, J.-P. P., Sterling, D., and Wilke, C.
> *Optimization models for needle placement in 3D-printed masks for
> high-dose-rate brachytherapy.*

The work studies the placement of straight channels in patient-specific,
3D-printed surface masks for high-dose-rate brachytherapy (HDR-BT) of
superficial skin cancer. The materials include MATLAB scripts for DICOM
geometry, dwell-point generation, and dose calculations, together with a
separate Julia implementation for constrained line clustering.

## Repository layout

| Path | Contents |
| --- | --- |
| `data/DICOM_FILES/` | Anonymized DICOM-RT structure sets and needle plans for two nasal cases and one ear case. |
| `data/RAW DATA /` | Voxel coordinates, selected dwell points, and needle source-endpoint CSV inputs. |
| `scripts/DICOM_files_reader/` | MATLAB scripts that read DICOM structure and needle data. |
| `scripts/Body_organs_redear_codes/` | MATLAB functions for reading, plotting, slicing, and voxelizing contour volumes. |
| `scripts/Polyhydron_generation/` | MATLAB code to construct a convex polyhedron from selected dwell points. |
| `scripts/Dose_calculation_codes/` | MATLAB code that creates dwell positions and calculates line-source or point-source doses. |
| `results/` | Location for generated figures and tables. |



It is intentionally separate from this MATLAB repository and contains all of
its required Julia files and CSV inputs in one folder.

## Data and privacy

The supplied DICOM-RT files are anonymized research data. As described in
`data/README.md`, direct and indirect identifiers, dates, UIDs, nested-sequence
content, and private attributes have been removed or transformed. The data are
for research and reproducibility purposes only; they are not clinical-treatment
software and must not be used for patient care.

The available DICOM cases are:

| Structure set | Needle plan |
| --- | --- |
| `RS_anon_roi_ear_case_body_structure.dcm` | `ear_needles.dcm` |
| `RS_anon_roi_nose_1_case_body_structure.dcm` | `nose1_needles.dcm` |
| `RS_anon_roi_nose_2_case_body_structure.dcm` | `nose_2_needles.dcm` |

## Software requirements

### MATLAB

Install a current desktop release of MATLAB for macOS from the MathWorks
installer:

1. Sign in at <https://www.mathworks.com/downloads/>.
2. Download and open the macOS installer.
3. Sign in with the license that provides MATLAB.
4. Select **MATLAB** and install these required toolboxes:
   - **Image Processing Toolbox** for DICOM functions such as `dicominfo`;
   - **Symbolic Math Toolbox** for `syms` and `solve` in
     `polyhydrons_of_structures.m`.
5. Open MATLAB and verify the installation:

```matlab
ver
which dicominfo
which syms
```

`dicominfo` and `syms` should resolve to MATLAB toolbox functions. The
repository also uses `xlsread`, `xlswrite`, `csvread`, and `csvwrite`. These
legacy functions remain in many MATLAB releases; if a current release warns
about them, the existing scripts may still be used as written.


### Julia, Gurobi

The Julia workflow requires Julia, the Julia packages listed below, Gurobi, and
a valid Gurobi license. The optimization cannot run without a licensed Gurobi
installation.

Install Julia for macOS:

1. Download the current stable macOS installer from
   <https://julialang.org/downloads/>.
2. Install Julia and open **Terminal**.
3. Confirm that the `julia` command is available:

```bash
julia --version
```

If that command is not found, start Julia from its installed application or
add the Julia executable directory to your shell `PATH` according to the
Julia macOS installation instructions.

Install Gurobi from <https://www.gurobi.com/downloads/> and activate a valid
license. Then install the Julia packages from a Julia session:

```julia
using Pkg
Pkg.add([
    "CSV",
    "Clustering",
    "DataFrames",
    "DelimitedFiles",
    "Distributions",
    "Formatting",
    "Gurobi",
    "JuMP",
    "StatsBase",
])
```

Verify that Julia can load the optimization stack:

```julia
using JuMP, Gurobi, CSV, DataFrames
println("Julia and Gurobi.jl loaded successfully.")
```

If `using Gurobi` fails, complete the Gurobi license setup first and consult
the Gurobi.jl installation instructions at
<https://github.com/jump-dev/Gurobi.jl>.

## MATLAB workflow

Run scripts from MATLAB after adding the repository to the path. The scripts
currently contain case-specific file names and relative paths. Before each
run, set the file name or path in the script to the desired file under
`data/DICOM_FILES/` or `data/RAW DATA /`. This is necessary because the
current scripts do not automatically discover input files.

### 1. Read and visualize DICOM structures

`scripts/DICOM_files_reader/read_structures.m` reads the currently configured
RT structure-set file, extracts all contour coordinates, and plots the
contours in 3D.

For example, change its `dicominfo` input to the selected case:

```matlab
B = dicominfo(fullfile( ...
    'GitHub/2024.0979', ...
    'data', 'DICOM_FILES', 'RS_anon_roi_nose_1_case_body_structure.dcm'));
```

Then run:

```matlab
run('scripts/DICOM_files_reader/read_structures.m')
```

### 2. Read needle plans

`scripts/DICOM_files_reader/read_needles.m` reads a DICOM RT plan, extracts
brachytherapy control-point positions, estimates a principal needle direction,
and produces a 3D plot.

Set the `dicominfo` input to one of the needle-plan files, then run:

```matlab
run('scripts/DICOM_files_reader/read_needles.m')
```

### 3. Generate a dwell-point polyhedron

`scripts/Polyhydron_generation/polyhydrons_of_structures.m` reads
`Selected_dwell_points.xlsx`, calculates the convex hull, and uses symbolic
equations to derive plane normals and offsets.

The script presently expects an input path named
`RAW_DATA/Selected_dwell_points.xlsx`, while this repository stores the file
at `data/RAW DATA /Selected_dwell_points.xlsx`. Update the script's `filename`
variable to the actual path before running:

```matlab
run('scripts/Polyhydron_generation/polyhydrons_of_structures.m')
```

### 4. Create dwell positions from needle endpoints

`scripts/Dose_calculation_codes/dwell_position_creation.m` defines needle
endpoints directly in the script, generates positions at 0.1 cm intervals,
and writes these files in its current working directory:

- `start_point_directions_on_needles.csv`
- `end_point_directions_on_needles.csv`
- `middle_point_directions_on_needles.csv`
- `needle_number.csv`

Run it from the intended output folder so its relative CSV paths are written
there:

```matlab
cd('GitHub/2024.0979/data/RAW DATA ')
run('../../scripts/Dose_calculation_codes/dwell_position_creation.m')
```

### 5. Calculate dose

`linear_dose_computation.m` evaluates dose from finite line sources using body
voxels and source endpoints. `point_source_dose_calculatio.m` evaluates dose
from selected dwell points. Both scripts use relative `RAW_DATA/...` paths, so
update their `filename` variables to the actual files under `data/RAW DATA /`
before running.

Each script writes a CSV output in its current working directory:

| Script | Output |
| --- | --- |
| `linear_dose_computation.m` | `dose_received_by_voxels.csv` |
| `point_source_dose_calculatio.m` | `dose_received_by_voxels_point_source.csv` |

## Julia constrained line clustering workflow

The Julia folder contains:

| File | Purpose |
| --- | --- |
| `kmeans_line_clustering.jl` | Main entry point. |
| `binary_line_optimizer.jl` | Binary optimization helper. |
| `constrained_line_fitter.jl` | Constrained line-fitting helper. |
| `geometry_functions.jl` | Input loading, geometric distances, and initialization. |
| `input_points.csv` | Three-dimensional points to cluster. |
| `constraint_normals.csv` | Constraint plane normal vectors. |
| `constraint_offsets.csv` | Constraint plane offsets. |
| `constraint_signs.csv` | Constraint orientation signs. |

Run the workflow from its own folder:

```bash
julia kmeans_line_clustering.jl
```

The primary final output is:

```text
./cluster_line_segments.csv
```

It contains one row per cluster with `cluster`, `start_x`, `start_y`,
`start_z`, `end_x`, `end_y`, and `end_z`. Additional local CSV files record
line parameters, intermediate assignments, objectives, and runtime. The Julia
algorithm was not changed during code cleanup; only file names, local output
paths, and the final descriptive CSV export were added.

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

The repository is distributed under the MIT License. See `LICENSE` for the
full license text. DICOM data and any third-party tools remain subject to
their respective governance, license, and use requirements.
