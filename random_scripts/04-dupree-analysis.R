###############################################################################

run_script <- function(repo_details_file) {
  repo_details <- readr::read_tsv(
    repo_details_file, col_types = readr::cols(.default = "c")
  )

  # For each repo,
  # For each min_block_size in (10, 20, 40, 100)
  # - Run dupree
  # - Save the results table to a file
  # - Measure the time it takes to run & save (package, min_block_size,
  # time_taken) to a file
  # - Suggest saving the timings in bench::mark results format

  stop("TODO: implement run_script for 04-dupree-analysis.R")
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
