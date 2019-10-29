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
