# dupree (development version)

## Breaking changes

* `dupree()`, `dupree_package()` and `dupree_dir()` return an object of class
  `dups`, rather than a data-frame. Methods to convert to data.frame / tibble
  are provided though (#60, @russHyde)

## Minor changes and bug-fixes

* Rewrote a test-helper function that compares two list-column-containing
  tibbles: necessitated by a change in dplyr=1.0 (#65, @russHyde)

* `dupree_package()` asserts that a path has a DESCRIPTION and an R/ subdir
  present (#57, @russHyde)

# dupree 0.2.0

* lintr dependence pinned to lintr=2.0.0 so that non-R-codeblocks and empty R
markdown files can be dealt with cleanly

* Tests that depend on `stringdist::seq_sim` were rewritten to ensure they
consistently pass

* Dependency on deprecated dplyr verbs removed

* Code to prevent double-reporting of code-block pairs was
initiated by @Alanocallaghan

# dupree 0.1.0

* Added a `NEWS.md` file to track changes to the package.
