###############################################################################

get_repo_from_comma_sepd_string <- function(x) {
  # input could be
  # "http[s]://[www.]github.com/<user>/<repo>[/issues][,] some-other-url"

  # For each entry in the vector of strings, return the first URL that is of
  # the form
  # "http[s]://[www.]github.com/<user>/repo[/<subdir>|#<section>]"
  # But strip off the optional <subdir> and #<section> (eg, issues)

  extract_and_get_first_match <- function(urls) {
    s <- urls %>%
      stringr::str_extract(
        pattern = "(https*://(www\\.)*github.com/[^/]+/[^/]+)"
      ) %>%
      stringr::str_replace_all(
        pattern = "^(.*)#.*$", replacement = "\\1"
      )

    s[!is.na(s) & nchar(s) > 0][1]
  }

  strsplit(x, "[, ]") %>%
    purrr::map(trimws) %>%
    purrr::map_chr(extract_and_get_first_match)
}

test_get_repo <- function() {
  if (!requireNamespace("testthat")) {
    message("testthat should be installed")
    return()
  }
  testthat::test_that("repo_parser_works", {
    # Deal with:
    # - http and https,
    # - www present or absent,
    # - trailing slash after reponame
    # - subdirectories (<repo>/issues)
    # - subsections (<repo>#readme)
    # - comma-space-separated (", ") and space-separated (" ") URLs
    repo <- "github.com/abc/123"
    ht <- c("https://", "http://")
    www <- c("", "www.")
    prefixes <- c(
      "", "https://not-a-github.com/repo, ", "https://some-other-repo.com "
    )
    suffixes <- c("", "/", "/issues", ",", ", ", "/, ", "#readme")

    grid <- expand.grid(prefixes, ht, www, repo, suffixes)
    input_url <- do.call(paste0, grid)
    expected_url <- do.call(paste0, grid[2:4])

    testthat::expect_equal(
      get_repo_from_comma_sepd_string(input_url),
      expected_url
    )
  })
}

define_repositories <- function(pkg_table, repo_dir) {
  # Define a table containing package-name, remote-GH-url and
  # local-repo-filepath (based on the filtered cran table)

  # URLs are stored as a ", "-separated string within fields 'url' and
  # 'bug_reports'

  define_remote <- function() {
    get_repo_from_comma_sepd_string(
      paste(pkg_table$url, pkg_table$bug_reports, sep = ", ")
    )
  }
  define_local <- function() {
    file.path(repo_dir, pkg_table$package)
  }

  tibble::tibble(
    package = pkg_table$package,
    remote_repo = define_remote(),
    local_repo = define_local()
  )
}

###############################################################################

run_tests <- function() {
  message("Running tests ...")
  test_get_repo()
}

###############################################################################

main <- function(cran_details_file, repo_dir, results_file) {
  message("Running script ...")
  # Converts a CRAN table that only contains github-hosted packages into a
  # table containing  (package-name, remote-repo, local-repo) paths.

  dev_pkg_table <- readr::read_tsv(
    cran_details_file, col_types = cols(.default = "c")
  )

  repo_details <- define_repositories(dev_pkg_table, repo_dir)

  readr::write_tsv(repo_details, results_file)
}

###############################################################################

source("utils.R")
source("config.R")

###############################################################################

# pkgs require for running the script (not the packages that are analysed here)
load_packages(c("dplyr", "magrittr", "readr", "stringr", "tibble"))

run_tests()

main(
  cran_details_file = config[["cran_details_file"]],
  repo_dir = config[["repo_dir"]],
  results_file = config[["repo_details_file"]]
)

###############################################################################
