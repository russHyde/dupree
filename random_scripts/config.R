###############################################################################

# Config details for the analysis of development tools packages using {dupree}
# - filepaths etc

###############################################################################

config <- list(
  # Store results summaries here:
  results_dir = file.path("results"),

  # Store results for individual packages in subdirs of this:
  pkg_results_dir = file.path("results", "packages"),

  repo_dir = normalizePath(
    file.path("~", "temp", "dev-tools-analysis"),
    mustWork = FALSE
  ),

  task_view_url = paste(
    "https://raw.githubusercontent.com/ropensci",
    "PackageDevelopment/master/PackageDevelopment.ctv",
    sep = "/"
  ),

  min_block_sizes = c(100, 40), #, 20, 10)

  # The github repo for package `logging` does not conform to standard R
  # package structure, and causes dupree to fail.
  drop = "logging"
)

config <- append(
  config,
  list(
    repo_details_file = file.path(
      config[["results_dir"]], "dev-pkg-respositories.tsv"
    ),
    cran_details_file = file.path(
      config[["results_dir"]], "dev-pkg-table.tsv"
    ),
    all_pkg_benchmarks_file = file.path(
      config[["results_dir"]], "dev-pkg-benchmarks.tsv"
    )
  )
)

###############################################################################
