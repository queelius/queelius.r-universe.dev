# Ecosystem improvement plan, 2026-10-28

Goal: make the existing R ecosystem trustworthy and approachable through a concrete timeout-aware benchmark workflow.

Design choice: strengthen likelihood.contr rather than create another foundational package. Keep domain assumptions explicit. Counted telemetry bins become frequency-weighted existing contribution objects; no distribution-name lookup tables or observation expansion. Supply a runnable example comparing naive completed-only estimates with censored estimates and warn that model extrapolation beyond deadlines is assumption-dependent. Existing survival/fitdistrplus remain appropriate alternatives for standard survival analysis; differentiation and custom contributions are this ecosystem's specialty.

Tasks:
1. Reproduce and fix algebraic.mle parameter-name pooling and rmap forwarding; nabla polynomial derivative and cummax issues; flexhaz invalid-censoring silent loss. Add regressions and run full suites and coverage.
2. Add contr_freq(contribution, count_col) to likelihood.contr. Validate counts as finite nonnegative integer frequencies; zero counts contribute zero. Preserve analytical score/Hessian if present. Test equality with independently expanded records for values and derivatives, invalid inputs and zero-only data. Add benchmark vignette/demo and CRAN-first onboarding.
3. Fix likelihood.model profile nuisance constraints with explicit bounds, regression against a correlated quadratic, and existing test script.
4. Update registry README as the task-oriented ecosystem entry point; derive inventory/dependency/release evidence from DESCRIPTION/CRAN metadata, record review findings and evidence.
5. Check changed packages with --as-cran and downstream integration where relevant. Submit appropriate tested patch releases, record exact files and upload outcomes; distinguish upload, email confirmation and acceptance. Do not republish existing unchanged releases.
