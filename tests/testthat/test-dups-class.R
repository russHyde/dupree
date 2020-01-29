
test_that("`dups` object can be converted to `data.frame`", {
  x <- get_empty_dups_df()
  dups <- as_dups(x)

  expect_equal(
    as.data.frame(dups),
    x,
    info = "conversion `dups` -> `data.frame`"
  )

  expect_equal(
    as_dups(as_dups(x)),
    as_dups(x),
    info = "dups -> dups conversion is an identity map"
  )

  y <- get_empty_dups_tbl()
  dups <- as_dups(y)

  expect_equal(
    as_tibble(dups),
    y,
    info = "conversion `dups` -> `tibble`"
  )
})

test_that("non dups/data-frames can't be converted to dups", {
  expect_error(as_dups("NOT A data.frame or dups object"))
})
