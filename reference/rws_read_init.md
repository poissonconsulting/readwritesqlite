# Read Initialization Data table from a SQLite Database

The table is created if it doesn't exist.

## Usage

``` r
rws_read_init(conn)
```

## Arguments

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

A data frame of the init table

## Examples

``` r
conn <- rws_connect()
rws_read_init(conn)
#> # A tibble: 0 × 3
#> # ℹ 3 variables: TableInit <chr>, IsInit <int>, SFInit <chr>
rws_write(rws_data, exists = FALSE, conn = conn)
rws_read_init(conn)
#> # A tibble: 1 × 3
#>   TableInit IsInit SFInit
#>   <chr>      <int> <chr> 
#> 1 RWS_DATA       1 NA    
rws_disconnect(conn)
```
