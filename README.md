
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
#> # A tibble: 32 x 7
#>    file_a             file_b            block_a block_b line_a line_b score
#>    <chr>              <chr>               <int>   <int>  <int>  <int> <dbl>
#>  1 tests/testthat/te… tests/testthat/t…       2       4      7     95 0.36 
#>  2 R/dupree_classes.R tests/testthat/t…       4       3     44     22 0.327
#>  3 R/dupree_code_enu… tests/testthat/t…       1       5     14    119 0.283
#>  4 R/dupree_number_o… R/dupree_number_…       2       3     24     42 0.265
#>  5 tests/testthat/te… tests/testthat/t…       3       5     22     70 0.239
#>  6 R/dupree_classes.R R/dupree_classes…       4       6     44    101 0.218
#>  7 R/dupree_code_enu… R/dupree_code_en…       6      12    124    218 0.213
#>  8 tests/testthat/te… tests/testthat/t…       3       4     25     95 0.212
#>  9 R/dupree_code_enu… R/dupree.R             12       2    218     69 0.200
#> 10 R/dupree_classes.R R/dupree_code_en…       4       6     44    124 0.192
#> # … with 22 more rows
```

Note that you can do something similar using the functions `dupree_dir`
and (if you are analysing a package) `dupree_package`.

``` r
# Analyse all R files except those in the tests directory:
dupree_dir(".", min_block_size = 20, filter = "tests", invert = TRUE)
#> # A tibble: 20 x 7
#>    file_a            file_b            block_a block_b line_a line_b  score
#>    <chr>             <chr>               <int>   <int>  <int>  <int>  <dbl>
#>  1 ./R/dupree_numbe… ./R/dupree_numbe…       2       3     24     42 0.265 
#>  2 ./R/dupree_class… ./R/dupree_class…       4       6     44    101 0.218 
#>  3 ./R/dupree_code_… ./R/dupree_code_…       6      12    124    218 0.213 
#>  4 ./R/dupree_code_… ./R/dupree.R           12       2    218     69 0.200 
#>  5 ./R/dupree_class… ./R/dupree_code_…       4       6     44    124 0.192 
#>  6 ./R/dupree_class… ./R/dupree_code_…       9       6    178    124 0.182 
#>  7 ./R/dupree_class… ./R/dupree_class…       4       9     44    178 0.181 
#>  8 ./R/dupree_code_… ./R/dupree_code_…       4       6     89    124 0.174 
#>  9 ./R/dupree_class… ./R/dupree_class…       7       9    135    178 0.168 
#> 10 ./R/dupree_numbe… ./R/dupree.R            3       2     42     69 0.167 
#> 11 ./R/dupree_class… ./R/dupree_data_…       2       5     19     45 0.163 
#> 12 ./R/dupree_class… ./R/dupree_class…       6       7    101    135 0.156 
#> 13 ./R/dupree_class… ./R/dupree_code_…       9       3    178     62 0.154 
#> 14 ./R/dupree_class… ./R/dupree_code_…       4       1     44     14 0.141 
#> 15 ./R/dupree_code_… ./R/dupree_data_…       3       5     62     45 0.140 
#> 16 ./R/dupree_code_… ./R/dupree_code_…       1       6     14    124 0.129 
#> 17 ./R/dupree_code_… ./R/dupree_code_…       3       4     62     89 0.125 
#> 18 ./R/dupree_class… ./R/dupree_class…       2       4     19     44 0.105 
#> 19 ./R/dupree_class… ./R/dupree_numbe…       2       2     19     24 0.0811
#> 20 ./R/dupree_data_… ./R/dupree.R            5       2     45     69 0.0678
```

``` r
# Analyse all R source code in the package (ignoring the tests directory)
dupree_package(".", min_block_size = 20)
#> # A tibble: 20 x 7
#>    file_a            file_b            block_a block_b line_a line_b  score
#>    <chr>             <chr>               <int>   <int>  <int>  <int>  <dbl>
#>  1 ./R/dupree_numbe… ./R/dupree_numbe…       2       3     24     42 0.265 
#>  2 ./R/dupree_class… ./R/dupree_class…       4       6     44    101 0.218 
#>  3 ./R/dupree_code_… ./R/dupree_code_…       6      12    124    218 0.213 
#>  4 ./R/dupree_code_… ./R/dupree.R           12       2    218     69 0.200 
#>  5 ./R/dupree_class… ./R/dupree_code_…       4       6     44    124 0.192 
#>  6 ./R/dupree_class… ./R/dupree_code_…       9       6    178    124 0.182 
#>  7 ./R/dupree_class… ./R/dupree_class…       4       9     44    178 0.181 
#>  8 ./R/dupree_code_… ./R/dupree_code_…       4       6     89    124 0.174 
#>  9 ./R/dupree_class… ./R/dupree_class…       7       9    135    178 0.168 
#> 10 ./R/dupree_numbe… ./R/dupree.R            3       2     42     69 0.167 
#> 11 ./R/dupree_class… ./R/dupree_data_…       2       5     19     45 0.163 
#> 12 ./R/dupree_class… ./R/dupree_class…       6       7    101    135 0.156 
#> 13 ./R/dupree_class… ./R/dupree_code_…       9       3    178     62 0.154 
#> 14 ./R/dupree_class… ./R/dupree_code_…       4       1     44     14 0.141 
#> 15 ./R/dupree_code_… ./R/dupree_data_…       3       5     62     45 0.140 
#> 16 ./R/dupree_code_… ./R/dupree_code_…       1       6     14    124 0.129 
#> 17 ./R/dupree_code_… ./R/dupree_code_…       3       4     62     89 0.125 
#> 18 ./R/dupree_class… ./R/dupree_class…       2       4     19     44 0.105 
#> 19 ./R/dupree_class… ./R/dupree_numbe…       2       2     19     24 0.0811
#> 20 ./R/dupree_data_… ./R/dupree.R            5       2     45     69 0.0678
```
