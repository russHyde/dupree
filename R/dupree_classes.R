###############################################################################

# Classes for `dupree`

###############################################################################

# Class definition / initialised / validator: `EnumeratedCodeTable``

###############################################################################

methods::setClass("EnumeratedCodeTable", slots = list(blocks = "tbl_df"))

###############################################################################

# `EnumeratedCodeTable` validation

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

methods::setValidity("EnumeratedCodeTable", .is_enumerated_code_table)

###############################################################################

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

###############################################################################

# `find_best_matches`

###############################################################################
# By default we use `lcs` as the sequence-similarity measure
# - for two integer vectors, the lcs-distance is the minimum number of entries
# that need to be removed from both vectors before identity is reached
# - then the lcs-similarity score is 1 - distance / max_length; where
# max_length is the sum of the lengths of the two input vectors
# - d((1, 2, 3, 4), (1, 4, 5, 6)) = 4; s(..., ...) = 1 - 4 / 8
# - we use lcs because it's simple to explain

methods::setGeneric("find_best_matches", function(x, ...) {
  methods::standardGeneric("find_best_matches")
})

methods::setMethod(
  "find_best_matches",
  methods::signature("EnumeratedCodeTable"),
  function(x, ...) {
    blocks <- x@blocks
    enum_codes <- x@blocks$enumerated_code
    index_matches <- .find_indexes_of_best_matches(enum_codes, ...)
    details_a <- blocks[index_matches$index_a, ]
    details_b <- blocks[index_matches$index_b, ]

    score <- index_matches$score

    tibble::tibble(
      file_a = details_a$file,
      file_b = details_b$file,
      block_a = details_a$block,
      block_b = details_b$block,
      line_a = details_a$start_line,
      line_b = details_b$start_line,
      score = score
    )
  }
)

###############################################################################

# Related Functions

###############################################################################

#' One against all search
.one_against_all <- function(subject_index, enum_codes, sim_func) {
  subject <- enum_codes[subject_index]
  scores <- sim_func(subject, enum_codes)
  scores[subject_index] <- -1
  list(
    index_a = subject_index,
    index_b = which.max(scores),
    score = max(scores)
  )
}

#' All against all search
#'
#' @importFrom   dplyr         arrange_   desc
#' @importFrom   purrr         map_df
#' @importFrom   stringdist    seq_sim
#' @importFrom   tibble        tibble
#'
.find_indexes_of_best_matches <- function(enum_codes, method = "lcs", ...) {
  empty_result <- tibble::tibble(
    index_a = integer(0), index_b = integer(0), score = numeric(0)
  )
  if (length(enum_codes) <= 1) {
    return(empty_result)
  }

  sim_func <- function(x, y) {
    stringdist::seq_sim(x, y, method = method, ...)
  }

  scores <- purrr::map_df(
    seq_along(enum_codes),
    .one_against_all,
    enum_codes,
    sim_func
  )

  scores %>%
    dplyr::arrange_(
      ~ dplyr::desc(score), ~ index_a, ~ index_b
    )
}

###############################################################################
