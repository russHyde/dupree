###############################################################################

context("Tests duplicated code analysis functions")

###############################################################################

test_that("Decommenting code", {
  expect_equal(
    object = .decomment("abc"),
    expected = "abc",
    info = "No comment!"
  )

  expect_equal(
    object = .decomment("abc\n"),
    expected = "abc\n",
    info = "No comment - with a newline"
  )

  expect_equal(
    object = .decomment("# abc"),
    expected = "",
    info = "Remove single line"
  )

  expect_equal(
    object = .decomment("# abc\n"),
    expected = "\n",
    info = "Remove new-line appended comment"
  )

  expect_equal(
    object = .decomment("abc\n#"),
    expected = "abc\n",
    info = "Comment on the line following some code"
  )

  expect_equal(
    object = .decomment("# 123\nabc"),
    expected = "\nabc",
    info = "Comment on the line preceding some code"
  )

  expect_equal(
    object = .decomment("abc <- 123 # def"),
    expected = "abc <- 123",
    info = "Comment on the same line as code; note that space prefixes are
removed"
  )

  expect_equal(
    object = .decomment("abc <- 123 # define 'abc'\nghi <- 456"),
    expected = "abc <- 123\nghi <- 456",
    info = "Two lines of code, with comment trailing the first one"
  )

  expect_equal(
    object = .decomment("# comment1\n# comment2\nabc"),
    expected = "\n\nabc",
    info = "Two comment lines, with subsequent code"
  )

  # doesn't currently deal with
  # expect_equal(
  #   object   = .decomment("print('# not a comment')"),
  #   expected = "print('# not a comment')",
  #   info     = "quoted hashes shouldn't be read as comments"
  # )
})

###############################################################################

test_that("parse_code_blocks: invalid input", {
  expect_error(
    parse_code_blocks(),
    info = ""
  )
  expect_error(
    parse_code_blocks(list()),
    info = ""
  )
  expect_error(
    parse_code_blocks(list(expressions = list(), error = character())),
    info = ""
  )
  expect_error(
    parse_code_blocks(list(error = character(), lines = list())),
    info = ""
  )
  expect_error(
    parse_code_blocks(list(expressions = list(), lines = list())),
    info = ""
  )
})

###############################################################################
.make_exprs <- function(strs) {
  # Convert a vector of strings into an source_expressions structure for use
  # in parse_code_blocks
  exprs <- setNames(
    Map(
      function(s) list(
        content = s,
        parsed_content = getParseData(parse(text = s))
      ),
      strs
    ),
    NULL
  )

  list(
    expressions = exprs,
    error = character(),
    lines = list()
  )
}

test_that("is_source_expressions", {
  expect_true(
    object = .is_source_expressions_object(.make_exprs("abc")),
    info = "Check that I can make a valid source_expressions object"
  )
})

###############################################################################

test_that("parse_code_blocks: valid input", {
  expect_equal(
    object = parse_code_blocks(.make_exprs("abc")),
    expected = c("abc"),
    info = "Single valid line of code - no comments or whitespace"
  )

  expect_equal(
    object = parse_code_blocks(.make_exprs("abc <- 123")),
    expected = c("abc<-123"),
    info = "Single valid line of code - contains whitespace"
  )

  expect_equal(
    object = parse_code_blocks(
      .make_exprs(
        c("abc", "abc # def", "abc <- 123\ndef <- f(g)")
      )
    ),
    expected = c("abc", "abc", "abc<-123def<-f(g)"),
    info = "Various code examples - remove comments, remove whitespace"
  )
})

###############################################################################
