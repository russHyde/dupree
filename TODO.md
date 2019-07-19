# `dupree` TODO notes

## Functions

- `dupree_classes`: `find_best_matches_of_single_block`

## Tests

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

## Visualisation

- Although `dupree` should not have to depend on any visualisation packages, it
  would be nice if it could convert a package or a set of files into some a
data structure that could readily be visualised in one of the graph packages
(tidygraph / igraph)

- Suggest making two different types of graphs structures and combining them in
  a single image:

    - Sequential connections between blocks of code in files

    - Duplication connections between blocks of code across the files
