
<!-- README.md is generated from README.Rmd. Please edit the latter -->
<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/russHyde/dupree/branch/main/graph/badge.svg)](https://codecov.io/gh/russHyde/dupree?branch=main)
[![R-CMD-check](https://github.com/russHyde/dupree/workflows/R-CMD-check/badge.svg)](https://github.com/russHyde/dupree/actions)
<!-- badges: end -->

# dupree

The goal of `dupree` is to identify chunks / blocks of highly duplicated
code within a set of R scripts.

A very lightweight approach is used:

- The user provides a set of `*.R` and/or `*.Rmd` files;

- All R-code in the user-provided files is read and code-blocks are
  identified;

- The non-trivial symbols from each code-block are retained (for
  instance, really common symbols like `<-`, `,`, `+`, `(` are dropped);

- Similarity between different blocks is calculated using
  `stringdist::seq_sim` by longest-common-subsequence (symbol-identity
  is at whole-word level - so “my_data”, “my_Data”, “my.data” and
  “myData” are not considered to be identical in the calculation - and
  all non-trivial symbols have equal weight in the similarity
  calculation);

- Code-blocks pairs (both between and within the files) are returned in
  order of highest similarity

To prevent the results being dominated by high-identity blocks
containing very few symbols (eg, `library(dplyr)`) the user can specify
a `min_block_size`. Any code-block containing at least this many
non-trivial symbols will be kept.

## Installation

You can install `dupree` from github with:

``` r
if (!"dupree" %in% installed.packages()) {
  # Alternatively:
  # install.packages("dupree")
  remotes::install_github("russHyde/dupree")
}
```

## Example

To run `dupree` over a set of R files, you can use the `dupree()`,
`dupree_dir()` or `dupree_package()` functions. For example, to identify
duplication within all of the `.R` and `.Rmd` files for the `dupree`
package you could run the following:

``` r
## basic example code
library(dupree)

files <- dir(pattern = "*.R(md)*$", recursive = TRUE)

dupree(files)
#> # A tibble: 14 × 7
#>    file_a                           file_b block_a block_b line_a line_b   score
#>    <chr>                            <chr>    <int>   <int>  <int>  <int>   <dbl>
#>  1 R/dupree_classes.R               tests…      33       8     57     13 0.296  
#>  2 tests/testthat/test_dupree_clas… tests…       8      10     13    118 0.248  
#>  3 R/dupree_classes.R               R/dup…      33      61     57    117 0.218  
#>  4 tests/testthat/test_dupree_clas… tests…       8      11     13     64 0.216  
#>  5 R/dupree_classes.R               R/dup…      33      88     57    180 0.215  
#>  6 tests/testthat/test_dupree_clas… tests…      11       1     64      1 0.185  
#>  7 tests/testthat/testdata/anRpack… tests…       2       1    132      1 0.172  
#>  8 R/dupree.R                       R/dup…     111      33    124     57 0.146  
#>  9 tests/testthat/test_dupree_clas… tests…       8       6     13     25 0.120  
#> 10 R/dupree.R                       tests…     111       4    124      4 0.114  
#> 11 R/dupree_classes.R               R/dup…      88      48    180     90 0.111  
#> 12 R/dupree_classes.R               prese…      61      28    117    316 0.105  
#> 13 tests/testthat/test-dupree_dir_… tests…       3       6     11     25 0.0972 
#> 14 R/dupree_code_enumeration.R      tests…      48       1     90      1 0.00298
```

Any top-level code blocks that contain at least 40 non-trivial tokens
are included in the above analysis (a token being a function or variable
name, an operator etc; but ignoring comments, white-space and some
really common tokens: `[](){}-+$@:,=`, `<-`, `&&` etc). To be more
restrictive, you could consider larger code-blocks (increase
`min_block_size`) within just the `./R/` source code directory:

``` r
# R-source code files in the ./R/ directory of the dupree package:
source_files <- dir(path = "./R", pattern = "*.R(md)*$", full.names = TRUE)

# analyse any code blocks that contain at least 50 non-trivial tokens
dupree(source_files, min_block_size = 50)
#> # A tibble: 1 × 7
#>   file_a               file_b               block_a block_b line_a line_b score
#>   <chr>                <chr>                  <int>   <int>  <int>  <int> <dbl>
#> 1 ./R/dupree_classes.R ./R/dupree_classes.R      61      88    117    180 0.104
```

For each (sufficiently big) code block in the provided files, `dupree`
will return the code-block that is most-similar to it (although any
given block may be present in the results multiple times if it is the
closest match for several other code blocks).

Code block pairs with a higher `score` value are more similar. `score`
lies in the range \[0, 1\]; and is calculated by the
[`stringdist`](https://github.com/markvanderloo/stringdist) package:
matching occurs at the token level: the token “my_data” is no more
similar to the token “myData” than it is to “x”.

If you find code-block-pairs with a similarity score much greater than
0.5 there is probably some commonality that could be abstracted away.

------------------------------------------------------------------------

Note that you can do something similar using the functions `dupree_dir`
and (if you are analysing a package) `dupree_package`.

``` r
# Analyse all R files in the R/ directory:
dupree_dir(".", filter = "R/")
#> # A tibble: 6 × 7
#>   file_a                            file_b block_a block_b line_a line_b   score
#>   <chr>                             <chr>    <int>   <int>  <int>  <int>   <dbl>
#> 1 ./R/dupree_classes.R              ./R/d…      33      61     57    117 0.218  
#> 2 ./R/dupree_classes.R              ./R/d…      33      88     57    180 0.215  
#> 3 ./tests/testthat/testdata/anRpac… ./tes…       2       1    132      1 0.172  
#> 4 ./R/dupree.R                      ./R/d…     111      33    124     57 0.146  
#> 5 ./R/dupree_classes.R              ./R/d…      88      48    180     90 0.111  
#> 6 ./R/dupree_code_enumeration.R     ./tes…      48       1     90      1 0.00298
```

``` r
# Analyse all R files except those in the tests / presentations directories:
# `dupree_dir` uses grep-like arguments
dupree_dir(
  ".",
  filter = "tests|presentations", invert = TRUE
)
#> # A tibble: 4 × 7
#>   file_a               file_b                block_a block_b line_a line_b score
#>   <chr>                <chr>                   <int>   <int>  <int>  <int> <dbl>
#> 1 ./R/dupree_classes.R ./R/dupree_classes.R       33      61     57    117 0.218
#> 2 ./R/dupree_classes.R ./R/dupree_classes.R       33      88     57    180 0.215
#> 3 ./R/dupree.R         ./R/dupree_classes.R      111      33    124     57 0.146
#> 4 ./R/dupree_classes.R ./R/dupree_code_enum…      88      48    180     90 0.111
```

``` r
# Analyse all R source code in the package (only looking at the ./R/ directory)
dupree_package(".")
#> # A tibble: 6 × 7
#>   file_a                            file_b block_a block_b line_a line_b   score
#>   <chr>                             <chr>    <int>   <int>  <int>  <int>   <dbl>
#> 1 ./R/dupree_classes.R              ./R/d…      33      61     57    117 0.218  
#> 2 ./R/dupree_classes.R              ./R/d…      33      88     57    180 0.215  
#> 3 ./tests/testthat/testdata/anRpac… ./tes…       2       1    132      1 0.172  
#> 4 ./R/dupree.R                      ./R/d…     111      33    124     57 0.146  
#> 5 ./R/dupree_classes.R              ./R/d…      88      48    180     90 0.111  
#> 6 ./R/dupree_code_enumeration.R     ./tes…      48       1     90      1 0.00298
```
