###############################################################################

if (requireNamespace("lintr", quietly = TRUE)) {
  context("Tests for lints in `dupree` package")
  # To ensure this test is ran during development, use devtools::test()
  #   or devtools::check(check_dir = "."), rather than devtools::check()
  test_that("Package Style", {
    lintr::expect_lint_free()
  })
}

###############################################################################
