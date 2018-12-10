
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

`readwritesqlite` is an R package that by default automatically

  - preserves
      - the time zone for POSIXct columns
      - the projection for sfc columns
      - the units for unit columns
      - the class for logical and Date columns
      - factor and ordered levels
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
  - rearrange and add factor and ordered levels
  - delete existing data (and meta data) before writing
  - confirm data can be written without commiting any changes

## Demonstration

``` r
library(readwritesqlite)
rws_data
#>   logical       date factor ordered             posixct units geometry
#> 1    TRUE 2000-01-01      x       x 2001-01-02 03:04:05  10.0     0, 1
#> 2   FALSE 2001-02-03      y       y 2006-07-08 09:10:11  11.5     1, 0
#> 3      NA       <NA>   <NA>    <NA>                <NA>    NA     1, 1

conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
rws_write_sqlite(rws_data, conn = conn, exists = FALSE)

rws_read_sqlite_log(conn)
#> # A tibble: 2 x 5
#>   DateTimeUTCLog      UserLog TableLog CommandLog NRowLog
#>   <dttm>              <chr>   <chr>    <chr>        <int>
#> 1 2018-12-10 20:07:15 joe     RWS_DATA CREATE           0
#> 2 2018-12-10 20:07:16 joe     RWS_DATA INSERT           3
rws_read_sqlite_meta(conn)
#> # A tibble: 7 x 4
#>   TableMeta ColumnMeta MetaMeta                            DescriptionMeta
#>   <chr>     <chr>      <chr>                               <chr>          
#> 1 RWS_DATA  DATE       class: Date                         <NA>           
#> 2 RWS_DATA  FACTOR     factor: 'x', 'y'                    <NA>           
#> 3 RWS_DATA  GEOMETRY   proj: +proj=longlat +datum=WGS84 +… <NA>           
#> 4 RWS_DATA  LOGICAL    class: logical                      <NA>           
#> 5 RWS_DATA  ORDERED    ordered: 'y', 'x'                   <NA>           
#> 6 RWS_DATA  POSIXCT    tz: Etc/GMT+8                       <NA>           
#> 7 RWS_DATA  UNITS      units: m                            <NA>

rws_read_sqlite(conn)
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
