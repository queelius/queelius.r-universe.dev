# Validation evidence, 2026-10-28

The [release manifest](releases.json) is the source of truth for exact source
commits, archive hashes, local checks and submission state. Archive/check-log
copies are retained locally in `rlang/release-artifacts/2026-10-28/`.

All seven finalized archives (algebraic.mle, compositional.mle, dist.structure,
flexhaz, nabla, likelihood.contr and likelihood.model) passed `R CMD check --as-cran`: zero errors,
zero warnings and two environment notes each (time verification; missing
HTML/math validation tooling). Examples, package tests, vignettes and manuals
were included. likelihood.model's initial archive was superseded by the constrained-domain
fix. Its final archive passed, with 22 analytical regression assertions and
98.88% coverage. All seven current source revisions also passed R-devel
--no-manual --as-cran with Status: OK; see r-devel.json.

Remote incoming checks ran on initial source builds. Final repeats for flexhaz
and likelihood.contr disabled remote incoming checks after their initial
passes. No test failures or warnings are hidden by those switches.

Coverage is recorded in [coverage.csv](coverage.csv); blank means not measured
in this review. In particular, old coverage claims are not substituted for
fresh measurements. New likelihood.contr code achieved 100% measured line
coverage; mathematical controls and validation cases are still necessary.

The seven package versions were installed together in a separate R library.
Integration checked parameter-reordering invariance, polynomial derivatives at
zero and the entire timeout/histogram example against the upgraded dependencies.
The test log ends `COHORT INTEGRATION PASSED`. The final profile-domain patch passed its expanded regressions and package checks.

The standalone deadline application passed unit and subprocess CLI tests plus
an independent review using 200 latent-completion controls. Its analysis code
had 100% measured line coverage. The sample results are recorded in
`examples/deadline-benchmark/expected-summary.csv`. Bounds are observed-sample
bounds, not confidence intervals or forecasts.

All fourteen packages received source review. The full kofn baseline suite was
stopped at 15m56s in `test-stress.R`, 'exponential parallel MLE works for m=5'.
Its bounded optimization takes roughly nine seconds per numerical gradient in
this environment. That full stress suite is incomplete. Kofn changed only its
README; replacement constructors and targeted integration checks passed.

Independent reviews found and corrected additional profile-scaling issues and
confirmed the pooling, failed-attempt, distribution-support, observation-schema,
and autodiff fixes. These are AI-assisted code reviews and finite checks, not
independent human statistical review or proof of general numerical correctness.
