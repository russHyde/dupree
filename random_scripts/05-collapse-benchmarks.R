###############################################################################

define_pkg_timings_paths <- function(packages, pkg_results_dir) {
  tibble(
    package = packages,
    path = file.path(pkg_results_dir, package, "dupree_timings.rds")
  )
}

###############################################################################

format_benchmark <- function(table) {
  list_cols <- which(map_lgl(table, is.list))
  table[, list_cols] <- NA
  as_tibble(table)
}

collapse_benchmarks <- function(tables) {
  # should be a named list of bench::press result tables
  stopifnot(is.list(tables) && !is.null(names(tables)))
  map_df(tables, format_benchmark, .id = "package")
}

###############################################################################

# --

main <- function(
    repo_details_file, results_dir, pkg_results_dir, output_file
) {
  repo_details <- readr::read_tsv(
    repo_details_file, col_types = readr::cols(.default = "c")
  )

  # For each repo, there is a .rds file containing bench::press results
  # 
  # Combine these results into a single table
  
  pkg_timings_paths <- define_pkg_timings_paths(
    repo_details[["package"]], pkg_results_dir
  )

  bench_results <- Map(
    function(pkg, path) read_rds(path),
    pkg_timings_paths[["package"]],
    pkg_timings_paths[["path"]]
  )
  
  # Combine the benchmark data for each package into a single table
  # - we suppress the `Vectorizing 'bench_time' ...` warnings
  summarised_results <- suppressWarnings(
    collapse_benchmarks(bench_results)
  )

  readr::write_tsv(summarised_results, output_file)
}

###############################################################################

source("utils.R")
source("config.R")

###############################################################################

# pkgs require for running the script (not the packages that are analysed here)
load_packages(
  c("bench", "dplyr", "magrittr", "purrr", "readr", "tibble")
)

main(
  repo_details_file = config[["repo_details_file"]],
  results_dir = config[["results_dir"]],
  pkg_results_dir = config[["pkg_results_dir"]],
  output_file = config[["all_pkg_benchmarks_file"]]
)

# 
# ggplot(df, aes(x = median, y = factor(package, levels =
#   unique(package[order(median)])))) + geom_point(aes(col = min_block_size))

###############################################################################
