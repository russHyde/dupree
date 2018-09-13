###############################################################################

context("Tests for code import and code-symbol enumeration in `dupree`")

###############################################################################

test_that("get_localised_parsed_code_blocks", {
  expect_equal(
    object = nrow(.get_default_annotated_parsed_content()),
    expected = 0,
    info = "Default annotated-parsed-content has no rows"
  )
  expect_equal(
    object = nrow(get_localised_parsed_code_blocks(list())),
    expected = 0,
    info = paste(
      "An empty list of source-expressions should return a",
      "data-frame of 0 rows"
    )
  )
})

###############################################################################

test_that("Number of code blocks in imported files", {
  # For empty files, an empty data-frame should be returned by
  # `import_parsed_code_blocks`

  # Empty .R files
  # - No content
  empty_file <- file.path("testdata", "empty.R")
  expect_true(
    file.exists(empty_file),
    info = "Just checking the test-files exist"
  )
  expect_true(
    nrow(import_parsed_code_blocks(empty_file)) == 0,
    info = "empty .R file should provide no code-blocks: import function"
  )
  expect_true(
    nrow(preprocess_code_blocks(empty_file)@blocks) == 0,
    info = "empty .R file should provide no code-blocks: preprocess workflow"
  )
  # - Only comments
  comment_file <- file.path("testdata", "comments.R")
  expect_true(
    nrow(import_parsed_code_blocks(comment_file)) == 0,
    info = paste(
      "comment-only .R file should provide no code-blocks: import function"
    )
  )
  expect_true(
    nrow(preprocess_code_blocks(comment_file)@blocks) == 0,
    info = paste(
      "comment-only .R file should provide no code-blocks: preprocess workflow"
    )
  )
  # Empty .Rmd files:
  # - No content
  empty_rmd <- file.path("testdata", "empty.Rmd")
  expect_true(
    nrow(import_parsed_code_blocks(empty_rmd)) == 0,
    info = "empty .Rmd file should import no code-blocks"
  )
  # - Only header
  header_rmd <- file.path("testdata", "header_only.Rmd")
  expect_true(
    nrow(import_parsed_code_blocks(header_rmd)) == 0,
    info = "header-only .Rmd file should import no code-blocks"
  )
  # - Only text
  text_rmd <- file.path("testdata", "text_only.Rmd")
  expect_true(
    nrow(import_parsed_code_blocks(text_rmd)) == 0,
    info = "text-only .Rmd file should import no code-blocks"
  )

  # - Some non-R blocks
  skip(
    # All subsequent tests in this `test_that` block will not be ran
    paste(
      "`dupree` is not yet implemented for R-markdown files that contain",
      "non-R code blocks"
    )
  )
  non_r_rmd <- file.path("testdata", "non_r_blocks.Rmd")
  expect_true(
    nrow(import_parsed_code_blocks(non_r_rmd)) == 0,
    info = ".Rmd with only non-R blocks should import not code-blocks"
  )
})

###############################################################################

test_that("Filtering by the number of symbols in the code-blocks", {

  # If there is less than `N` symbols in each input code-block, and
  # `min_block_size` is `N` then every code-block will be disregarded
  max_9_symbols <- file.path("testdata", "max_9_symbols.R")
  expect_equal(
    nrow(preprocess_code_blocks(max_9_symbols, min_block_size = 10)@blocks),
    0,
    info = paste(
      "If there's less than 10 symbols per code-block, no blocks should",
      "return on preprocessing with min_block_size = 10"
    )
  )
  expect_equal(
    nrow(preprocess_code_blocks(max_9_symbols, min_block_size = 1)@blocks),
    5,
    info = paste(
      "A file with 5 code-blocks, keeping blocks with >= 1 non-trivial symbol"
    )
  )
})
