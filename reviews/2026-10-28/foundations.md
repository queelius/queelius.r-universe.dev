# Foundation ecosystem review , 2026-10-28

Scope: algebraic.dist, algebraic.mle, likelihood.model, compositional.mle,
likelihood.contr, hypothesize. Local source review and executable tests, not
a novelty assessment or independent statistical validation of every method.

## Architecture and positioning

The dependency spine is algebraic.dist -> algebraic.mle -> likelihood.model
-> likelihood.contr. compositional.mle also depends on algebraic.mle and offers
an optional bridge to likelihood.model. hypothesize is a standalone, stats-only
hypothesis-test abstraction. These are useful separations internally, but users
currently encounter abstractions before a concrete outcome.

Strongest application candidate: infer latency/completion distributions from
service or AI-agent benchmark runs whose timeouts are right-censored rather
than discarding them or treating timeout thresholds as completed runtimes.
likelihood.contr is already the natural engine for this, including exact,
right-, left-, and interval-censored observations and custom likelihood pieces.
This is a proposal grounded in the code, not evidence of market demand.

Recommended adoption path: executable timeout-aware benchmark vignette and
small validated public API in likelihood.contr, with assumptions made explicit;
compare against analytical and standard survival-model controls. Avoid another
thin wrapper package until there is a distinct reusable API and users.

Second application: pooled independent experiment estimates with transformed
decision quantities, using algebraic.mle combine()/rmap(). Its utility depends
on correctly preserving parameter identity; this review found failures there.

Distribution algebra and optimizer combinators remain supporting libraries.
Do not pitch a general inference framework as a replacement for well-established
model-fitting tools without comparisons and a concrete feature advantage.

## Confirmed correctness findings

1. **P1: algebraic.mle combine silently pools different named parameters.**
   R/combine.R previously added information and estimates by position only.
   `combine(mle(c(a=1,b=10),sigma=diag(2)),
   mle(c(b=10,a=1),sigma=diag(2)))` returned a=b=5.5.
   Fixed here: align estimates and both information-matrix axes by unique
   parameter names; reject incompatible/mixed/ambiguous names; retain positional
   behavior when every estimate is unnamed. Regression includes unequal,
   correlated covariance, direct-information and covariance-fallback paths.

2. **P1: likelihood.model invents positivity constraints during profiling.**
   R/core-fisherian.R lines 164-172 infer a nuisance parameter's domain from
   whether its fitted value is positive. An unrestricted mean/slope must be
   allowed to cross zero. This also makes likelihood_interval inconsistent
   with profile_loglik. Reproduction:

   ```r
   loglik.correlated <- function(model, ...)
     function(df,par,...) -0.5*((par[1]-1)^2+(par[2]-par[1])^2)
   model <- structure(list(),class=c('correlated','likelihood_model'))
   f <- fisher_mle(c(a=1,b=1),vcov=matrix(c(1,1,1,2),2),loglik_val=0)
   likelihood_interval(f,data=data.frame(x=0),model=model,param='a')
   # actual [-0.852533, 3.039334]
   # correct 1 +/- sqrt(2*log(8)) = [-1.039334, 3.039334]
   ```

   Sent to primary agent for separate correction. Domain constraints should
   come from an explicit model/parameter specification, never estimate signs.

3. **P1: compositional.mle loses failed solver slots.**
   `results[[i]] <- NULL` deletes the list entry. with_restarts then reads a
   possibly nonexistent index, so a failed final attempt throws instead of
   returning a successful earlier fit. Sequential race also loses metadata
   alignment. Fixed by assigning `results[i] <- list(result)` to retain NULL
   slots. Regression covers failed first/last attempts and all-failure behavior.

4. **P2: algebraic.mle rmap drops transformation arguments.**
   R/mle_rmap.R final `g(theta)` omitted `...` although covariance used it.
   `rmap(f, function(theta,scale)theta*scale, scale=2, method='delta')`
   errored; defaults could silently produce a wrong point estimate.
   Fixed `g(theta, ...)`, with tests for both delta and Monte Carlo methods.

5. **Validation gaps in likelihood.contr.**
   Observation-type callbacks promise a character vector of nrow(df) but
   R/cache.R does not validate type/length; split() can recycle. Duplicate
   contribution names are accepted and lookup by name chooses the first.
   Reported to primary agent owning likelihood.contr work.

## Testing and coverage

All initial suites completed successfully. compositional.mle's parallel race
test is intentionally skipped under devtools::test because subprocesses use an
installed package. likelihood.model has a substantial tests/test.R run by
R CMD check, but devtools::test reports no infrastructure and runs nothing;
explicitly loading local source then sourcing tests/test.R passes. Move that
script to tests/testthat or document the correct local command to prevent a
false impression of testing.

Initial covr::package_coverage results:

| Package | Coverage | Main uncovered files |
|---|---:|---|
| algebraic.dist | 95.89% | empirical_dist, edist, dist, realized_dist |
| algebraic.mle | 95.22% | combine, mle_boot, mle |
| likelihood.contr | 100% | None at line level |
| hypothesize | 100% | None at line level |
| likelihood.model | 98.53% | core-fisherian, core-fisher_mle |
| compositional.mle | 85.84% | verbose, trace, compose, plot |

Near-perfect line coverage did not catch parameter-identity, profiling-domain,
or failed-attempt bugs. Add invariant tests (parameter reorder invariance,
agreement of profile values with interval endpoints, failed-attempt placement
invariance), not tests that mirror implementation branches.

## Release and existing work

All six repositories already contain CRAN-SUBMISSION records from March 2026.
These are evidence of prior submission, not acceptance. algebraic.dist,
algebraic.mle, compositional.mle and likelihood.contr had modified tracked
CRAN-SUBMISSION files before this work; likelihood.model/hypothesize records
were untracked. Those records were preserved.

algebraic.mle 2.0.3 and compositional.mle 2.0.1 are prepared locally with NEWS
and regression tests. No commit, push, or CRAN submission was made by this agent.
Current cran-comments in both repos describe old coordinated submissions;
rewrite them with fresh check results before submitting.

Other preexisting untracked files were preserved, including contribution docs,
HTML readmes, likelihood.model paper output/design notes and hypothesize audit
artifacts. algebraic.mle/AGENTS.md incorrectly says there is no tests directory;
the package now has a substantial testthat suite.

Check results and final coverage will be added after completion below.

## Changes verified so far

Both edited packages pass their full devtools::test suites, including new
regressions and existing integration tests. The compositional.mle parallel race
test skips under devtools as noted above. Final algebraic.mle line coverage is
95.51%. Its stale AGENTS.md testing instructions have also been corrected.
Both git diffs pass `git diff --check`. Source builds/checks remain in progress.
