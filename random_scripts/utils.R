###############################################################################

load_packages <- function(pkgs) {
  for (pkg in pkgs) {
    suppressPackageStartupMessages(
      library(pkg, character.only = TRUE)
    )
  }
}

###############################################################################
