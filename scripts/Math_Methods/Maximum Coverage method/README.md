# Maximum Coverage Method

To run this code for any desired case:

1. Change the desired-case parameters in `maximum_coverage_parameters.jl`.
2. Replace the input files in the `data` folder.
3. Run:

   ```bash
   julia --project=. maximum_coverage_method.jl
   ```

The output files are written to the `output` folder.

`candidate_needle_coverage.csv` is the candidate-needle-by-dwell-position binary
coverage matrix. It is used by constraint (7b), which permits at most one selected
candidate needle to cover each dwell position.
