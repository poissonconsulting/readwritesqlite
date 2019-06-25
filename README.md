
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis build
status](https://travis-ci.com/poissonconsulting/readwritesqlite.svg?branch=master)](https://travis-ci.com/poissonconsulting/readwritesqlite)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/poissonconsulting/readwritesqlite?branch=master&svg=true)](https://ci.appveyor.com/project/poissonconsulting/readwritesqlite)
[![Coverage
status](https://codecov.io/gh/poissonconsulting/readwritesqlite/branch/master/graph/badge.svg)](https://codecov.io/github/poissonconsulting/readwritesqlite?branch=master)
[![License:
MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![CRAN
status](https://www.r-pkg.org/badges/version/readwritesqlite)](https://cran.r-project.org/package=readwritesqlite)
<!-- badges: end -->

# readwritesqlite

SQLite databases are a simple, powerful way to validate, query and store
related data frames particularly when used with the RSQLite package.
However, current solutions do not preserve (or check) meta data, log
changes or provide particularly useful error messages.

`readwritesqlite` is an R package that by default

  - preserves (and subsequently checks) the following metadata
      - the class for logical, Date and hms columns
      - the levels for factors and ordered factors
      - the time zone for POSIXct columns
      - the units for unit columns
      - the projection for sfc columns
      - the sf column for sf objects
  - logs
      - the date time
      - system user
      - table creation and data insertion or deletion
  - provides informative error messages if
      - columns are missing
      - NOT NULL columns contain missing values
      - PRIMARY KEY column values in the input data are not unique

`readwritesqlite` also allows the user to

  - write environments (or named lists) of data frames (useful for
    populating databases)
  - delete existing data (and meta data) before writing (useful for
    converting an existing database)
  - replace existing data which causes unique or primary key conflicts
    (useful for updating databases)
  - confirm data can be written without commiting any changes (useful
    for checking data)
  - check all existing tables are written to (useful for data transfers)
  - rearrange and add levels for factors and add levels for ordered
    factors
  - initialize the meta data for a new table by writing a data frame or
    sf data frame with no rows but logical, Date, factor, ordered,
    POSIXct, sfc or unit columns (useful for creating an empty database
    with additional informative checks)

`readwritesqlite` provides all these features through its `rws_write()`
and `rws_read()` functions.

The `rws_query()` function allows the user to pass a SQL query. By
default, the metadata (except the setting of the sf column) is, if
unambigously defined, preserved for each column in the final query. To
enable this functionality the user should ensure that a) columns in
tables which will be referenced in the same query should have different
names or identical metadata and b) column names in the final query
should match those in the referenced base tables.

The init, meta and log data are stored in separate tables from the main
data which means that they do not interfere with other ways of
interacting with a SQLite database.

## Demonstration

``` r
library(tibble)
library(units)
#> udunits system database from /Library/Frameworks/R.framework/Versions/3.6/Resources/library/units/share/udunits
library(sf)
#> Linking to GEOS 3.6.1, GDAL 2.1.3, PROJ 4.9.3

library(readwritesqlite)

conn <- rws_connect()

rws_data
#> Simple feature collection with 3 features and 6 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 0 ymin: 0 xmax: 1 ymax: 1
#> epsg (SRID):    4326
#> proj4string:    +proj=longlat +datum=WGS84 +no_defs
#> # A tibble: 3 x 7
#>   logical date       factor ordered posixct             units    geometry
#>   <lgl>   <date>     <fct>  <ord>   <dttm>                [m] <POINT [°]>
#> 1 TRUE    2000-01-01 x      x       2001-01-02 03:04:05  10.0       (0 1)
#> 2 FALSE   2001-02-03 y      y       2006-07-08 09:10:11  11.5       (1 0)
#> 3 NA      NA         <NA>   <NA>    NA                     NA       (1 1)

rws_write(rws_data, exists = FALSE, conn = conn)

DBI::dbReadTable(conn, "rws_data")
#>   logical  date factor ordered    posixct units   geometry
#> 1       1 10957      x       x  978433445  10.0 blob[21 B]
#> 2       0 11356      y       y 1152378611  11.5 blob[21 B]
#> 3      NA    NA   <NA>    <NA>         NA    NA blob[21 B]

rws_read_table("rws_data", conn = conn)
#> Simple feature collection with 3 features and 6 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 0 ymin: 0 xmax: 1 ymax: 1
#> epsg (SRID):    4326
#> proj4string:    +proj=longlat +datum=WGS84 +no_defs
#> # A tibble: 3 x 7
#>   logical date       factor ordered posixct             units    geometry
#>   <lgl>   <date>     <fct>  <ord>   <dttm>                [m] <POINT [°]>
#> 1 TRUE    2000-01-01 x      x       2001-01-02 03:04:05  10.0       (0 1)
#> 2 FALSE   2001-02-03 y      y       2006-07-08 09:10:11  11.5       (1 0)
#> 3 NA      NA         <NA>   <NA>    NA                     NA       (1 1)

rws_disconnect(conn)
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
