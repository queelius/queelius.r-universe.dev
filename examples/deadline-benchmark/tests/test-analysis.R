args <- commandArgs(trailingOnly = FALSE)
script <- sub("--file=", "", args[startsWith(args, "--file=")][1L], fixed = TRUE)
source(file.path(dirname(dirname(normalizePath(script))), "analysis.R"))

expect_error <- function(expression) {
  result <- tryCatch({ force(expression); NULL }, error = identity)
  stopifnot(inherits(result, "error"))
}

# At 2 seconds: two successes, one unknown, three known misses.
partial <- data.frame(
  backend = rep("alpha", 6),
  seconds = c(1, 2, 3, 1, 2, 0.5),
  outcome = c("completed", "completed", "completed", "timeout", "timeout", "failure")
)
r <- deadline_summary(partial, 2)
stopifnot(r$n_requests == 6L, r$n_completed == 3L, r$n_timeout == 2L,
          r$n_failure == 1L, r$n_slo_success == 2L, r$n_slo_unknown == 1L,
          r$n_slo_miss == 3L, r$slo_success_lower == 2/6,
          r$slo_success_upper == 3/6, r$timeout_fraction == 2/6,
          r$failure_fraction == 1/6)

# No completed requests: unknown outcomes must not disappear from denominators.
timeouts <- data.frame(backend = "beta", seconds = c(1, 2, 3), outcome = "timeout")
r <- deadline_summary(timeouts, 2)
stopifnot(r$n_completed == 0L, r$slo_success_lower == 0,
          r$slo_success_upper == 1/3, r$timeout_fraction == 1)
failures <- data.frame(backend = "gamma", seconds = c(0, 4), outcome = "failure")
r <- deadline_summary(failures, 2)
stopifnot(r$slo_success_lower == 0, r$slo_success_upper == 0,
          r$failure_fraction == 1)

combined <- deadline_summary(rbind(partial, timeouts, failures), 2)
stopifnot(identical(combined$backend, c("alpha", "beta", "gamma")),
          sum(combined$n_requests) == 11L)

# Completion at the deadline succeeds; timeout at the deadline is a known miss.
boundary <- data.frame(backend = "edge", seconds = c(0, 2, 2),
                       outcome = c("completed", "completed", "timeout"))
r <- deadline_summary(boundary, 2)
stopifnot(r$n_slo_success == 2L, r$n_slo_miss == 1L, r$n_slo_unknown == 0L)

expect_error(deadline_summary(partial[FALSE, ], 2))
expect_error(deadline_summary(partial[, c("backend", "seconds")], 2))
expect_error(deadline_summary(transform(partial, extra = 1), 2))
bad <- partial; names(bad)[3] <- "seconds"; expect_error(deadline_summary(bad, 2))
for (value in list(NA_real_, Inf, -1, "1")) {
  bad <- partial; bad$seconds <- rep(value, nrow(bad)); expect_error(deadline_summary(bad, 2))
}
for (value in c("", " ", NA_character_)) {
  bad <- partial; bad$backend[1] <- value; expect_error(deadline_summary(bad, 2))
}
for (value in c("cancelled", "Completed", NA_character_)) {
  bad <- partial; bad$outcome[1] <- value; expect_error(deadline_summary(bad, 2))
}
for (value in list(0, -1, Inf, NA_real_, "2", c(1, 2))) {
  expect_error(deadline_summary(partial, value))
}
for (column in c("backend", "outcome")) {
  bad <- partial
  bad[[column]] <- I(matrix(bad[[column]], ncol = 1L))
  expect_error(deadline_summary(bad, 2))
}
cat("All deadline analysis tests passed.\n")
