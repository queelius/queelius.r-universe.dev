#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) {
  stop("Usage: Rscript run.R input.csv slo_seconds output.csv", call. = FALSE)
}
script_arg <- commandArgs(trailingOnly = FALSE)
script_arg <- script_arg[startsWith(script_arg, "--file=")]
script_path <- substring(script_arg[[1L]], nchar("--file=") + 1L)
source(file.path(dirname(normalizePath(script_path)), "analysis.R"))
slo <- suppressWarnings(as.numeric(args[[2L]]))
# read.csv parses quoting/escaping; named column classes preserve backend labels.
data <- read.csv(args[[1L]], check.names = FALSE, stringsAsFactors = FALSE,
                 row.names = NULL,
                 colClasses = c(backend = "character", seconds = "numeric",
                                outcome = "character"))
result <- deadline_summary(data, slo)
input_path <- normalizePath(args[[1L]], mustWork = TRUE)
output_path <- file.path(normalizePath(dirname(args[[3L]]), mustWork = TRUE),
                         basename(args[[3L]]))
if (identical(input_path, output_path) ||
    (file.exists(output_path) && identical(input_path, normalizePath(output_path)))) {
  stop("Output must be a different file from the input.", call. = FALSE)
}
write.csv(result, output_path, row.names = FALSE)
cat(sprintf("Summarized %d requests across %d backends to %s\n",
            nrow(data), nrow(result), output_path))
