###############################################################################

define_repositories <- function(pkg_table, repo_dir) {
  stop("TODO: define_repositories() function")
  # Define a table containing package-name, remote-GH-url and
  # local-repo-filepath (based on the filtered cran table)
}

###############################################################################

run_script <- function(cran_details_file, repo_dir, results_file) {
  # Converts a CRAN table that only contains github-hosted packages into a
  # table containing  (package-name, remote-repo, local-repo) paths.

  dev_pkg_table <- readr::read_tsv(cran_details_file)

  repo_details <- define_repositories(dev_pkg_table, repo_dir)

  readr::write_tsv(repo_details, results_file)
}

###############################################################################

source("utils.R")
source("config.R")

###############################################################################

# pkgs require for running the script (not the packages that are analysed here)
load_packages(c("dplyr", "magrittr", "readr", "tibble"))

run_script(
  cran_details_file = config[["cran_details_file"]],
  repo_dir = config[["repo_dir"]],
  results_file = config[["repo_details_file"]]
)

###############################################################################
