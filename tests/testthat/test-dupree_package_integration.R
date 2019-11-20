context("Integration tests for `dupree_package()`")

test_that("Only files in <my_pkg>/R/ are present in the results", {
  # the test-package "anRpackage" contains
  # - ./R/anRpackage-internal.R
  # - and ./inst/dir1/R/dont_dup_me.R
  # - the latter should not be included by dupree_package() by default
  expect_silent(
    dupree_package(file.path("testdata", "anRpackage"))
  )

  dups <- dupree_package(file.path("testdata", "anRpackage"))
  files <- unique(c(dups$file_a, dups$file_b))
  expect_equal(
    files,
    file.path("testdata", "anRpackage", "R", "anRpackage-internal.R")
  )
})
