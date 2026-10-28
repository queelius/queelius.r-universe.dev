# Run from the registry checkout, with package repositories beside it.
registry <- jsonlite::fromJSON("packages.json")
rows <- lapply(seq_len(nrow(registry)), function(i) {
  d <- read.dcf(file.path("..", registry$package[i], "DESCRIPTION"))
  stopifnot(identical(unname(d[1, "Package"]), registry$package[i]))
  data.frame(package = d[1, "Package"], version = d[1, "Version"],
             title = d[1, "Title"], url = registry$url[i])
})
inventory <- do.call(rbind, rows)
inventory <- inventory[order(inventory$package), ]
lines <- c("| Package | Source version | Purpose |", "|---|---|---|",
  vapply(seq_len(nrow(inventory)), function(i) {
    x <- inventory[i, ]
    sprintf("| [%s](%s) | %s | %s |", x$package, x$url, x$version,
            paste(strsplit(x$title, "\n", fixed = TRUE)[[1]], collapse = " "))
  }, character(1)))
readme <- readLines("README.md")
start <- match("<!-- inventory:start -->", readme)
end <- match("<!-- inventory:end -->", readme)
stopifnot(!is.na(start), !is.na(end), start < end)
writeLines(c(readme[seq_len(start)], lines, readme[end:length(readme)]), "README.md")
