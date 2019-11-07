## Resubmission
This is the second resubmission of {dupree}. In this version I have:
* Ensured the `\value` tag for function `dupree()` is present in `dupree.Rd`
  (apologies, I had used an incorrect roxygen2 tag in the previous
  resubmission).

* Fixed some typos in the documentation.

In the previous resubmission, I:

* Added some examples to the documentation for `dupree::dupree` these use a
  file that is stored in `inst/extdata` and accessed using `system.file()`

## Test environments
* local Ubuntu (in conda envs), R 3.5.1 and R 3.6.1
* Ubuntu 16.04 (on travis-ci.org), R 3.2.5, 3.3.3, 3.4.4, 3.5.3, 3.6.1 and devel
* Windows (on ci.appveyor.com and by `rhub::check_on_windows()`), R 3.6.1

I did check the package on R-hub's Fedora Linux distribution, but it failed
since 'libxml2' was unavailable and the (transitive) dependency package 'xml2'
could not be installed.

## R CMD check results
There were no ERRORS, WARNINGs or NOTEs

## Downstream dependencies
There are currently no downstream dependencies for this package
