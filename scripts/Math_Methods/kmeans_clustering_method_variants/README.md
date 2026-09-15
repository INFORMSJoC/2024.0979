# K-means Line Models by Formulation

Each subfolder is independent. It has its own
`data/`, `output/`, `problem_data.jl`, `line_fitter.jl`, and
`run_clustering.jl`. Run a model from its own folder:

```bash
julia run_clustering.jl
```

| Folder | Line representation | Formulation |
|---|---|---|
| `infinite_line_nonconvex_qcqp` | Infinite line | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_fixed_bounds` | Finite segment with fixed bounds | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_variable_bounds` | Finite segment with variable lower and upper bounds | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_lower_bound` | Finite segment with a determined lower bound and fixed upper bound | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_two_sided_bounds` | Finite segment with determined lower and upper bounds | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_two_sided_bounds_minimum_length` | Finite segment with two-sided bounds and a minimum length | Nonconvex QCQP |
| `infinite_line_nonconvex_qcqp_alternating_refinement` | Infinite line with alternating refinement | Nonconvex QCQP |
| `infinite_line_nonconvex_qcqp_quadratic_cone_refinement` | Infinite line with quadratic-cone refinement | Nonconvex QCQP |
| `finite_segment_nonconvex_qcqp_fixed_parameter_bounds` | Finite segment with fixed parameter bounds | Nonconvex QCQP |

