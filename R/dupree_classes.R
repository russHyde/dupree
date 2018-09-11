###############################################################################

# Classes for `dupree`

###############################################################################

.is_enumerated_code_table <- function(object) {
  required_cols <- c("file", "block", "start_line", "enumerated_code")
  observed_cols <- colnames(object@blocks)

  if (
    all(required_cols %in% observed_cols)
  ) {
    TRUE
  } else {
    missing_cols <- setdiff(required_cols, observed_cols)
    paste("Column", missing_cols, "should be in object@blocks")
  }
}

###############################################################################

methods::setClass("EnumeratedCodeTable", slots = list(blocks = "tbl_df"))

methods::setValidity("EnumeratedCodeTable", .is_enumerated_code_table)

#' @importFrom   methods       callNextMethod   setMethod   validObject
#' @importFrom   tibble        tibble
methods::setMethod(
  "initialize",
  "EnumeratedCodeTable",
  function(.Object, blocks = NULL, ...) {
    .Object <- methods::callNextMethod(...)

    default_code_table <- tibble::tibble(
      file = character(0), block = integer(0), start_line = integer(0),
      enumerated_code = list()
    )

    if (is.null(blocks)) {
      .Object@blocks <- default_code_table
    }

    methods::validObject(.Object)

    .Object
  }
)
