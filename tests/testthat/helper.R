#' Since you can't compare two `tbl_df` objects when they contain a list as a
#' column using expect_equal or all.equal
#'
#' @importFrom   tidyr         unnest
#'
expect_equal_listy_tbl <- function(object, expected, ...) {
  expect_equal(
    object = tidyr::unnest(object),
    expected = tidyr::unnest(expected),
    ...
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
