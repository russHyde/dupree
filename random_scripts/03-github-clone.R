###############################################################################

# Download lots of R packages from remote to local repositories

###############################################################################

clone_repositories <- function(x) {
  stop("TODO: clone_repositories() function")

  # Clone each package from its remote to its local repo (but only if we
  # haven't already cloned it)
}

###############################################################################

run_script <- function(repo_details_file) {
  # Takes a table of CRAN packages of the form (package-name, remote-repo,
  # local-repo) and clones each package from it's remote location to the
  # specified local location.

  repo_details <- readr::read_tsv(
    repo_details_file, col_types = readr::cols(.default = "c")
  )

  clone_repositories(repo_details)
}

###############################################################################

source("utils.R")
source("config.R")

###############################################################################

# pkgs require for running the script (not the packages that are analysed here)
load_packages(c("dplyr", "git2r", "magrittr", "readr", "tibble"))

run_script(
  repo_details_file = config[["repo_details_file"]]
)

###############################################################################
