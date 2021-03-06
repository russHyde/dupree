###############################################################################

context("Tests duplicated code analysis functions")

###############################################################################

.make_exprs <- function(strs) {
  # Convert a vector of strings into an source_expressions structure for use
  # in parse_code_blocks
  exprs <- setNames(
    Map(
      function(s) {
        list(
          content = s,
          parsed_content = getParseData(parse(text = s))
        )
      },
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


###############################################################################
