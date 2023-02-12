#!/usr/bin/env Rscript

# Script for running lintr::lint() against all provided files
#
# This loads the development package prior to calling {lintr}, this prevents any
# spurious "object-usage" lints.

pkgload::load_all()

filenames <- strsplit(commandArgs(trailingOnly = TRUE), " ")

output <- unlist(filenames) |>
  lapply(lintr::lint) |>
  purrr::compact()

if (length(output) > 0) {
  print(output)
  stop("Files not lint free")
}
