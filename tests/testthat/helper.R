#' Since you can't compare two `tbl_df` objects when they contain a list as a
#' column using expect_equal or all.equal
#'
expect_equal_tbl <- function(object, expected, ..., info = NULL) {
  act <- testthat::quasi_label(rlang::enquo(object), arg = "object")
  exp <- testthat::quasi_label(rlang::enquo(expected), arg = "expected")

  # all.equal.list is slightly problematic: it returns TRUE for match, and
  # returns a character vector when differences are observed. We extract
  # both a match-indicator and a failure message

  diffs <- all.equal.list(object, expected, ...)
  has_diff <- if (is.logical(diffs)) diffs else FALSE
  diff_msg <- paste(diffs, collapse = "\n")

  testthat::expect(
    has_diff,
    failure_message = sprintf(
      "%s not equal to %s.\n%s", act$lab, exp$lab, diff_msg
    ),
    info = info
  )

  invisible(act$val)
}

expect_equivalent_tbl <- function(object, expected, ..., info = NULL) {
  expect_equal_tbl(
    object, expected, ..., check.attributes = FALSE, info = info
  )
}

get_empty_dups_tbl <- function() {
  tibble::tibble(
    file_a = character(0),
    file_b = character(0),
    block_a = integer(0),
    block_b = integer(0),
    line_a = integer(0),
    line_b = integer(0),
    score = numeric(0)
  )
}

get_empty_dups_df <- function() {
  as.data.frame(get_empty_dups_tbl(), stringsAsFactors = FALSE)
}

###############################################################################
