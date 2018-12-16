
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

`readwritesqlite` is an R package that

  - preserves
      - the time zone for POSIXct columns
      - the projection for sfc columns
      - the sf column for sf objects
      - the units for unit columns
      - the class for logical and Date columns
      - the levels for factors and ordered factors
  - logs
      - the date time
      - system user
      - table creation and data insertion or deletion
  - provides informative error messages if
      - columns are missing (extra columns are silently ignored and the
        remaining columns correctly ordered)
      - NOT NULL columns contain missing values
      - PRIMARY KEY column values in the input data are not unique

`readwritesqlite` also allows the user to

  - write named lists or environments of data frames
  - rearrange and add levels for factors and add levels for ordered
    factors
  - delete existing data (and meta data) before writing
  - confirm data can be written without commiting any changes
  - check all existing tables are written to

`readwritesqlite` provides all these features through its
`rws_write_sqlite()` and `rws_read_sqlite()` functions. The meta and log
data are stored in separate tables from the main data which means that
they do not interfere with other ways of interacting with a SQLite
database.

## Demonstration

``` r
library(readwritesqlite)
conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")

rws_data
#>   logical       date factor ordered             posixct units geometry
#> 1    TRUE 2000-01-01      x       x 2001-01-02 03:04:05  10.0     0, 1
#> 2   FALSE 2001-02-03      y       y 2006-07-08 09:10:11  11.5     1, 0
#> 3      NA       <NA>   <NA>    <NA>                <NA>    NA     1, 1

rws_write_sqlite(rws_data, exists = FALSE, conn = conn)

rws_read_sqlite("rws_data", conn = conn)
#> $rws_data
#> # A tibble: 3 x 7
#>   logical date       factor ordered posixct             units
#>   <lgl>   <date>     <fct>  <ord>   <dttm>              <S3:>
#> 1 TRUE    2000-01-01 x      x       2001-01-02 03:04:05 10.0…
#> 2 FALSE   2001-02-03 y      y       2006-07-08 09:10:11 11.5…
#> 3 NA      NA         <NA>   <NA>    NA                  "  N…
#> # ... with 1 more variable: geometry <POINT [°]>

DBI::dbDisconnect(conn)
```

## Information

For more information on using `readwritesqlite` see the vignette
[using-readwritesqlite](https://poissonconsulting.github.io/readwritesqlite/articles/using-readwritesqlite.html).

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
