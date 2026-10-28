# Independent review of likelihood contribution and profile changes

Reviewed 2026-10-28. This is AI code/mathematical review plus finite regression checks, not human review or a proof of general numerical reliability.

## Release-blocking finding, corrected

Removing inferred positivity from likelihood_interval() is mathematically necessary, but originally introduced a scale regression: BFGS used absolute finite-difference steps of 0.001 on positive nuisance scales. For normal data `x = 0.0005 * c(-2,-1,0,1,2)`, profiling the mean returned NA/NA after the change; the previous log-reparameterized implementation returned approximately +/-0.0008049. Normal data on a 1e-6 scale also failed. Absolute root tolerance 1e-5 was larger than the target interval.

With explicit authorization, the reviewer changed only likelihood.model/R/core-fisherian.R and tests/regression-profile-domain.R:

- Both profile paths now use finite positive nuisance standard errors as optim() parscale; otherwise they use the nonzero estimate magnitude, or one. This sets numerical scale and imposes no sign/domain constraint.
- Interval root tolerance is scaled by the parameter standard error, with the same fallback rule.
- Added the analytic normal profile interval control `sqrt(mean(x^2) * (k^(2/n) - 1))` at scales 1, 1e-3 and 1e-6, plus profile support checks and missing nuisance-SE fallback checks.

Validation: the initial expanded regression failed as expected; final regression passes 11 assertions (2 pre-existing new sign-domain assertions plus 9 scale/fallback assertions). The complete existing likelihood.model tests/test.R passes after the change. Logs: /tmp/profile-domain-scale-regression.log and /tmp/profile-domain-scale-validation.log. Root should rebuild/check the package from these updated sources; earlier tarballs omit this fix. The reviewer implemented this correction, so the final correction itself has regression evidence but is not independent review by a second author.

## likelihood.contr assessment

No release-blocking issue found in contr_freq(), its tests, the timeout vignette/demo, or the observation-schema fixes reviewed.

- Frequency likelihood, score, and Hessian scale each additive row contribution by its observed count. Zero-count rows are not evaluated, avoiding 0 * (-Inf). Integer, finite, nonnegative counts are validated.
- Histogram bin probability calculations correspond to multinomial likelihood up to a parameter-independent combinatorial constant, given fixed disjoint bins and the stated sampling assumptions.
- Timeout demonstration uses synthetic data and correctly distinguishes completion time censoring from errors/refusals, conditional completed-only quantiles from unconditional latency, and model-dependent extrapolation from measured tail performance. The exponential MLE is checked against the independent closed form `completed / total_exposure`.
- Vignette and now contr_freq() help explicitly warn that default nobs/BIC and row bootstrap in the generic fitting layer are not suitable for frequency data. Counts must supply sample size and resampling must follow the sampling design. The examples use direct likelihood optimization accordingly.
- New callback validation enforces one character observation label per row, eliminating silent recycling. Data-frame validation and unique/nonmissing contribution names are appropriate. Column-based factor labels remain accepted and tested.
- Claims are appropriately scoped: no provider ranking, causal inference, empirical performance claim, or assertion that latency is exponential in general.

Remaining limitations (documented or pre-existing): local optimization need not find a global profile maximum; model parameter transformations/bounds are not a general typed domain API; frequency-aware nobs/bootstrap remain an explicitly documented future integration rather than implemented functionality. These do not invalidate the additive frequency wrapper or its explicitly bounded examples.
