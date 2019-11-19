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
# - run levenshtein distance between each pair of enumerated code-blocks
# - return the distance-sorted associations between blocks

# Therefore, need class:
#   - `EnumeratedCodeTable`: tibble containing colnames "file", "block",
#   "start_line", "enumerated_code"
#   - the "enumerated_code" column is a list of vectors of integers
#   - methods: find_best_matches() and find_best_matches_of_single_block()

# Also need a way to filter out blocks that have few non-trivial symbols

###############################################################################

#' Detect code duplication between the code-blocks in a set of files
#'
#' This function identifies all code-blocks in a set of files and then computes
#' a similarity score between those code-blocks to help identify functions /
#' classes that have a high level of duplication, and could possibly be
#' refactored.
#'
#' Code-blocks under a size threshold are disregarded before analysis (the size
#' threshold is controlled by \code{min_block_size}); and only top-level code
#' blocks are considered.
#'
#' Every sufficiently large code-block in the input files will be present in
#' the results at least once. If code-block X and code-block Y are present in
#' a row of the resulting data-frame, then either X is the closest match to Y,
#' or Y is the closest match to X (or possibly both) according to the
#' similarity score; as such, some code-blocks may be present multiple times in
#' the results.
#'
#' Similarity between code-blocks is calculated using the
#' longest-common-subsequence (\code{lcs}) measure from the package
#' \code{stringdist}. This measure is applied to a tokenised version of the
#' code-blocks. That is, each function name / operator / variable in the code
#' blocks is converted to a unique integer so that a code-block can be
#' represented as a vector of integers and the \code{lcs} measure is applied to
#' each pair of these vectors.
#'
#' @param        files         A set of files over which code-duplication
#'   should be measured.
#'
#' @param        min_block_size   `dupree` uses a notion of non-trivial
#'   symbols.  These are the symbols / code-words that remain after filtering
#'   out really common symbols like `<-`, `,`, etc. After filtering out these
#'   symbols from each code-block, only those blocks containing at least
#'   `min_block_size` symbols are used in the inter-block code-duplication
#'   measurement.
#'
#' @param        ...           Unused at present.
#'
#' @return        A tibble. Each row in the table summarises the comparison
#' between two code-blocks (block 'a' and block 'b') in the input files. Each
#' code-block in the pair is indicated by: i) the file (file_a / file_b) that
#' contains it; ii) its position within that file (block_a / block_b; 1 being
#' the first code-block in a given file); and iii) the line where that
#' code-block starts in that file (line_a / line_b). The pairs of code-blocks
#' are ordered by decreasing similarity. Any match that is returned is either
#' the top hit for block 'a' or for block 'b' (or both).
#'
#' @importFrom   magrittr      %>%
#'
#' @examples
#' # To quantify duplication between the top-level code-blocks in a file
#' example_file <- system.file("extdata", "duplicated.R", package = "dupree")
#' dup <- dupree(example_file, min_block_size = 10)
#' dup
#'
#' # For the block-pair with the highest duplication, we print the first four
#' # lines:
#' readLines(example_file)[dup$line_a[1] + c(0:3)]
#' readLines(example_file)[dup$line_b[1] + c(0:3)]
#'
#' # The code-blocks in the example file are rather small, so if
#' # `min_block_size` is too large, none of the code-blocks will be analysed
#' # and the results will be empty:
#' dupree(example_file, min_block_size = 40)
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
#' @seealso     dupree
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
#' @seealso      dupree
#'
#' @export

dupree_package <- function(package,
                           min_block_size = 20) {
  dupree_dir(package, min_block_size, filter = paste0(package, "/R/"))
}

###############################################################################
