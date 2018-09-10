# `dupree` TODO notes

## Data-structures

- How should the results be returned?

- Current datastructure: list(scores, blocks)

    - scores is tibble[score, subject, pattern]

- Want:

    - scores should be [file_a, file_b, line_a, line_b, score]
    
    - if score for (block_a, block_b) is returned, score for (block_b, block_a)
    should not be returned

## Multiple files

- Import all files and run dupr across all blocks in all files

## Quicker implementation

- Strip out all "()<- {}[]=" type symbols before alignment

    - eg, filter on the 'token' values (keep SYMBOL,FUNCTION,SYMBOL_FORMALS
    etc) that are returned by lintr::get_source_expressions::parse_content

- Fastest version:

    - convert to frequency-vector of symbols-used (eg, tidytext / tf_idf
    analysis) and just determine distances between block-contents

- Alignment version:

    - convert the symbols-used into a vector of integers (corresponding to
    factor levels)
    
    - run Levenshtein distance on the vector-pairs (using stringdist::seq_sim;
    note that stringdist is required for lintr/available)
