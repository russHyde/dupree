context("Integration tests for `dupree_package()`")

test_that("`dupree_package` results only include files from <my_pkg>/R/", {
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

test_that("`dupree_package` fails when passed a non-R package structure", {

  # There must be a DESCRIPTION file present
  d <- tempfile(pattern = "not_an_r_package")
  dir.create(d)
  dir.create(file.path(d, "R"))

  expect_error(
    dupree_package(d),
    regexp = "not an R package",
    info = "DESCRIPTION must be present in the path passed to dupree_package"
  )

  # There must be an R/ subdirectory present
  d <- tempfile(pattern = "not_an_r_package")
  dir.create(d)
  file.create(file.path(d, "DESCRIPTION"))

  expect_error(
    dupree_package(d),
    regexp = "not an R package",
    info = "R/ subdir must be present in the path passed to dupree_package"
  )
})
