###############################################################################

context("Tests for classes in `dupree` package")

###############################################################################

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

###############################################################################

test_that("EnumeratedCodeTable: find_best_match_for_single_block", {
  # TODO:
})

test_that("EnumeratedCodeTable: find_best_matches", {
  # TODO:
  # - return at most 1 best-hit for each block

  empty_results <- tibble::tibble(
    file_a = character(0), file_b = character(0), block_a = integer(0),
    block_b = integer(0), line_a = integer(0), line_b = integer(0),
    score = numeric(0)
  )

  # No overlap between the symbols in the two code-blocks
  my_blocks <- tibble::tibble(
    file = "a", block = 1:2, start_line = 1:2,
    enumerated_code = list(1:3, 4L)
  )
  my_code_table <- new("EnumeratedCodeTable", my_blocks)

  expect_equal(
    find_best_matches(my_code_table),
    tibble::tibble(
      file_a = "a", file_b = "a", block_a = 1:2, block_b = 2:1,
      line_a = 1:2, line_b = 2:1, score = 0
    ),
    info = "find_best_matches on two distinct code-blocks (same file)"
  )

  # Identical code-blocks
  identical_blocks <- tibble::tibble(
    file = "a", block = 1:2, start_line = 1:2,
    enumerated_code = list(1:3, 1:3)
  )
  identical_code_table <- new("EnumeratedCodeTable", identical_blocks)
  expect_equal(
    find_best_matches(identical_code_table),
    tibble::tibble(
      file_a = "a", file_b = "a", block_a = 1:2, block_b = 2:1,
      line_a = 1:2, line_b = 2:1, score = 1
    ),
    info = "find_best_matches on two identical code-blocks (same file)"
  )

  # Overlapping, non-equal code-blocks, using longest-common-subsequence
  nonequal_blocks <- tibble::tibble(
    file = letters[1:2], block = 1L, start_line = 1L,
    enumerated_code = list(1:4, 3:6)
    # seq_dist_LCS = 4; length_sum = 8; seq_sim = 1 - dist/len_sum = 0.5
  )
  nonequal_code_table <- new("EnumeratedCodeTable", nonequal_blocks)
  expect_equal(
    find_best_matches(nonequal_code_table),
    tibble::tibble(
      file_a = c("a", "b"), file_b = c("b", "a"), block_a = 1L, block_b = 1L,
      line_a = 1L, line_b = 1L, score = 1 / 2
    ),
    info = "find_best_matches on non-equal code-blocks (LCS; different file)"
  )

  # - if there's 1 or fewer blocks, return an empty data-frame
  single_block <- tibble::tibble(
    file = "a", block = 1L, start_line = 1L, enumerated_code = list(1:4)
  )
  single_code_table <- new("EnumeratedCodeTable", single_block)
  expect_equal(
    find_best_matches(single_code_table),
    empty_results,
    info = paste(
      "A single code-block can't be compared to anything: results should be",
      "empty"
    )
  )
})
