
#' Create a \code{Lint} object
#' @param filename path to the source file that was linted.
#' @param line_number line number where the lint occurred.
#' @param column_number column number where the lint occurred.
#' @param type type of lint.
#' @param message message used to describe the lint error
#' @param line code source where the lint occurred
#' @param ranges a list of ranges on the line that should be emphasized.
#' @param linter name of linter that created the Lint object.
#' @export

# nolint start
Lint <- function(
                 # nolint end
                 filename, line_number = 1L, column_number = 1L,
                 type = c("style", "warning", "error"),
                 message = "", line = "", ranges = NULL, linter = "") {
  type <- match.arg(type)

  structure(
    list(
      filename = filename,
      line_number = as.integer(line_number),
      column_number = as.integer(column_number),
      type = type,
      message = message,
      line = line,
      ranges = ranges,
      linter = linter
    ),
    class = "lint"
  )
}
