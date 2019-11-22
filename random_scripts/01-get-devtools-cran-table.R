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

run_script <- function(task_view_url, results_file) {
  # We identify packages that
  # - are currently on CRAN
  # - have a github URL
  # - are mentioned on the ROpenSci software development task view

  stopifnot(dir.exists(dirname(results_file)))

  cran_gh <- import_github_cran_table()
  dev_packages <- import_dev_package_names(task_view_url)

  dev_pkg_table <- dplyr::filter(
    cran_gh, Package %in% dev_packages
  )

  readr::write_tsv(dev_pkg_table, results_file)
}

###############################################################################

source("utils.R")
source("config.R")

###############################################################################

# pkgs require for running the script (not the packages that are analysed here)
load_packages(c("dplyr", "tibble", "magrittr", "readr", "xml2"))

run_script(
  task_view_url = config[["task_view_url"]],
  results_file = config[["cran_details_file"]]
)

###############################################################################
