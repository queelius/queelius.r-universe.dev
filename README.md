# Statistical tools for incomplete observations

Build explicit likelihoods from exact measurements, timeouts, histogram bins,
and partially observed failures. This registry distributes Alexander Richard
Towell's R packages through [R-universe](https://queelius.r-universe.dev/).
Thirteen packages are also on CRAN (verified 2026-10-28).

## Start with a question

**Does this service or AI backend meet a latency target?** Try the
[Deadline benchmark app](examples/deadline-benchmark/README.md): feed it a CSV
of completed requests, timeouts and failures to obtain per-backend SLO bounds.
It uses base R and includes synthetic data and tests. For custom parametric
models and counted telemetry bins, start with
[likelihood.contr](https://github.com/queelius/likelihood.contr) and its
[timeout benchmarking walkthrough](https://github.com/queelius/likelihood.contr/blob/master/vignettes/timeout-benchmarking.Rmd).
Completed requests, right-censored timeouts, and counted histogram bins can
contribute to the same model. Report observed deadline success separately from
model-dependent p95 extrapolation. The example uses synthetic data and is not
a provider ranking. Counted bins and the demo are new in version 0.2.0.

**Which components determine system reliability?** Start with
[dist.structure](https://github.com/queelius/dist.structure) for topology and
simulation, then [maskedcauses](https://github.com/queelius/maskedcauses) or
[kofn](https://github.com/queelius/kofn) for inference from incomplete system data.
Use [flexhaz](https://github.com/queelius/flexhaz) when you need to specify a
custom time-varying hazard.

**How does uncertainty change under a transformation?** Start with
[algebraic.mle](https://github.com/queelius/algebraic.mle) for pooling and
propagating estimates, or [nabla](https://github.com/queelius/nabla) for
higher derivatives of supported scalar R expressions.

For standard survival analysis, consider `survival`; for standard parametric
censored fitting, consider `fitdistrplus` or `flexsurv`. This ecosystem is useful
when observation mechanisms, distributions, or system structures must compose.

## Install

```r
# Stable CRAN release
install.packages("likelihood.contr")

# R-universe builds, including development versions when available
install.packages("likelihood.contr", repos = c(
  "https://queelius.r-universe.dev", "https://cloud.r-project.org"))

# Requires likelihood.contr >= 0.2.0
demo("timeout-benchmark", package = "likelihood.contr")
```

Development examples require the corresponding version to have reached the
repository; CRAN and R-universe builds can lag source changes.

## Package inventory

The inventory below is generated from `packages.json` and each package's
`DESCRIPTION`, using `Rscript tools/refresh-inventory.R` from this directory.
Versions are source versions, not promises of CRAN availability.

<!-- inventory:start -->
| Package | Source version | Purpose |
|---|---|---|
| [algebraic.dist](https://github.com/queelius/algebraic.dist) | 1.0.0 | Algebra over Probability Distributions |
| [algebraic.mle](https://github.com/queelius/algebraic.mle) | 2.0.3 | Algebraic Maximum Likelihood Estimators |
| [compositional.mle](https://github.com/queelius/compositional.mle) | 2.0.1 | Compositional Maximum Likelihood Estimation |
| [dist.structure](https://github.com/queelius/dist.structure) | 0.5.1 | Structured Random Variables for Reliability System Distributions |
| [femtograd](https://github.com/queelius/femtograd) | 0.3.1 | Automatic Differentiation for Statistical Computing |
| [flexhaz](https://github.com/queelius/flexhaz) | 0.5.3 | Dynamic Failure Rate Distributions for Survival Analysis |
| [hypothesize](https://github.com/queelius/hypothesize) | 1.0.0 | Consistent API for Hypothesis Testing |
| [kofn](https://github.com/queelius/kofn) | 0.4.0 | Maximum Likelihood Estimation for k-Out-of-n System Data |
| [likelihood.contr](https://github.com/queelius/likelihood.contr) | 0.2.0 | Likelihood Contribution Models for Heterogeneous Observation Types |
| [likelihood.model](https://github.com/queelius/likelihood.model) | 1.0.2 | Likelihood-Based Statistical Inference in the Fisherian Tradition |
| [maskedcauses](https://github.com/queelius/maskedcauses) | 0.10.0 | Likelihood Models for Systems with Masked Component Cause of Failure |
| [maskedhaz](https://github.com/queelius/maskedhaz) | 0.1.0 | Masked-Cause Likelihood Models for Series Systems with Arbitrary Hazard Components |
| [nabla](https://github.com/queelius/nabla) | 0.7.2 | Exact Derivatives via Automatic Differentiation |
| [serieshaz](https://github.com/queelius/serieshaz) | 0.2.0 | Series System Distributions from Dynamic Failure Rate Components |
<!-- inventory:end -->

## Review and development

The [2026-10-28 ecosystem review](reviews/2026-10-28/review.md) records priorities,
confirmed defects, changes, remaining limitations, tests and release evidence.
`femtograd` remains an educational reverse-mode AD library; its optimizer and
clipping edge cases need work before it is a release priority.

To register a package, add its package name and canonical repository URL to
`packages.json`. Build and distribution are managed by R-universe. Keep source,
issues, tests and releases in each owning repository.
