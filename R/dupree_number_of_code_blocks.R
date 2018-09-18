###############################################################################

# Borrowed from `lintr`
# Remove this file when CRAN-lintr is updated beyond v1.0.2

###############################################################################

# `extract_r_source` is used to pull out blocks of R code from an R-markdown
# script. `dupree` uses calls to `lintr` to do this. But, the current version
# of `lintr` that is on CRAN contains a bug (that has been fixed in the dev
# version of `lintr` but has not been passed to CRAN yet: Sept 2018) such that
# files that do not contain any code blocks are considered to be malformed.
#
# We copied this code into here so that we can determine how many code-blocks
# are present in an R-markdown / R script before we parse the code-blocks out
# of those files

###############################################################################

"%:::%" <- function(p, f) {
  get(f, envir = asNamespace(p))
}

count_code_blocks <- function(filename) {
  lines <- readLines(filename)

  pattern <- get_knitr_pattern(filename, lines)
  if (is.null(pattern$chunk.begin) || is.null(pattern$chunk.end)) {
    return(0)
  }

  starts <- grep(pattern$chunk.begin, lines, perl = TRUE)
  ends <- grep(pattern$chunk.end, lines, perl = TRUE)

  if (length(starts) != length(ends)) {
    stop("Malformed file!", call. = FALSE)
  }

  length(starts)
}

get_knitr_pattern <- function(filename, lines) {
  pattern <- (
    "knitr" %:::% "detect_pattern"
  )(
    lines, tolower(tools::file_ext(filename))
  )
  if (!is.null(pattern)) {
    knitr::all_patterns[[pattern]]
  } else {
    NULL
  }
}
