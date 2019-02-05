#' @import rex
#' @import methods
#' @importFrom utils tail getParseData
#' @include lintr_utils.R
NULL

# need to register rex shortcuts as globals to avoid CRAN check errors
rex::register_shortcuts("dupree")

utils::globalVariables("from", "dupree")
