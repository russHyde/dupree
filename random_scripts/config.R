###############################################################################

# Config details for the analysis of development tools packages using {dupree}
# - filepaths etc

###############################################################################

config <- list(
  results_dir = file.path("results"),
  repo_dir = normalizePath(
    file.path("~", "temp", "dev-tools-analysis"),
    mustWork = FALSE
  ),
  task_view_url = paste(
    "https://raw.githubusercontent.com/ropensci",
    "PackageDevelopment/master/PackageDevelopment.ctv",
    sep = "/"
  )
)

config <- append(
  config,
  list(
    repo_details_file = file.path(
      config[["results_dir"]], "dev-pkg-respositories.tsv"
    ),
    cran_details_file = file.path(
      config[["results_dir"]], "dev-pkg-table.tsv"
    )
  )
)

###############################################################################
