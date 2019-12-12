###############################################################################

# Download lots of R packages from remote to local repositories

###############################################################################

clone_repositories <- function(x) {
  # Clone each package from its remote to its local repo (but only if we
  # haven't already cloned it)
  purrr::walk2(
    x$remote_repo, x$local_repo, git2r::clone
  )
}

###############################################################################

main <- function(repo_details_file) {
  # Takes a table of CRAN packages of the form (package-name, remote-repo,
  # local-repo) and clones each package from it's remote location to the
  # specified local location.

  repo_details <- readr::read_tsv(
    repo_details_file, col_types = readr::cols(.default = "c")
  )

  # Columns of `repo_details`:
  # (package, remote_repo, local_repo)
  stopifnot(
    all(c("package", "remote_repo", "local_repo") %in% colnames(repo_details))
  )

  repo_details %>%
    dplyr::filter(!dir.exists(local_repo)) %>%
    clone_repositories()
}

###############################################################################

source("utils.R")
source("config.R")

###############################################################################

# pkgs require for running the script (not the packages that are analysed here)
load_packages(c("dplyr", "git2r", "magrittr", "purrr", "readr"))

main(
  repo_details_file = config[["repo_details_file"]]
)

###############################################################################
