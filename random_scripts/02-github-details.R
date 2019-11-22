###############################################################################

load_packages <- function(pkgs) {
  for (pkg in pkgs) {
    suppressPackageStartupMessages(
      library(pkg, character.only = TRUE)
    )
  }
}

###############################################################################

define_repositories <- function(pkg_table, repo_dir) {
  stop("TODO: define_repositories() function")
  # Define a table containing package-name, remote-GH-url and
  # local-repo-filepath (based on the filtered cran table)
}

###############################################################################

run_script <- function(dev_pkgs_path, repo_dir, results_dir) {
  # Converts a CRAN table that only contains github-hosted packages into a
  # table containing  (package-name, remote-repo, local-repo) paths.

  dev_pkg_table <- readr::read_tsv(dev_pkgs_path)

  repo_details <- define_repositories(dev_pkg_table, repo_dir)

  readr::write_tsv(
    repo_details,
    file.path(results_dir, "dev-pkg-repositories.tsv")
  )
}

###############################################################################

# pkgs require for running the script (not the packages that are analysed here)
load_packages(c("dplyr", "git2r", "tibble", "magrittr"))

results_dir <- "results"
run_script(
  file.path(results_dir, "dev-pkg-table.tsv"),
  results_dir
)

###############################################################################
