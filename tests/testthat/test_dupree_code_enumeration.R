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

test_that("Number of code blocks in imported files", {
  # For empty files, an empty data-frame should be returned by
  # `import_parsed_code_blocks`

  # Empty .R files
  # - No content
  empty_file <- file.path("empty.R")
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
  comment_file <- file.path("comments.R")
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
  # Empty .Rmd files
  # - No content
  # - Only header
  # - Only text
  # - Some non-R blocks
})
