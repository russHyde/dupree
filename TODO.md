# `dupree` TODO notes

## Functions

- `dupree_classes`: `find_best_matches` and `find_best_matches_of_single_block`

- Filter out blocks that have few non-trivial symbols


## Data-structures

- How should the results be returned?

- Current datastructure: list(scores, blocks)

    - scores is tibble[score, subject, pattern]

- Want:

    - scores should be [file_a, file_b, line_a, line_b, score]
    
    - if score for (block_a, block_b) is returned, score for (block_b, block_a)
    should not be returned

## Quicker implementation

- Fastest version:

    - convert to frequency-vector of symbols-used (eg, tidytext / tf_idf
    analysis) and just determine distances between block-contents

- Alignment version:

    - convert the symbols-used into a vector of integers (corresponding to
    factor levels)
    
    - run Levenshtein distance on the vector-pairs (using stringdist::seq_sim;
    note that stringdist is required for lintr/available)
