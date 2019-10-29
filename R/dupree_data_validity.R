###############################################################################

# Data-validity checking for data-structures in `dupree`

###############################################################################

.build_name_checker <- function(label) {
  function(x) label %in% names(x)
}

###############################################################################

.has_content <- .build_name_checker("content")

.has_parsed_content <- .build_name_checker("parsed_content")

###############################################################################

#' Checks if a data-structure conforms to the structure of a `parsed_content`
#' entry as present in a subentry of get_source_expressions...$expressions
#'
#' @noRd
#'
.is_parsed_content <- function(x) {
  # data-frame with columns: line1, col1, line2, col2, id, parent, token,
  #   terminal, text
  reqd_columns <- c(
    "line1", "col1", "line2", "col2", "id", "parent", "token",
    "terminal", "text"
  )

  is.data.frame(x) &&
    all(reqd_columns %in% colnames(x))
}
