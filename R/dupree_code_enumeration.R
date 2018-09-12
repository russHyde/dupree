###############################################################################

# Functions / Classes for extracting / collapsing / filtering parsed-code
# blocks from a set of files
# - All non-trivial symbols in the code blocks are enumerated (converted to an
#   integer) for use in similarity measurement

###############################################################################

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
#' @importFrom   dplyr         mutate
#' @include      dupree_data_validity.R
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
#' @importFrom   dplyr         bind_rows
#' @importFrom   purrr         keep   map2
#' @include   dupree_data_validity.R
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

#' @importFrom   dplyr         filter
filter_code_tokens <- function(df) {
  # TODO: check for presence of `token` column
  drop_tokens <- c(
    "'-'", "','", "'('", "')'", "'['", "']'", "'{'", "'}'",
    "'$'", "'@'", "AND2", "NS_GET", "expr", "COMMENT",
    "LEFT_ASSIGN", "LBB"
  )

  df %>%
    dplyr::filter_(~ !token %in% drop_tokens)
}

#' @importFrom   dplyr         mutate_
enumerate_code_symbols <- function(df) {
  # TODO: check for `text` column
  df %>%
    dplyr::mutate_(symbol_enum = ~ as.integer(factor(text)))
}

#' @importFrom   dplyr         group_by_   summarise_
summarise_enumerated_blocks <- function(df) {
  df %>%
    dplyr::group_by_(~ file, ~ block, ~ start_line) %>%
    dplyr::summarise_(enumerated_code = ~ list(c(symbol_enum)))
}

###############################################################################

#' @importFrom   dplyr         bind_rows
#' @importFrom   lintr         get_source_expressions
#' @importFrom   purrr         map
import_parsed_code_blocks <- function(files) {
  files %>%
    purrr::map(lintr::get_source_expressions) %>%
    purrr::map(get_localised_parsed_code_blocks) %>%
    dplyr::bind_rows()
}

#' @importFrom   methods       new
#' @include      dupree_classes.R
#'
preprocess_code_blocks <- function(files) {
  blocks <- files %>%
    import_parsed_code_blocks() %>%
    filter_code_tokens() %>%
    enumerate_code_symbols() %>%
    summarise_enumerated_blocks()

  methods::new("EnumeratedCodeTable", blocks)
}

###############################################################################
