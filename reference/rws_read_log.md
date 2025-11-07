# Read Log Data Table from a SQLite Database

The table is created if it doesn't exist.

## Usage

``` r
rws_read_log(conn)
```

## Arguments

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

A data frame of the log table

## Examples

``` r
conn <- rws_connect()
rws_read_log(conn)
#> # A tibble: 0 × 5
#> # ℹ 5 variables: DateTimeUTCLog <dttm>, UserLog <chr>, TableLog <chr>,
#> #   CommandLog <chr>, NRowLog <int>
rws_write(rws_data, exists = FALSE, conn = conn)
if (FALSE) { # \dontrun{
rws_read_log(conn)
} # }
rws_disconnect(conn)
```
