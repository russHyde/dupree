#' @importFrom   methods   is
as_dups <- function(x) {
  if (!is.data.frame(x) && !methods::is(x, "dups")) {
    stop("Can only convert 'data.frame' and 'dups' to 'dups'")
  }
  if (methods::is(x, "dups")) {
    return(x)
  }
  structure(
    list(dups_df = x),
    class = "dups"
  )
}

#' as.data.frame method for `dups` class
#'
#' @inheritParams   base::as.data.frame
#' @export
#'
as.data.frame.dups <- function(x, ...) {
  as.data.frame(x[["dups_df"]])
}

#' convert a `dups` object to a `tibble`
#'
#' @inheritParams   tibble::as_tibble
#' @importFrom   tibble        as_tibble
#'
#' @exportS3Method
#'

# nolint start
as_tibble.dups <- function(x, ...) {
  tibble::as_tibble(x[["dups_df"]])
}
# nolint end

#' @export
tibble::as_tibble

#' print method for `dups` class
#'
#' @inheritParams   base::print
#' @export
#'

# nocov start
print.dups <- function(x, ...) {
  print(as_tibble(x))
  invisible(x)
}
# nocov end
