
<!-- README.md is generated from README.Rmd. Please edit that file -->

# readwritesqlite <img src="man/figures/logo.png" style="float: right" />

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/poissonconsulting/readwritesqlite/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/poissonconsulting/readwritesqlite/actions/workflows/R-CMD-check.yaml)
[![Coverage
status](https://codecov.io/gh/poissonconsulting/readwritesqlite/branch/master/graph/badge.svg)](https://codecov.io/github/poissonconsulting/readwritesqlite?branch=master)
[![License:
MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![CRAN
status](https://www.r-pkg.org/badges/version/readwritesqlite)](https://cran.r-project.org/package=readwritesqlite)
![CRAN Downloads](http://cranlogs.r-pkg.org/badges/readwritesqlite)
<!-- badges: end -->

# readwritesqlite

SQLite databases are a simple, powerful way to validate, query and store
related data frames particularly when used with the RSQLite package.
However, current solutions do not preserve (or check) meta data, log
changes or provide particularly useful error messages.

`readwritesqlite` is an R package that by default

-   preserves (and subsequently checks) the following metadata
    -   the class for logical, Date and hms columns
    -   the levels for factors and ordered factors
    -   the time zone for POSIXct columns
    -   the units for unit columns
    -   the projection for sfc columns
    -   the sf column for sf objects
-   logs
    -   the date time
    -   system user
    -   table creation and data insertion or deletion
-   provides informative error messages if
    -   columns are missing
    -   NOT NULL columns contain missing values
    -   PRIMARY KEY column values in the input data are not unique

`readwritesqlite` also allows the user to

-   write environments (or named lists) of data frames (useful for
    populating databases)
-   delete existing data (and meta data) before writing (useful for
    converting an existing database)
-   replace existing data which causes unique or primary key conflicts
    (useful for updating databases)
-   confirm data can be written without committing any changes (useful
    for checking data)
-   check all existing tables are written to (useful for data transfers)
-   rearrange and add levels for factors and add levels for ordered
    factors
-   initialize the meta data for a new table by writing a data frame or
    sf data frame with no rows but logical, Date, factor, ordered,
    POSIXct, sfc or unit columns (useful for creating an empty database
    with additional informative checks)

`readwritesqlite` provides all these features through its `rws_write()`
and `rws_read()` functions.

The `rws_query()` function allows the user to pass a SQL query. By
default, the metadata (except the setting of the sf column) is, if
unambiguously defined, preserved for each column in the final query. To
enable this functionality the user should ensure that a) columns in
tables which will be referenced in the same query should have different
names or identical metadata and b) column names in the final query
should match those in the referenced base tables.

The init, meta and log data are stored in separate tables from the main
data which means that they do not interfere with other ways of
interacting with a SQLite database.

## Installation

To install the latest release from [CRAN](https://cran.r-project.org)

``` r
install.packages("readwritesqlite")
```

To install the developmental version from
[GitHub](https://github.com/poissonconsulting/readwritesqlite)

``` r
# install.packages("remotes")
remotes::install_github("poissonconsulting/readwritesqlite")
```

## Demonstration

Key attribute information is preserved for many classes.

``` r
library(readwritesqlite)

# for nicer printing of data frames
library(tibble)
library(sf)
#> Linking to GEOS 3.10.2, GDAL 3.4.2, PROJ 8.2.1; sf_use_s2() is TRUE

conn <- rws_connect()

rws_data <- readwritesqlite::rws_data
rws_data
#> # A tibble: 3 × 6
#>   logical date       factor ordered posixct             units
#>   <lgl>   <date>     <fct>  <ord>   <dttm>                [m]
#> 1 TRUE    2000-01-01 x      x       2001-01-02 03:04:05  10  
#> 2 FALSE   2001-02-03 y      y       2006-07-08 09:10:11  11.5
#> 3 NA      NA         <NA>   <NA>    NA                   NA

rws_write(rws_data, exists = FALSE, conn = conn)

rws_read_table("rws_data", conn = conn)
#> # A tibble: 3 × 6
#>   logical date       factor ordered posixct             units
#>   <lgl>   <date>     <fct>  <ord>   <dttm>                [m]
#> 1 TRUE    2000-01-01 x      x       2001-01-02 03:04:05  10  
#> 2 FALSE   2001-02-03 y      y       2006-07-08 09:10:11  11.5
#> 3 NA      NA         <NA>   <NA>    NA                   NA
```

The attribute information is stored in the metadata table

``` r
rws_read_meta(conn = conn)
#> # A tibble: 6 × 4
#>   TableMeta ColumnMeta MetaMeta          DescriptionMeta
#>   <chr>     <chr>      <chr>             <chr>          
#> 1 RWS_DATA  DATE       class: Date       <NA>           
#> 2 RWS_DATA  FACTOR     factor: 'x', 'y'  <NA>           
#> 3 RWS_DATA  LOGICAL    class: logical    <NA>           
#> 4 RWS_DATA  ORDERED    ordered: 'y', 'x' <NA>           
#> 5 RWS_DATA  POSIXCT    tz: Etc/GMT+8     <NA>           
#> 6 RWS_DATA  UNITS      units: m          <NA>
```

The user can add descriptions if they wish.

``` r
rws_describe_meta("rws_data", "posixct", "The time of a visit", conn = conn)
rws_describe_meta("rws_data", "units", "The site length.", conn = conn)
rws_read_meta(conn = conn)
#> # A tibble: 6 × 4
#>   TableMeta ColumnMeta MetaMeta          DescriptionMeta    
#>   <chr>     <chr>      <chr>             <chr>              
#> 1 RWS_DATA  DATE       class: Date       <NA>               
#> 2 RWS_DATA  FACTOR     factor: 'x', 'y'  <NA>               
#> 3 RWS_DATA  LOGICAL    class: logical    <NA>               
#> 4 RWS_DATA  ORDERED    ordered: 'y', 'x' <NA>               
#> 5 RWS_DATA  POSIXCT    tz: Etc/GMT+8     The time of a visit
#> 6 RWS_DATA  UNITS      units: m          The site length.
```

The log provides a record of data changes that have been made using
readwritesqlite.

``` r
rws_read_log(conn = conn)
#> # A tibble: 2 x 5
#>   DateTimeUTCLog      UserLog TableLog CommandLog NRowLog
#>   <dttm>              <chr>   <chr>    <chr>        <int>
#> 1 2019-07-07 16:05:10 joe     RWS_DATA CREATE           0
#> 2 2019-07-07 16:05:11 joe     RWS_DATA INSERT           3
```

Don’t forget to disconnect when done.

``` r
rws_disconnect(conn)
```

## Information

For more information on using `readwritesqlite` see the vignette
[using-readwritesqlite](https://poissonconsulting.github.io/readwritesqlite/articles/using-readwritesqlite.html).

## Contribution

Please report any
[issues](https://github.com/poissonconsulting/readwritesqlite/issues).

[Pull
requests](https://github.com/poissonconsulting/readwritesqlite/pulls)
are always welcome.

## Code of Conduct

Please note that the readwritesqlite project is released with a
[Contributor Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
