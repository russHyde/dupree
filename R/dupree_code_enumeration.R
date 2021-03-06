###############################################################################

# Functions / Classes for extracting / collapsing / filtering parsed-code
# blocks from a set of files
# - All non-trivial symbols in the code blocks are enumerated (converted to an
#   integer) for use in similarity measurement

###############################################################################

#' `.get_default_annotated_parsed_content`
#'
#' @noRd
#'
.get_default_annotated_parsed_content <- function() {
  i0 <- integer(0)
  c0 <- character(0)
  l0 <- logical(0)

  tibble::tibble(
    line1 = i0, col1 = i0, line2 = i0, col2 = i0, id = i0, parent = i0,
    token = c0, terminal = l0, text = c0, file = c0, block = i0,
    start_line = i0
  )
}

#' Add filename, block-number and start-line for the parsed-content for each
#'   code block in a given file
#'
#' @param        parsed_content   The parsed-content for a specific code-block
#'   from running get_source_expressions on a file.
#' @param        file             The filename for the content.
#' @param        block            The block from which the content came.
#' @param        start_line       The start-line of the block in the filename.
#'
#' @importFrom   dplyr         mutate
#' @include      dupree_data_validity.R
#'
#' @noRd
#'
annotate_parsed_content <- function(parsed_content, file, block, start_line) {
  stopifnot(.is_parsed_content(parsed_content))

  parsed_content %>%
    dplyr::mutate(
      file = file, block = block, start_line = start_line
    )
}

#' Convert a list of source_expressions to a data-frame that contains the
#'   parsed-content from each source expression, and indicates the file,
#'   block-number and start-line for that source expression
#'
#' @param        source_exprs   A list of source-expressions, obtained from
#'   lintr::get_source_expressions.
#'
#' @importFrom   dplyr         bind_rows
#' @importFrom   purrr         keep   map2
#' @include   dupree_data_validity.R
#'
#' @noRd
#'
get_localised_parsed_code_blocks <- function(source_exprs) {
  source_blocks <- purrr::keep(
    source_exprs[["expressions"]],
    .has_parsed_content
  )

  if (length(source_blocks) == 0) {
    return(.get_default_annotated_parsed_content())
  }

  parsed_content <- purrr::map2(
    source_blocks,
    seq_along(source_blocks),
    function(x, y) {
      annotate_parsed_content(x$parsed_content, x$file, y, x$line)
    }
  )

  dplyr::bind_rows(parsed_content)
}

#' `remove_trivial_code_symbols`
#'
#' @importFrom   dplyr         filter
#' @importFrom   rlang         .data
#'
#' @noRd
#'
remove_trivial_code_symbols <- function(df) {
  # TODO: check for presence of `token` column
  .quote_wrap <- function(x) {
    gsub(pattern = "^(.*)$", replacement = "'\\1'", x)
  }

  drop_tokens <- c(
    .quote_wrap(
      c("-", "+", ",", "(", ")", "[", "]", "{", "}", "$", "@", ":")
    ),
    "AND2", "NS_GET", "expr", "COMMENT", "LEFT_ASSIGN", "LBB", "EQ_SUB"
  )

  df %>%
    dplyr::filter(!.data[["token"]] %in% drop_tokens)
}

#' enumerate_code_symbols
#'
#' @importFrom   dplyr         mutate
#' @importFrom   rlang         .data
#'
#' @noRd
#'
enumerate_code_symbols <- function(df) {
  # TODO: check for `text` column
  df %>%
    dplyr::mutate(symbol_enum = as.integer(factor(.data[["text"]])))
}

#' summarise_enumerated_blocks
#'
#' @importFrom   dplyr         group_by   summarise   n
#' @importFrom   rlang         .data
#'
#' @noRd
#'
summarise_enumerated_blocks <- function(df) {
  df %>%
    dplyr::group_by(
      .data[["file"]], .data[["block"]], .data[["start_line"]]
    ) %>%
    dplyr::summarise(
      enumerated_code = list(c(.data[["symbol_enum"]])),
      block_size = dplyr::n()
    )
}

###############################################################################

#' import_parsed_code_blocks_from_one_file
#'
#' @importFrom   dplyr         filter
#' @importFrom   lintr         get_source_expressions
#' @importFrom   rlang         .data
#'
#' @noRd
#'
import_parsed_code_blocks_from_one_file <- function(file) {
  file %>%
    lintr::get_source_expressions() %>%
    get_localised_parsed_code_blocks() %>%
    dplyr::filter(!.data[["token"]] %in% "COMMENT")
}

#' import_parsed_code_blocks
#'
#' @importFrom   dplyr         bind_rows
#' @importFrom   purrr         map
#'
#' @noRd
#'
import_parsed_code_blocks <- function(files) {
  files %>%
    purrr::map(import_parsed_code_blocks_from_one_file) %>%
    dplyr::bind_rows()
}

#' tokenize_code_blocks
#'
#' @noRd
#'
tokenize_code_blocks <- function(block_df) {
  block_df %>%
    remove_trivial_code_symbols() %>%
    enumerate_code_symbols() %>%
    summarise_enumerated_blocks()
}

###############################################################################

#' preprocess_code_blocks
#'
#' @param        files         A set of *.R or *.Rmd files over which dupree is
#'   to perform duplicate-identification
#' @param        min_block_size   An integer >= 1. How many non-trivial symbols
#'   must be present in a code-block if that block is to be used in
#'   code-duplication detection.
#'
#' @importFrom   dplyr         filter
#' @importFrom   methods       new
#' @include      dupree_classes.R
#'
#' @noRd
#'
preprocess_code_blocks <- function(files, min_block_size = 40) {
  blocks <- files %>%
    import_parsed_code_blocks() %>%
    tokenize_code_blocks() %>%
    dplyr::filter(
      .data[["block_size"]] >= min_block_size
    )

  methods::new("EnumeratedCodeTable", blocks)
}

###############################################################################
