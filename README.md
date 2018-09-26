
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Travis-CI Build
Status](https://travis-ci.org/russHyde/dupree.svg?branch=master)](https://travis-ci.org/russHyde/dupree)

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
#> # A tibble: 19 x 7
#>    file_a            file_b            block_a block_b line_a line_b score
#>    <chr>             <chr>               <int>   <int>  <int>  <int> <dbl>
#>  1 tests/testthat/t… tests/testthat/t…       2       4      7     95 0.36 
#>  2 tests/testthat/t… tests/testthat/t…       4       2     95      7 0.36 
#>  3 R/dupree_classes… tests/testthat/t…       4       3     35     22 0.34 
#>  4 tests/testthat/t… R/dupree_classes…       3       4     22     35 0.34 
#>  5 R/dupree_number_… R/dupree_number_…       2       3     24     42 0.265
#>  6 R/dupree_number_… R/dupree_number_…       3       2     42     24 0.265
#>  7 tests/testthat/t… tests/testthat/t…       5       3     70     22 0.246
#>  8 R/dupree_classes… R/dupree_classes…       6       4     73     35 0.242
#>  9 R/dupree_code_en… R/dupree_code_en…       6      12    104    168 0.222
#> 10 R/dupree_code_en… R/dupree_code_en…      12       6    168    104 0.222
#> 11 R/dupree_classes… R/dupree_code_en…       8       3    122     54 0.215
#> 12 R/dupree_code_en… R/dupree_classes…       3       8     54    122 0.215
#> 13 tests/testthat/t… tests/testthat/t…       3       4     25     95 0.212
#> 14 R/dupree_classes… R/dupree_classes…       7       8    104    122 0.198
#> 15 R/dupree_code_en… R/dupree_code_en…       4       6     77    104 0.179
#> 16 R/dupree_classes… R/dupree_data_va…       2       5     15     41 0.163
#> 17 R/dupree_data_va… R/dupree_classes…       5       2     41     15 0.163
#> 18 R/dupree_code_en… tests/testthat/t…       1       3     10     22 0.162
#> 19 tests/testthat/t… R/dupree_classes…       2       4      7     35 0.127
```
