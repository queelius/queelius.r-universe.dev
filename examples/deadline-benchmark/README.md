# Deadline benchmark

Compare API or inference backends without dropping timed-out requests from the
score. This base-R command reports what the observed sample establishes about
completion by a deadline, including a range when early timeouts hide outcomes.

From this directory:

```sh
Rscript run.R synthetic.csv 2 /tmp/deadline-summary.csv
Rscript tests/test-analysis.R
Rscript tests/test-cli.R
```

For your own data, use `Rscript run.R input.csv slo_seconds output.csv`.
The deadline must be a finite positive number. The output must differ from the
input; an existing output file is replaced. No package installation is needed.

The input must contain exactly these columns (CSV quoting is supported):

| Column | Meaning |
| --- | --- |
| `backend` | Non-empty backend label. |
| `seconds` | Non-negative finite elapsed time in seconds. |
| `outcome` | `completed`, `timeout`, or `failure`, with no missing values. |

Use one row per request and a consistent definition of completion. A timeout
means observation stopped while completion was still unresolved. Record an
explicit failed operation as `failure`; do not turn every HTTP error or user
cancellation into a timeout. Keep attempts and end-to-end requests separate.
Convert milliseconds to seconds before running the command.

For each backend, the output includes all request/outcome counts, timeout and
failure fractions, the deadline, success/unknown/miss counts, and sample
completion-fraction bounds:

- Completed at or before the deadline: known success.
- Timeout strictly before the deadline: unknown.
- Timeout at or after the deadline: known miss.
- Completion after the deadline or explicit failure: known miss.

The lower bound is `known successes / all requests`; the upper bound includes
all unknowns as possible successes. At a two-second deadline, synthetic backend
`alpha` has bounds **1/3 to 1/2**, and `beta` has bounds **2/3 to 2/3**. These are
fabricated demonstration records, not measured provider benchmarks.

The bounds describe this sample; they are **not confidence intervals** or
predictions of future traffic. The upper bound concerns the latent completion
outcomes hidden by early timeouts, not successes actually delivered to clients.
No p95 or unobserved tail is inferred. A fixed timeout cannot establish
completion times beyond that cutoff. Workload, retries, dependence, and
changing service conditions still matter when comparing backends.

To use the calculation from R, source `analysis.R` and call
`deadline_summary(data, slo_seconds)`. For a subsequent parametric analysis of
censored observations, see the ecosystem's `likelihood.contr` examples; those
require explicit distribution and censoring assumptions.

Author: Alexander Richard Towell. Implementation and tests developed with
substantial AI assistance (OpenAI Codex), 2026-10-28.
