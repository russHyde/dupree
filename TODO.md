# `dupree` TODO notes

## Functions

- `dupree_classes`: `find_best_matches_of_single_block`

- Filter out blocks that have few non-trivial symbols

## Tests

- Tests for number of symbols in each block

## Data-structures

- Suggestion:

    - if score for (`block_a`, `block_b`) is returned, score for (`block_b`,
    `block_a`) should not be returned

## Quicker implementation

- Fastest version:

    - convert to frequency-vector of symbols-used (eg, tidytext / `tf_idf`
    analysis) and just determine distances between block-contents

- Alignment version:

    - run (various) distance functions on the vector-pairs (using
    `stringdist::seq_sim`; note that stringdist is required for
    `lintr/available`)
