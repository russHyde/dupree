## Submission

The prospective release of dplyr=1.0 necessitated an update to the CRAN package
{dupree}. The dplyr change made some dupree-tests fail. The dupree-tests have
been fixed in this update.

A new class has been added to dupree, which introduces a breaking change, hence
the update from v0.2.0 to v0.3.0.

## Test environments

* MacOS via r-hub: x86_64-apple-darwin15.6.0, R 3.6.3
* local Ubuntu R 3.5.1
* Ubuntu 16.04 (on travis-ci.org), R 3.4.4, R 3.5.3, R 3.6.2 and devel
* Windows (on ci.appveyor.com), R 3.6.3

## R CMD check results
There were no ERRORS, WARNINGs or NOTEs

## Downstream dependencies
There are currently no downstream dependencies for this package
