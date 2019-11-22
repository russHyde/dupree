###############################################################################

# Download lots of R packages from remote to local repositories

###############################################################################

load_packages <- function(pkgs) {
  for (pkg in pkgs) {
    suppressPackageStartupMessages(
      library(pkg, character.only = TRUE)
    )
  }
}

###############################################################################

clone_repositories <- function(x) {
  stop("TODO: clone_packages() function")

  # Clone each package from its remote to its local repo (but only if we
  # haven't already cloned it)
}

###############################################################################

run_script <- function(repo_details_file) {
  # Takes a table of CRAN packages of the form (package-name, remote-repo,
  # local-repo) and clones each package from it's remote location to the
  # specified local location.

  repo_details <- readr::read_tsv(repo_details_file)

  clone_repositories(repo_details)
}

###############################################################################

# pkgs require for running the script (not the packages that are analysed here)
load_packages(c("dplyr", "git2r", "magrittr", "readr", "tibble"))

repo_details_file <- file.path("results", "dev-pkg-repositories.tsv")

run_script(repo_details_file)

###############################################################################
