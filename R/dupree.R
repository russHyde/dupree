###############################################################################

# Workflow for a set of files:
# - for each file:
#     - `get_source_expressions` on the file
#     - drop any entry in `expressions` that stores the whole file
#     - join the parsed_content blocks by block-number
# - join the file-level parsed-content blocks by file-name
# - filter the tokens to non-trivial symbols
#     - drop any blocks that have fewer non-trivial symbols than some threshold
# - enumerate the symbols
# - construct a vector of enumerated-symbols for each code-block in each file
# - run levenshtein distance between each pair of enumerated code blocks
# - return the distance-sorted associations between blocks

# Therefore, need class:
#   - `EnumeratedCodeTable`: tibble containing colnames "file", "block",
#   "start_line", "enumerated_code"
#   - the "enumerated_code" column is a list of vectors of integers
#   - methods: find_best_matches() and find_best_matches_of_single_block()

# Also need a way to filter out blocks that have few non-trivial symbols

###############################################################################

#' Newer version of the duplicate detection workflow
#'
#' @param        files         A set of files over which code-duplication
#'   should be measured.
#' @param        min_block_size   `dupree` uses a notion of non-trivial
#'   symbols.  These are the symbols / code-words that remain after filtering
#'   out really common symbols like `<-`, `,`, etc. After filtering out these
#'   symbols from each code-block, only those blocks containing at least
#'   `min_block_size` symbols are used in the inter-block code-duplication
#'   measurement.
#' @param        ...           Unused at present.
#'
#' @importFrom   magrittr      %>%
#'
#' @export

dupree <- function(files, min_block_size = 20, ...) {
  preprocess_code_blocks(files, min_block_size) %>%
    find_best_matches()
}

###############################################################################

#' `dupree_dir` - run duplicate-code detection over all R-files in a directory
#'
#' @inheritParams   dupree
#'
#' @param        path          A directory. All files in this directory that
#' have a ".R", ".r" or ".Rmd" extension will be checked for code duplication.
#'
#' @param        filter        A pattern for use in grep - this is used to
#' keep only particular files: eg, filter = "classes" would compare files with
#' `classes` in the filename
#'
#' @param        ...           Further arguments for grep. For example,
#' `filter = "test", invert = TRUE` would disregard all files with `test` in
#' the file-path.
#'
#' @param       recursive     Should we consider files in subdirectories as
#' well?
#'
#' @export

dupree_dir <- function(path,
                       min_block_size = 20,
                       filter = NULL,
                       ...,
                       recursive = TRUE) {
  files <- dir(
    path,
    pattern = ".*(.R|.r|.Rmd)$", full.names = TRUE, recursive = recursive
  )
  keep_files <- if (is.null(filter)) {
    files
  } else {
    files[grep(pattern = filter, x = files, ...)]
  }
  dupree(keep_files, min_block_size)
}

###############################################################################

#' `dupree_package` - run duplicate-code detection over all files in a
#' package's `R` directory
#'
#' @inheritParams   dupree
#'
#' @param        package       The name or path to the package that is to be
#' checked.
#'
#' @export

dupree_package <- function(package,
                           min_block_size = 20) {
  # nolint start
  dupree_dir(package, min_block_size, filter = paste0(package, "/R/"))
  # nolint end
}

###############################################################################
