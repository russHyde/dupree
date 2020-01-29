context("Integration tests for `dupree_dir()`")

test_that("All .R files in subdirs are assessed by dupree_dir()", {
  # the test-package "anRpackage" contains
  # - ./R/anRpackage-internal.R
  # - and ./inst/dir1/R/dont_dup_me.R
  # - both of these files should be included by `dupree_dir()`
  package <- file.path("testdata", "anRpackage")
  r_content <- c(
    file.path("R", "anRpackage-internal.R"),
    file.path("inst", "dir1", "R", "dont_dup_me.R")
  )
  expect_silent(
    dupree_dir(package)
  )

  dups <- as.data.frame(dupree_dir(package))
  observed_files <- unique(c(dups$file_a, dups$file_b))
  expected_files <- file.path(package, r_content)
  expect_equal(
    sort(observed_files),
    sort(expected_files)
  )
})
