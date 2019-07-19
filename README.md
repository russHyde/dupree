
<!-- README.md is generated from README.Rmd. Please edit the latter -->

[![Travis-CI Build
Status](https://travis-ci.org/russHyde/dupree.svg?branch=master)](https://travis-ci.org/russHyde/dupree)

[![Coverage
Status](https://img.shields.io/codecov/c/github/russHyde/dupree/master.svg)](https://codecov.io/github/russHyde/dupree?branch=master)

# dupree

The goal of `dupree` is to identify chunks / blocks of highly duplicated
code within a set of R scripts.

A very lightweight approach is used:

  - The user provides a set of `*.R` and/or `*.Rmd` files;

  - All R-code in the user-provided files is read and code-blocks are
    identified;

  - The non-trivial symbols from each code-block are retained (for
    instance, really common symbols like `<-`, `,`, `+`, `(` are
    dropped);

  - Similarity between different blocks is calculated using
    stringdist::seq\_sim by longest-common-subsequence (symbol-identity
    is at whole-word level - so “my\_data”, “my\_Data”, “my.data” and
    “myData” are not considered to be identical in the calculation -
    and all non-trivial symbols have equal weight in the similarity
    calculation);

  - Code-blocks pairs (both between and within the files) are returned
    in order of highest similarity

To prevent the results being dominated by high-identity blocks
containing very few symbols (eg, `library(dplyr)`) the user can specify
a `min_block_size`. Any code-block containing at least this many
non-trivial symbols will be kept.

## Installation

You can install `dupree` from github with:

``` r
# install.packages("devtools")
devtools::install_github("russHyde/dupree")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
## basic example code
library(dupree)
files <- dir(pattern = "*.R(md)*$", recursive = TRUE)
dupree(files, min_block_size = 20)
#> # A tibble: 15 x 7
#>    file_a             file_b            block_a block_b line_a line_b score
#>    <chr>              <chr>               <int>   <int>  <int>  <int> <dbl>
#>  1 tests/testthat/te… tests/testthat/t…       2       4      7     95 0.36 
#>  2 R/dupree_classes.R tests/testthat/t…       4       3     50     22 0.327
#>  3 R/dupree_code_enu… tests/testthat/t…       1       5     14    119 0.283
#>  4 R/dupree_number_o… R/dupree_number_…       2       3     24     42 0.265
#>  5 R/dupree_classes.R R/dupree_classes…       4       8     50    169 0.219
#>  6 R/dupree_classes.R R/dupree_classes…       4       6     50    107 0.218
#>  7 tests/testthat/te… tests/testthat/t…       3       5     22     70 0.216
#>  8 R/dupree_code_enu… R/dupree_code_en…       6      12    124    218 0.213
#>  9 tests/testthat/te… tests/testthat/t…       3       4     25     95 0.212
#> 10 R/dupree_code_enu… R/dupree.R             12       2    218     69 0.200
#> 11 R/dupree_code_enu… R/dupree_code_en…       4       6     89    124 0.174
#> 12 R/dupree_classes.R R/dupree_classes…       7       8    141    169 0.173
#> 13 R/dupree_classes.R R/dupree_code_en…       8       3    169     62 0.172
#> 14 R/dupree_classes.R R/dupree_data_va…       2       5     19     45 0.163
#> 15 R/dupree_classes.R tests/testthat/t…       4       2     50      7 0.110
```

Note that you can do something similar using the functions `dupree_dir`
and (if you are analysing a package) `dupree_package`.

``` r
# Analyse all R files except those in the tests directory:
dupree_dir(".", min_block_size = 20, filter = "tests", invert = TRUE)
#> # A tibble: 10 x 7
#>    file_a             file_b            block_a block_b line_a line_b score
#>    <chr>              <chr>               <int>   <int>  <int>  <int> <dbl>
#>  1 ./R/dupree_number… ./R/dupree_numbe…       2       3     24     42 0.265
#>  2 ./R/dupree_classe… ./R/dupree_class…       4       8     50    169 0.219
#>  3 ./R/dupree_classe… ./R/dupree_class…       4       6     50    107 0.218
#>  4 ./R/dupree_code_e… ./R/dupree_code_…       6      12    124    218 0.213
#>  5 ./R/dupree_code_e… ./R/dupree.R           12       2    218     69 0.200
#>  6 ./R/dupree_code_e… ./R/dupree_code_…       4       6     89    124 0.174
#>  7 ./R/dupree_classe… ./R/dupree_class…       7       8    141    169 0.173
#>  8 ./R/dupree_classe… ./R/dupree_code_…       8       3    169     62 0.172
#>  9 ./R/dupree_classe… ./R/dupree_data_…       2       5     19     45 0.163
#> 10 ./R/dupree_classe… ./R/dupree_code_…       4       1     50     14 0.141
```

``` r
# Analyse all R source code in the package (ignoring the tests directory)
dupree_package(".", min_block_size = 20)
#> # A tibble: 10 x 7
#>    file_a             file_b            block_a block_b line_a line_b score
#>    <chr>              <chr>               <int>   <int>  <int>  <int> <dbl>
#>  1 ./R/dupree_number… ./R/dupree_numbe…       2       3     24     42 0.265
#>  2 ./R/dupree_classe… ./R/dupree_class…       4       8     50    169 0.219
#>  3 ./R/dupree_classe… ./R/dupree_class…       4       6     50    107 0.218
#>  4 ./R/dupree_code_e… ./R/dupree_code_…       6      12    124    218 0.213
#>  5 ./R/dupree_code_e… ./R/dupree.R           12       2    218     69 0.200
#>  6 ./R/dupree_code_e… ./R/dupree_code_…       4       6     89    124 0.174
#>  7 ./R/dupree_classe… ./R/dupree_class…       7       8    141    169 0.173
#>  8 ./R/dupree_classe… ./R/dupree_code_…       8       3    169     62 0.172
#>  9 ./R/dupree_classe… ./R/dupree_data_…       2       5     19     45 0.163
#> 10 ./R/dupree_classe… ./R/dupree_code_…       4       1     50     14 0.141
```
