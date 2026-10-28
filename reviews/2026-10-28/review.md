# Ecosystem review and improvement, 2026-10-28

Author and maintainer: Alexander Richard Towell (ORCID 0000-0001-6443-9897).
Assessment, implementation and initial review substantially assisted by OpenAI
Codex agents. These are executable software checks and AI-assisted reviews,
not a claim of independent human review, peer review or novel statistical methods.

## Recommendation

Lead with **timeout-aware service and AI latency benchmarking**. Strengthen
`likelihood.contr` as the reusable entry point instead of creating a fifteenth
package that wraps existing layers. Its useful distinction is explicit
composition of custom observation mechanisms: raw times, right/left censoring,
interval measurements, and now counted telemetry bins.

The deliverables include a tested base-R CSV-to-SLO-report app, an executable
parametric demo and vignette, plus `contr_freq()` in
likelihood.contr 0.2.0. It is not yet a hosted dashboard, an OpenTelemetry
collector, or a validated ranking of real AI providers. Demand is a product
hypothesis; the user selected this audience. The next validation should use
consented, anonymized request-level data across repeated matched load tests.

The synthetic control produces 14.5% timeouts at two seconds, completed-only
p95 1.716 seconds, censored exponential p95 3.114 seconds, and known population
p95 2.996 seconds. Those are simulation results, not performance measurements.
The observed data alone do not identify the p95 beyond the timeout. Always
separate model-dependent extrapolation, observed SLO success, and failure/quality
rates. Errors, refusals, retries and cancellations require explicit semantics.

Relevant primary sources establish a real integration surface:
[OpenTelemetry HTTP metrics](https://opentelemetry.io/docs/specs/semconv/http/http-metrics/)
and [vLLM serving benchmark implementation](https://github.com/vllm-project/vllm/blob/main/vllm/benchmarks/serve.py).
This application recommendation is our inference from that surface and the code,
not evidence that existing benchmarks universally mishandle timeouts.

## Architecture and positioning

The reusable spine is distribution algebra -> MLE results -> likelihood models
-> observation contributions. Reliability topology belongs in dist.structure;
maskedcauses defines the masked-data protocol. Keeping those responsibilities
separate is sound, but first-time users should see a complete decision workflow
before learning the abstractions.

| Layer | Packages | Recommended role |
|---|---|---|
| Distributions and uncertainty | algebraic.dist, algebraic.mle | supporting composition and inference |
| Models and optimization | likelihood.model, compositional.mle | shared inference and solver machinery |
| Observation mechanisms | likelihood.contr | primary practical library entry point |
| Topology and hazards | dist.structure, flexhaz, serieshaz | reliability simulation and custom hazards |
| Incomplete system observations | maskedcauses, maskedhaz, kofn | specialist reliability inference |
| Derivatives | nabla | low-dimensional higher derivatives of supported scalar expressions |
| Hypothesis testing | hypothesize | standalone consistent test representation |
| Educational autodiff | femtograd | pedagogy; defer production/CRAN positioning |

Use survival, fitdistrplus and flexsurv for their established standard workflows.
The prior flexhaz comparison understated competitor censoring/custom model support;
it has been replaced with accurate positioning and primary documentation links.
No novelty or superiority claim is made for censoring or frequency weighting.

## Correctness improvements

- algebraic.mle 2.0.3: align named estimates and covariance/information axes
  before pooling; reject ambiguous parameter identities. Forward transformation
  arguments consistently to point estimates and uncertainty propagation.
- compositional.mle 2.0.1: preserve failed solver slots in restart/race results,
  so a failed attempt cannot discard earlier successes or misalign metadata.
- likelihood.model 1.0.2: stop inferring positivity of nuisance parameters from
  the signs of fitted estimates. Regression matches an analytical correlated
  quadratic profile interval.
- nabla 0.7.2: fix polynomial derivatives at zero, nested dual zero detection,
  and scalar cumulative min/max derivatives; narrow arbitrary-R-code claims.
- flexhaz 0.5.3: reject missing/invalid event codes and invalid observation times
  instead of silently discarding rows.
- dist.structure 0.5.1: respect nonnegative support in closed-form system
  distributions, avoiding survival probabilities above one and negative CDFs.
- kofn: repair README examples to use typed component prototypes; correct
  the left/right censoring counts.
- likelihood.contr 0.2.0: frequency-weighted contribution objects, regression
  and integration tests, counted-bin example, timeout walkthrough and demo.

## Remaining material findings

These are known limitations, not claims that the entire ecosystem is defect-free.

1. maskedhaz assumes every parameter is positive although arbitrary hazards
   may use unrestricted log-rates or covariate coefficients. It also needs a
   shared explicit observation schema: x2/x3 columns can silently be treated as
   components 1/2. Design a parameter/domain and candidate-matrix protocol
   before marketing this as unrestricted custom-hazard inference.
2. dist.structure accepts malformed topology indices (e.g. path containing 0)
   and its general topology algorithms can have exponential/factorial cost.
   Validate structured topology inputs and make computational limits explicit.
   A pre-existing Weibull k-out-of-n density can also return NaN exactly at
   zero through an Inf*0 boundary calculation; positive-time limits remain
   usable, but this deserves a separate analytical boundary fix.
3. femtograd has reproducible optimizer fallback, stale final diagnostics,
   clipping derivative and stable-function/Hessian compatibility bugs despite
   a passing baseline suite. Keep it out of CRAN submission in this wave.
4. likelihood.contr callback lengths and duplicate contribution names are now
   validated, with regression tests. Frequency-weighted likelihoods are correct, but generic fit
   metadata counts rows and generic bootstrap resamples rows: the new vignette
   explicitly avoids default BIC/row-bootstrap for counted data. A future
   observation-size/resampling protocol should represent those semantics.
5. likelihood.model's substantial tests/test.R runs under R CMD check, but
   devtools::test does not discover it. Local validation must source that file
   until the harness is migrated.
6. The simple latency example does not model workload heterogeneity, dependence,
   arbitrary censoring, retries or provider quality. Real benchmark comparison
   needs repeated runs, matched load/workloads, and sensitivity analysis.

## Validation and release evidence

All 14 packages received source/architecture review. Baseline unit/integration
suites were run; the kofn five-component numerical stress fit was stopped
after 15m56s and its full suite remains incomplete. Its changed README
constructors and focused integration checks pass. Exact final results, coverage and checks are recorded in the
companion evidence files. High line coverage did not prevent the mathematical
and identity bugs above. New regressions use analytical identities and invariants.

The live CRAN PACKAGES index was parsed by R on 2026-10-28, without default
R-version filtering: 13 existing packages match their pre-edit local versions;
femtograd is absent. `packages.csv` records source and CRAN versions.
No unchanged version needs resubmission. Releases must distinguish a validated
local tarball, upload success, maintainer confirmation and CRAN acceptance.
See [CRAN policy](https://cran.r-project.org/web/packages/policies.html).

Detailed audits: [foundations](foundations.md), [reliability](reliability.md),
[automatic differentiation](autodiff.txt). These preserve the distinction
between baseline findings and the final changes; the release evidence supersedes
any provisional "running" status within them.
