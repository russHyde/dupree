###############################################################################

# Classes for `dupree`

###############################################################################

# Class definition: `EnumeratedCodeTable`

#' EnumeratedCodeTable
#'
methods::setClass("EnumeratedCodeTable", slots = list(blocks = "tbl_df"))

###############################################################################

#' `EnumeratedCodeTable` validation
#'
#' @noRd
#'
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

#' Initialise an `EnumeratedCodeTable`
#'
#' @importFrom   methods       callNextMethod   setMethod   validObject
#' @importFrom   tibble        tibble
#'
#' @noRd
#'
methods::setMethod(
  "initialize",
  "EnumeratedCodeTable",
  # nolint start
  function(.Object, blocks = NULL, ...) {
    .Object <- methods::callNextMethod(...)
    # nolint end

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

#' `find_best_matches` between code blocks
#'
#' @noRd
#'
methods::setGeneric("find_best_matches", function(x, ...) {
  methods::standardGeneric("find_best_matches")
})

#' `find_best_matches` between code blocks in an `EnumeratedCodeTable`
#' @noRd
#'
methods::setMethod(
  "find_best_matches",
  methods::signature("EnumeratedCodeTable"),
  function(x, ...) {
    blocks <- x@blocks
    enum_codes <- x@blocks$enumerated_code
    index_matches <- find_indexes_of_best_matches(enum_codes, ...)
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
#'
#' @noRd
#'
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

#' One against one search
#'
#' @noRd
#'
.one_against_one <- function(subject_index, target_index, enum_codes, sim_func) {
  score <- sim_func(enum_codes[subject_index], enum_codes[target_index])
  list(
    index_a = subject_index,
    index_b = target_index,
    score = score
  )
}

#' All against all search
#'
#' @param        enum_codes    List of vectors of integers. Each `int` is an
#'   enumerated code for some code-symbol (like a conversion of the
#'   code-symbols into a factor).
#' @param        method        Alignment method for use in
#'   `stringdist::seq_sim`.
#' @param        ...           Further parameters for passing to
#'   `stringdist::seq_sim`.
#'
#' @importFrom   dplyr         arrange_   desc
#' @importFrom   purrr         map_df
#' @importFrom   stringdist    seq_sim
#' @importFrom   tibble        tibble
#'
#' @noRd
#'
find_indexes_of_best_matches <- function(enum_codes, method = "lcs", ...) {
  empty_result <- tibble::tibble(
    index_a = integer(0), index_b = integer(0), score = numeric(0)
  )
  if (length(enum_codes) <= 1) {
    return(empty_result)
  }

  sim_func <- function(x, y) {
    stringdist::seq_sim(x, y, method = method, ...)
  }
  combs <- combn(seq_along(enum_codes), 2)
  scores <- purrr::map2_dfr(
    combs[1, ],
    combs[2, ],
    .one_against_one,
    enum_codes,
    sim_func
  )

  a_scores <- scores %>% dplyr::group_by(index_a) %>% 
    filter(score == max(score))
  b_scores <- scores %>% dplyr::group_by(index_b) %>% 
    filter(score == max(score))

  dplyr::bind_rows(a_scores, b_scores) %>% 
    dplyr::distinct(index_a, index_b, .keep_all = TRUE) %>%
    dplyr::arrange_(
      ~ dplyr::desc(score), ~index_a, ~index_b
    )
}

###############################################################################
