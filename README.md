
<!-- README.md is generated from README.Rmd. Please edit the latter -->

<!-- badges: start -->

[![Travis-CI Build
Status](https://travis-ci.org/russHyde/dupree.svg?branch=master)](https://travis-ci.org/russHyde/dupree)

[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/russHyde/dupree?branch=master&svg=true)](https://ci.appveyor.com/project/russHyde/dupree)

[![Coverage
Status](https://img.shields.io/codecov/c/github/russHyde/dupree/master.svg)](https://codecov.io/github/russHyde/dupree?branch=master)

<!-- badges: end -->

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
#> # A tibble: 18 x 7
#>    file_a             file_b            block_a block_b line_a line_b score
#>    <chr>              <chr>               <int>   <int>  <int>  <int> <dbl>
#>  1 presentations/cle… presentations/cl…      30      31    353    371 0.930
#>  2 presentations/cle… presentations/cl…      25      26    281    294 0.4  
#>  3 tests/testthat/te… tests/testthat/t…       4       8      7     94 0.36 
#>  4 presentations/cle… presentations/cl…      26      29    294    343 0.321
#>  5 R/dupree_code_enu… tests/testthat/t…      11      10     14    118 0.308
#>  6 R/dupree_classes.R tests/testthat/t…      33       8     54     13 0.296
#>  7 R/dupree_code_enu… R/dupree.R            103      57    195     69 0.230
#>  8 presentations/cle… R/dupree_code_en…      25      64    281    127 0.227
#>  9 tests/testthat/te… tests/testthat/t…       6       8     25     94 0.219
#> 10 R/dupree_classes.R R/dupree_classes…      33      59     54    113 0.218
#> 11 tests/testthat/te… tests/testthat/t…       8      11     13     64 0.216
#> 12 R/dupree_classes.R R/dupree_classes…      33      86     54    176 0.215
#> 13 presentations/cle… presentations/cl…      26      28    294    316 0.208
#> 14 R/dupree_code_enu… R/dupree_code_en…      48      64     90    127 0.176
#> 15 R/dupree_classes.R R/dupree_code_en…      86      40    176     62 0.169
#> 16 R/dupree_classes.R R/dupree_data_va…      17      14     23     24 0.163
#> 17 R/dupree_classes.R R/dupree_classes…      59      67    113    147 0.156
#> 18 R/dupree_classes.R tests/testthat/t…      33       4     54      7 0.110
```

Note that you can do something similar using the functions `dupree_dir`
and (if you are analysing a package) `dupree_package`.

``` r
# Analyse all R files except those in the tests / presentations directories:
dupree_dir(
  ".", min_block_size = 20, filter = "tests|presentations", invert = TRUE
)
#> # A tibble: 9 x 7
#>   file_a             file_b             block_a block_b line_a line_b score
#>   <chr>              <chr>                <int>   <int>  <int>  <int> <dbl>
#> 1 ./R/dupree_code_e… ./R/dupree.R           103      57    195     69 0.230
#> 2 ./R/dupree_classe… ./R/dupree_classe…      33      59     54    113 0.218
#> 3 ./R/dupree_classe… ./R/dupree_classe…      33      86     54    176 0.215
#> 4 ./R/dupree_code_e… ./R/dupree_code_e…      64     103    127    195 0.213
#> 5 ./R/dupree_code_e… ./R/dupree_code_e…      48      64     90    127 0.176
#> 6 ./R/dupree_classe… ./R/dupree_code_e…      86      40    176     62 0.169
#> 7 ./R/dupree_classe… ./R/dupree_data_v…      17      14     23     24 0.163
#> 8 ./R/dupree_classe… ./R/dupree_classe…      59      67    113    147 0.156
#> 9 ./R/dupree_classe… ./R/dupree_code_e…      33      11     54     14 0.141
```

``` r
# Analyse all R source code in the package (only looking at the ./R/ directory)
dupree_package(".", min_block_size = 20)
#> # A tibble: 9 x 7
#>   file_a             file_b             block_a block_b line_a line_b score
#>   <chr>              <chr>                <int>   <int>  <int>  <int> <dbl>
#> 1 ./R/dupree_code_e… ./R/dupree.R           103      57    195     69 0.230
#> 2 ./R/dupree_classe… ./R/dupree_classe…      33      59     54    113 0.218
#> 3 ./R/dupree_classe… ./R/dupree_classe…      33      86     54    176 0.215
#> 4 ./R/dupree_code_e… ./R/dupree_code_e…      64     103    127    195 0.213
#> 5 ./R/dupree_code_e… ./R/dupree_code_e…      48      64     90    127 0.176
#> 6 ./R/dupree_classe… ./R/dupree_code_e…      86      40    176     62 0.169
#> 7 ./R/dupree_classe… ./R/dupree_data_v…      17      14     23     24 0.163
#> 8 ./R/dupree_classe… ./R/dupree_classe…      59      67    113    147 0.156
#> 9 ./R/dupree_classe… ./R/dupree_code_e…      33      11     54     14 0.141
```
