###############################################################################

load_packages <- function(pkgs) {
  for (pkg in pkgs) {
    suppressPackageStartupMessages(
      library(pkg, character.only = TRUE)
    )
  }
}

###############################################################################

contains_github <- function(x) {
  grepl("github\\.com", x)
}

format_cran_table <- function(x) {
  tibble::as_tibble(x[, !duplicated(colnames(x))])
}

import_github_cran_table <- function() {
  # code modified from https://juliasilge.com/blog/mining-cran-description/

  # Download a table containing all the DESCRIPTION fields for the packages on
  # CRAN
  # - then remove duplicated fields
  # - turn it into a tibble
  # - and filter to keep only packages that have a github repo

  # read
  raw_cran <- tools::CRAN_package_db()

  # format & restrict to github repos
  format_cran_table(raw_cran) %>%
    dplyr::filter(contains_github(URL) | contains_github(BugReports))
}

###############################################################################

extract_package_names <- function(xml) {
  # package names are each stored in a <pkg> tag on the task view page
  # and the list of <pkg> tags is stored in a <packagelist> tag

  # extract the package names
  xml %>%
    xml2::xml_find_all("packagelist/pkg") %>%
    xml2::xml_text()
}

import_dev_package_names <- function(url) {
  xml2::read_xml(url) %>%
    extract_package_names()
}

###############################################################################

define_repositories <- function(x) {
  stop("TODO: define_repositories() function")
  # Define a table containing package-name, remote-GH-url and
  # local-repo-filepath (based on the filtered cran table)

}

clone_repositories <- function(x) {
  stop("TODO: clone_packages() function")

  # Clone each package from its remote to its local repo (but only if we
  # haven't already cloned it)
}

###############################################################################

run_script <- function(repo_dir, task_view_url) {
  # download lots of CRAN packages from github
  # the chosen packages relate to package development
  # the repos will be stored in repo_dir
  #
  # we select packages that
  # - are currently on CRAN
  # - have a github URL
  # - are mentioned on the ROpenSci software development task view
  #
  # we download repos using git2r

  stopifnot(dir.exists(repo_dir))

  cran_gh <- import_github_cran_table()
  dev_packages <- import_dev_package_names(task_view_url)

  dev_pkg_table <- dplyr::filter(
    cran_gh, Package %in% dev_packages
  )

  repo_details <- define_repositories(dev_pkg_table)
  clone_repositories(repo_details)

  list(
    dev_pkg_table,
    repo_details
  )
}

###############################################################################

# pkgs require for running the script (not the packages that are analysed here)
load_packages(c("dplyr", "git2r", "tibble", "magrittr", "xml2"))

repo_dump <- normalizePath(
  file.path("~", "temp", "dev-tools-analysis")
)
task_view_url <- paste(
  "https://raw.githubusercontent.com/ropensci",
  "PackageDevelopment/master/PackageDevelopment.ctv",
  sep = "/"
)

run_script(repo_dump, task_view_url)

###############################################################################
