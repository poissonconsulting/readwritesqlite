# Query SQLite Database

Gets a query from a SQLite database.

## Usage

``` r
rws_query(query, meta = TRUE, conn)
```

## Arguments

- query:

  A string of a SQLite query.

- meta:

  A flag specifying whether to preserve meta data.

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

A data frame of the query.

## Examples

``` r
conn <- rws_connect()
rws_write(rws_data, exists = FALSE, conn = conn)
rws_query("SELECT date, posixct, factor FROM rws_data", conn = conn)
#> # A tibble: 3 × 3
#>   date       posixct             factor
#>   <date>     <dttm>              <fct> 
#> 1 2000-01-01 2001-01-02 03:04:05 x     
#> 2 2001-02-03 2006-07-08 09:10:11 y     
#> 3 NA         NA                  NA    
rws_disconnect(conn)
```
