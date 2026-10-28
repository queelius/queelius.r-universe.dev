args <- commandArgs(trailingOnly = FALSE)
script <- substring(args[startsWith(args, "--file=")][1L], nchar("--file=") + 1L)
app <- dirname(dirname(normalizePath(script)))
workspace <- tempfile("deadline-cli-")
dir.create(workspace)
input <- file.path(workspace, "input with spaces.csv")
output <- file.path(workspace, "output with spaces.csv")
runner <- function(input, slo, output) {
  status <- system2(file.path(R.home("bin"), "Rscript"),
                   shQuote(c(file.path(app, "run.R"), input, slo, output)),
                   stdout = file.path(workspace, "stdout"),
                   stderr = file.path(workspace, "stderr"))
  status
}
write.csv(data.frame(backend = c("001", "provider,west"), seconds = c(1, 1),
                     outcome = c("completed", "timeout")), input, row.names = FALSE)
stopifnot(runner(input, "2", output) == 0L)
r <- read.csv(output, colClasses = c(backend = "character"))
stopifnot(identical(r$backend, c("001", "provider,west")),
          identical(r$slo_success_lower, c(1L, 0L)),
          identical(r$slo_success_upper, c(1L, 1L)))
stopifnot(runner(input, "bad", output) != 0L)
stopifnot(runner(input, "2", input) != 0L)
# A fourth field cannot silently become row names and evade schema validation.
writeLines(c("backend,seconds,outcome", "extra,alpha,1,completed"), input)
stopifnot(runner(input, "2", output) != 0L)
unlink(workspace, recursive = TRUE)
cat("All deadline CLI integration tests passed.\n")
