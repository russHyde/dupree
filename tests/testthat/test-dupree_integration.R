test_that("multiplication works", {
  expect_is(
    dupree(
      files = file.path("testdata", "anRpackage", "R", "anRpackage-internal.R")
    ),
    "dups"
  )
})
