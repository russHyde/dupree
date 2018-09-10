###############################################################################

context("Tests for classes in `dupree` package")

###############################################################################

#' Since you can't compare two `tbl_df` objects when they contain a list as a
#' column using expect_equal or all.equal
expect_equal_listy_tbl <- function(object, expected, ...) {
  expect_equal(
    object = tidyr::unnest(object),
    expected = tidyr::unnest(expected),
    ...
  )
}

###############################################################################

test_that("EnumeratedCodeTable: construction / validity", {
  expect_is(
    new("EnumeratedCodeTable"),
    "EnumeratedCodeTable",
    info = "Constructor for EnumeratedCodeTable"
  )

  expect_error(
    new("EnumeratedCodeTable", blocks = tibble()),
    info = paste(
      "EnumeratedCodeTable should have `file`, `block`, `start_line` and",
      "`enumerated_code columns`"
    )
  )

  default_blocks <- tibble::tibble(
    file = character(0), block = integer(0), start_line = integer(0),
    enumerated_code = list()
  )

  expect_equal_listy_tbl(
    new("EnumeratedCodeTable")@blocks,
    default_blocks,
    info = paste(
      "Default 'blocks' entry should have no rows, and have",
      "file|block|start_line|enumerated_code columns"
    )
  )

  my_blocks <- tibble::tibble(
    file = "a", block = 1, start_line = 1, enumerated_code = list(1:5)
  )

  expect_equal_listy_tbl(
    new("EnumeratedCodeTable", my_blocks)@blocks,
    my_blocks,
    info = paste(
      "'blocks' entry should match the defining data-frame"
    )
  )

})
