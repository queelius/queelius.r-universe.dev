# Summarize observed deadline outcomes without extrapolating beyond timeouts.
# These are bounds on the observed sample, not population confidence intervals.
deadline_summary <- function(data, slo_seconds) {
  columns <- c("backend", "seconds", "outcome")
  outcomes <- c("completed", "timeout", "failure")
  if (!is.data.frame(data) || anyDuplicated(names(data)) ||
      !setequal(names(data), columns) || nrow(data) == 0L) {
    stop("Input must be a non-empty data frame with exactly backend, seconds, outcome columns.",
         call. = FALSE)
  }
  if (!is.numeric(slo_seconds) || is.complex(slo_seconds) ||
      length(slo_seconds) != 1L || !is.finite(slo_seconds) || slo_seconds <= 0) {
    stop("slo_seconds must be one finite positive number.", call. = FALSE)
  }
  if (!is.character(data$backend) || !is.null(dim(data$backend)) ||
      anyNA(data$backend) ||
      any(!nzchar(trimws(data$backend)))) {
    stop("backend must contain non-empty, non-missing names.", call. = FALSE)
  }
  if (!is.numeric(data$seconds) || is.complex(data$seconds) ||
      !is.null(dim(data$seconds)) || any(!is.finite(data$seconds)) ||
      any(data$seconds < 0)) {
    stop("seconds must contain finite, non-negative numbers.", call. = FALSE)
  }
  if (!is.character(data$outcome) || !is.null(dim(data$outcome)) ||
      anyNA(data$outcome) ||
      any(!data$outcome %in% outcomes)) {
    stop("outcome must be completed, timeout, or failure (no missing values).",
         call. = FALSE)
  }
  data$outcome <- factor(data$outcome, levels = outcomes)
  groups <- split(data, data$backend, drop = TRUE)
  result <- lapply(groups, function(group) {
    n <- nrow(group)
    counts <- table(group$outcome)
    success <- sum(group$outcome == "completed" & group$seconds <= slo_seconds)
    unknown <- sum(group$outcome == "timeout" & group$seconds < slo_seconds)
    data.frame(
      backend = group$backend[[1L]],
      n_requests = n,
      n_completed = unname(counts[["completed"]]),
      n_timeout = unname(counts[["timeout"]]),
      n_failure = unname(counts[["failure"]]),
      timeout_fraction = unname(counts[["timeout"]]) / n,
      failure_fraction = unname(counts[["failure"]]) / n,
      slo_seconds = slo_seconds,
      n_slo_success = success,
      n_slo_unknown = unknown,
      n_slo_miss = n - success - unknown,
      slo_success_lower = success / n,
      slo_success_upper = (success + unknown) / n,
      stringsAsFactors = FALSE
    )
  })
  result <- do.call(rbind, result)
  rownames(result) <- NULL
  result
}
