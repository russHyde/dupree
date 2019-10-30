###############################################################################

# Classes for `dupree`

###############################################################################

# Class definition: `EnumeratedCodeTable`

#' An S4 class to represent the code blocks as strings of integers
#'
#' @name   EnumeratedCodeTable-class
#' @slot   blocks   A tbl_df with columns `file`, `block`, `start_line` and
#'   `enumerated_code`
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
#' An `EnumeratedCodeTable` contains a `blocks` table. Each row of this table
#' contains details for a block of R code: the filename, block-id and startline
#' of the block, and a tokenized version of the code within that block.
#'
#' Once initialised, the blocks table is ordered by filename and then block-id.
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
    } else {
      # we ensure that the code blocks are ordered by file and then block
      .Object@blocks <- dplyr::arrange(
        blocks, .data[["file"]], .data[["block"]]
      )
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
#'
#' The code blocks are assumed to be ordered within the
#' `EnumeratedCodeTable`, as such when two code blocks are
#' mutually-best-matches, the results returned by this function only contains
#' a single row for those two code blocks; when this happens we guarantee that
#' `file_a` <= `file_b` and `block_a` <= `block_b`
#'
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
#' @importFrom   dplyr         arrange   desc   mutate   select
#' @importFrom   purrr         map_df
#' @importFrom   stringdist    seq_sim
#' @importFrom   tibble        tibble
#' @importFrom   rlang         .data
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

  # .one_against_all returns df: (index_a, index_b, score)

  # For each code-block we want to identify it's closest matching code-block
  #
  # We only return a code-block pair once (ie, if A-B is a pair and B-A is a
  # pair, then we return A-B, but not B-A)
  #
  # When C-A is a pair but the index of C is greater than that of A, we return
  # the pair A-C

  scores <- purrr::map_df(
    seq_along(enum_codes),
    .one_against_all,
    enum_codes,
    sim_func
  ) %>%
    # ensure the index of A is less than the index of B
    dplyr::mutate(
      temp = pmax(.data[["index_a"]], .data[["index_b"]]),
      index_a = pmin(.data[["index_a"]], .data[["index_b"]]),
      index_b = .data[["temp"]]
    ) %>%
    dplyr::select(
      -.data[["temp"]]
    ) %>%
    # only return each code-block pair once
    unique() %>%
    # order the code-block pairs by decreasing score
    dplyr::arrange(
      dplyr::desc(.data[["score"]]), .data[["index_a"]], .data[["index_b"]]
    )

  scores
}

###############################################################################
