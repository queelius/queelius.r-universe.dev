# Reliability ecosystem review , 2026-10-28

Read-only assessment covered dist.structure, flexhaz, serieshaz, kofn,
maskedcauses, maskedhaz. Authorized follow-up fixes are described below.

## Product direction

The strongest near-term application is **timeout-aware latency planning** for
APIs and AI inference workflows: treat client timeouts as right censoring,
estimate completion probability by deadline, compare simple fitted models,
and propagate component completion times through a declared workflow.
Use actual elapsed observations and explicit completion/censoring codes.
Do not infer success from HTTP status alone; failures and cancellations are
not automatically independent censoring. Avoid claims of unrestricted tail
identification: fixed timeouts provide no empirical tail past that timeout.

This is a grounded application proposal, not demonstrated market demand.
OpenTelemetry defines HTTP request duration in seconds and records timeout
errors, giving a real ingestion target:
https://opentelemetry.io/docs/specs/semconv/http/http-metrics/
But intentional cancellation may omit error.type:
https://opentelemetry.io/docs/specs/semconv/http/http-spans/
A structured per-request adapter needs explicit event semantics; histogram
aggregates cannot be silently converted into exact observations.

For completion times, a workflow requiring *all* concurrent steps completes at
max(T_j), while a race for the first successful result is min(T_j). This is the
reverse of some reliability-lifetime verbal intuitions. In particular kofn
uses failure-count k (:F), while dist.structure uses surviving-count k (:G).
The bridge is k_G = m-k_F+1. Make these semantics explicit in any application.
Independence is substantive; shared provider load and retries violate it.

## Architecture and adoption

- dist.structure is the reusable distribution/topology layer. General
  algorithms enumerate 2^m states or m! permutations; large service graphs
  need specialized methods or simulation and explicit size limits.
- flexhaz builds distributions and likelihoods from hazard functions;
  serieshaz adds component composition; maskedhaz adds candidate-set failure
  attribution; maskedcauses provides specialized analytical implementations.
- kofn specializes inference under observation schemes. Its mathematical
  feature is identifying component information lost under system-only
  observations and recovered through inspection. This deserves a concrete
  inspection-budget example more than another generic package diagram.
- Too much user-facing infrastructure appears before a completed task.
  Put one observation table -> fit -> deadline/risk decision first, retaining
  the small packages as implementation layers.
- Avoid claiming superiority over survival/flexsurv: both support multiple
  censoring types and flexsurv supports custom distributions. Official docs:
  https://stat.ethz.ch/R-manual/R-devel/library/survival/html/Surv.html
  https://chjackson.github.io/flexsurv/reference/flexsurvreg.html

## Confirmed correctness/adoption defects

1. **Fixed:** flexhaz/R/dfr_dist.R silently discarded invalid/missing event
   codes: loglik(dfr_exponential(1))(data.frame(t=2,delta=2),par=1) returned 0;
   delta=NA also returned 0. Shared observation ingestion now rejects unknown,
   missing or mistyped statuses and nonnumeric/nonfinite/negative times before
   likelihood or analytical derivative evaluation. Missing status *column*
   intentionally remains all-exact; logical statuses, zero times, custom column
   names, and empty data are preserved. Added 53 regression assertions.
2. **Fixed:** dist.structure closed-form exponential/Weibull functions ignored
   nonnegative support. surv(exp_series(c(1,2)))(-1) was 20.08554, and CDF was
   -19.08554. Base stats CDFs/densities now provide boundary handling. Added
   26 assertions spanning exponential, Weibull, Gamma and lognormal systems.
3. **Fixed:** kofn README used removed family= arguments, so first examples
   failed. Uses typed component prototypes now. Corrected swapped counts:
   k-1 previously failed components are left-censored; m-k survivors right.
4. **Open:** maskedhaz/R/loglik.R:67 globally rejects parameters <=0 despite
   arbitrary component hazards. Reproducer: dfr_dist(rate=function(t,par,...)
   rep(exp(par[1]),length(t)), par=-1, cum_haz_rate=function(t,par,...)
   t*exp(par[1])) wrapped in dfr_series_md; exact t=2, x1=TRUE gives -Inf instead
   of -1-2*exp(-1). A parameter-domain protocol/transform is needed; simply
   removing the guard would allow invalid built-in positive parameters.
5. **Open:** maskedhaz/fit.R accepts Brent/L-BFGS-B but passes no bounds and
   ignores ... for optim; arbitrary-domain fitting is not complete.
6. **Open:** coherent_dist accepts malformed/nonminimal component index sets
   and silently truncates fractional indices via as.integer; topology
   validation should reject malformed inputs rather than normalize silently.
7. **Open:** maskedhaz data decode uses regex column discovery with inferred
   positional component identity. Missing/noncontiguous columns can silently
   misalign parameter components; a shared explicit candidate matrix/schema
   would better meet the user's structured-data preference.

## Existing work preserved

