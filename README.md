
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
#> # A tibble: 20 x 7
#>    file_a            file_b            block_a block_b line_a line_b score
#>    <chr>             <chr>               <int>   <int>  <int>  <int> <dbl>
#>  1 tests/testthat/t… tests/testthat/t…       4       8      7     95 0.36 
#>  2 tests/testthat/t… tests/testthat/t…       8       4     95      7 0.36 
#>  3 R/dupree_classes… tests/testthat/t…      13      11     35     22 0.34 
#>  4 tests/testthat/t… R/dupree_classes…      11      13     22     35 0.34 
#>  5 R/dupree_number_… R/dupree_number_…      16      17     24     42 0.265
#>  6 R/dupree_number_… R/dupree_number_…      17      16     42     24 0.265
#>  7 tests/testthat/t… tests/testthat/t…      14      11     70     22 0.246
#>  8 R/dupree_classes… R/dupree_classes…      25      13     75     35 0.242
#>  9 R/dupree_code_en… R/dupree_code_en…      41      72    104    174 0.222
#> 10 R/dupree_code_en… R/dupree_code_en…      72      41    174    104 0.222
#> 11 R/dupree_classes… R/dupree_code_en…      38      32    124     54 0.215
#> 12 R/dupree_code_en… R/dupree_classes…      32      38     54    124 0.215
#> 13 tests/testthat/t… tests/testthat/t…       6       8     25     95 0.212
#> 14 R/dupree.R        R/dupree_code_en…      57      72     69    174 0.200
#> 15 R/dupree_classes… R/dupree_classes…      30      38    106    124 0.198
#> 16 R/dupree_code_en… R/dupree_code_en…      35      41     77    104 0.179
#> 17 R/dupree_classes… R/dupree_data_va…       8      22     15     41 0.163
#> 18 R/dupree_data_va… R/dupree_classes…      22       8     41     15 0.163
#> 19 R/dupree_code_en… tests/testthat/t…       7      11     10     22 0.162
#> 20 tests/testthat/t… R/dupree_classes…       4      13      7     35 0.127
```

Note that you can do something similar using the functions `dupree_dir`
and (if you are analysing a package) `dupree_package`.

``` r
# Analyse all R files except those in the tests directory:
dupree_dir(".", min_block_size = 20, filter = "tests", invert = TRUE)
#> # A tibble: 14 x 7
#>    file_a            file_b            block_a block_b line_a line_b score
#>    <chr>             <chr>               <int>   <int>  <int>  <int> <dbl>
#>  1 ./R/dupree_numbe… ./R/dupree_numbe…      16      17     24     42 0.265
#>  2 ./R/dupree_numbe… ./R/dupree_numbe…      17      16     42     24 0.265
#>  3 ./R/dupree_class… ./R/dupree_class…      13      25     35     75 0.242
#>  4 ./R/dupree_class… ./R/dupree_class…      25      13     75     35 0.242
#>  5 ./R/dupree_code_… ./R/dupree_code_…      41      72    104    174 0.222
#>  6 ./R/dupree_code_… ./R/dupree_code_…      72      41    174    104 0.222
#>  7 ./R/dupree_class… ./R/dupree_code_…      38      32    124     54 0.215
#>  8 ./R/dupree_code_… ./R/dupree_class…      32      38     54    124 0.215
#>  9 ./R/dupree.R      ./R/dupree_code_…      57      72     69    174 0.200
#> 10 ./R/dupree_class… ./R/dupree_class…      30      38    106    124 0.198
#> 11 ./R/dupree_code_… ./R/dupree_code_…      35      41     77    104 0.179
#> 12 ./R/dupree_class… ./R/dupree_data_…       8      22     15     41 0.163
#> 13 ./R/dupree_data_… ./R/dupree_class…      22       8     41     15 0.163
#> 14 ./R/dupree_code_… ./R/dupree_class…       7      13     10     35 0.16
```

``` r
# Analyse all R source code in the package (ignoring the tests directory)
dupree_package(".", min_block_size = 20)
#> # A tibble: 14 x 7
#>    file_a            file_b            block_a block_b line_a line_b score
#>    <chr>             <chr>               <int>   <int>  <int>  <int> <dbl>
#>  1 ./R/dupree_numbe… ./R/dupree_numbe…      16      17     24     42 0.265
#>  2 ./R/dupree_numbe… ./R/dupree_numbe…      17      16     42     24 0.265
#>  3 ./R/dupree_class… ./R/dupree_class…      13      25     35     75 0.242
#>  4 ./R/dupree_class… ./R/dupree_class…      25      13     75     35 0.242
#>  5 ./R/dupree_code_… ./R/dupree_code_…      41      72    104    174 0.222
#>  6 ./R/dupree_code_… ./R/dupree_code_…      72      41    174    104 0.222
#>  7 ./R/dupree_class… ./R/dupree_code_…      38      32    124     54 0.215
#>  8 ./R/dupree_code_… ./R/dupree_class…      32      38     54    124 0.215
#>  9 ./R/dupree.R      ./R/dupree_code_…      57      72     69    174 0.200
#> 10 ./R/dupree_class… ./R/dupree_class…      30      38    106    124 0.198
#> 11 ./R/dupree_code_… ./R/dupree_code_…      35      41     77    104 0.179
#> 12 ./R/dupree_class… ./R/dupree_data_…       8      22     15     41 0.163
#> 13 ./R/dupree_data_… ./R/dupree_class…      22       8     41     15 0.163
#> 14 ./R/dupree_code_… ./R/dupree_class…       7      13     10     35 0.16
```
