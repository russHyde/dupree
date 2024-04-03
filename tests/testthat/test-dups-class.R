
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

  y <- get_dups_tbl()
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

describe("printing a 'dups' object", {
  dups <- as_dups(get_dups_tbl(file_a = paste0(letters, ".R")))

  it("includes the first line in the output", {
    expect_output(print(dups), regexp = "a\\.R")
  })

  it("respects print(tibble, n = ...)", {
    # "z.R" is on the last line of the table, it shouldn't be visible by default
    # because `print(tibble)` shows the first 10 lines for large tables
    expect_output(print(dups), regexp = "[^z].\\R")
    # But when 26 lines of the table are printed, then the file "z.R" should be
    # seen
    expect_output(print(dups, n = 26), regexp = "z\\.R")
  })
})