kofn had untracked .papermill research reviews; maskedhaz had dirty .Rbuildignore
and untracked CRAN-SUBMISSION dated 2026-04-15. No edits made to those files.
No commits, pushes or CRAN submissions by this worker.

## Validation

Baseline devtools::test suites passed for dist.structure, flexhaz, serieshaz,
maskedcauses and maskedhaz. flexhaz emitted 30 pre-existing optimizer NaN/
related warnings. kofn was still running at this writing. Follow-up full suites,
coverage, and R CMD check --as-cran are being recorded in /tmp/*-coverage.log,
/tmp/*-cran-check.log and /tmp/*-full-test.log, with final summary sent to parent.

### Follow-up evidence

- Patched dist.structure full suite passed; coverage 84.86%. The
  dist_structure-class.R validator/protocol code has 1.92% coverage and dual.R
  10%; these are more important gaps than the highly exercised closed-form
  distribution methods (many at 100%).
- Patched flexhaz full suite passed with the same 30 baseline warnings.
  Coverage is 99.26%; final targeted validation passes 53 assertions.
- Invalid topology reproduction: coherent_dist(list(0),
  list(algebraic.dist::exponential(1))) is accepted; reliability(...,0.5)=1.
- Candidate identity reproduction: two-component maskedhaz model accepts
  columns x2=TRUE,x3=FALSE without x1 and evaluates x2 as component 1.
- Both release builds generated source archives and vignettes; as-cran
  dependency/incoming checks passed. Final checks still running at update.

### Completed dist.structure release check

R CMD check --as-cran: 0 errors, 0 warnings, 2 environment notes (current time
verification unavailable; no tidy HTML validator). Tests, examples, vignettes,
PDF manual passed. Archive: /tmp/dist-cran-0.5.1/dist.structure_0.5.1.tar.gz.
SHA-256: a1d85cf9a406fac438467a7369b05ff81a992831045e3cf5d770cb90d2338f54.
Full log: /tmp/dist-cran-0.5.1/dist.structure.Rcheck/00check.log.

Independent review of algebraic.mle/compositional.mle diffs found no new
release-blocking regressions. Extra non-diagonal covariance and unequal-point
estimate control and a vector delta-method transformation passed. Targeted
regression tests passed; the existing parallel solver test skipped because it
requires an installed v2.0 package. Log: /tmp/foundations-independent-review.log.

### Artifact refresh

The first flexhaz check also completed with 0 errors, 0 warnings and 2 notes
(time verification; missing tidy/V8 for HTML/math validation). A second exact
source artifact includes final generated documentation and all 53 validation
assertions: /tmp/flexhaz-final-0.5.3/flexhaz_0.5.3.tar.gz.
SHA-256: f45d1af438fe14a7525d4da9add36ec5c203cfc78a4cb69c766c7357a0bbf6be.
Its as-cran check is running with remote incoming disabled on this repeated
check, after remote checks passed on the initial build.

### Final validation and bounded stress-test limitation

Final flexhaz source archive check completed: 0 errors, 0 warnings, 2
environment notes as above. Full final log:
/tmp/flexhaz-final-0.5.3/flexhaz.Rcheck/00check.log.

The kofn full development suite was deliberately stopped after **15m56s wall
clock (9m14s CPU)** while running `exponential parallel MLE works for m=5`
(tests/testthat/test-stress.R:106). This was a review time limit, not an
optimizer-declared failure; the full suite is **incomplete**, not passing.
The ordinary test file had completed without failures. The slow stress case
uses n=300 and three starts, each with L-BFGS-B bounded at 100 iterations and
Nelder-Mead fallback bounded at 500. Measured here: one log-likelihood evaluation
~0.18s and a numDeriv gradient ~9s. Three 100-iteration gradient runs alone can
therefore take tens of minutes. This is nested numerical-differentiation and
combinatorial likelihood cost, with no evidence of an unbounded loop.
Preserved log: /tmp/reliability-kofn.log. Only that worker-owned R process was
terminated. Corrected README constructors were independently executed.

### Runnable deadline benchmark delivered

Directory: queelius.r-universe.dev/examples/deadline-benchmark/.
Base-R CLI: `Rscript run.R input.csv slo_seconds output.csv`.
Strict CSV schema: backend, seconds, outcome. Reports per-backend outcome counts,
fractions, and empirical deadline success lower/upper bounds, preserving timed-out
requests in denominators. No fitted tail or p95 claim. Unit tests cover
hand-calculated partial censoring, all-timeout data, explicit failures, exact
deadline boundaries, and malformed schemas/statuses/times. CLI integration tests
cover quoted backend labels, numeric-looking backend IDs, space-containing paths,
invalid deadlines, refusing input overwrite, and malformed extra CSV fields.
Both test scripts passed. analysis.R measured line coverage: 100% using covr as a
development measurement only; app and tests require only base R.
Coverage record: /tmp/deadline-app-coverage.log and .rds.
Synthetic output: /tmp/deadline-summary.csv.
