has_description <- function(path) {
  file.exists(file.path(path, "DESCRIPTION"))
}

has_r_source_dir <- function(path) {
  dir.exists(file.path(path, "R"))
}
