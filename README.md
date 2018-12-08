
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/poissonconsulting/readwritesqlite.svg?branch=master)](https://travis-ci.org/poissonconsulting/readwritesqlite)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/poissonconsulting/readwritesqlite?branch=master&svg=true)](https://ci.appveyor.com/project/poissonconsulting/readwritesqlite)
[![Coverage
status](https://codecov.io/gh/poissonconsulting/readwritesqlite/branch/master/graph/badge.svg)](https://codecov.io/github/poissonconsulting/readwritesqlite?branch=master)
[![License:
MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

# readwritesqlite

SQLite databases are a simple, powerful way to validate, query and store
related data frames particularly when used with the RSQLite package.
However, current solutions do not preserve meta data, log changes or
provide particularly useful error messages.

## What It Does

`readwritesqlite` is an R package that by default automatically

  - preserves
      - the time zone for POSIXct columns
      - the projection for sfc columns
      - the units for unit columns
      - the class for logical and Date columns
  - logs
      - the date time
      - system user
      - number of rows deleted, or inserted by table
  - provides informative error messages if
      - columns are missing (extra columns are silently ignored and the
        remaining columns correctly ordered)
      - NOT NULL columns contain missing values
      - PRIMARY KEY column values in the input data are not unique

`readwritesqlite` also allows the user to

  - read and write lists of data frames
  - delete existing data before writing
  - confirm data can be written without commiting any changes

## What It Doesn’t Do

`readwritesqlite` does not currently

  - preserve
      - factor levels (because in our experience they invariably end up
        changing)
  - override the default error messages for violations of
      - CHECK constraints
      - UNIQUE constraints
      - FOREIGN KEY constraints (although foreign key constraints are
        enforced when writing)

## Installation

To install the latest development version from the Poisson drat
[repository](https://github.com/poissonconsulting/drat)

``` r
install.packages("drat")
drat::addRepo("poissonconsulting")
install.packages("readwritesqlite")
```

## Contribution

Please report any
[issues](https://github.com/poissonconsulting/readwritesqlite/issues).

[Pull
requests](https://github.com/poissonconsulting/readwritesqlite/pulls)
are always welcome.

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
