# Read Meta Data table from a SQLite Database

The table is created if it doesn't exist.

## Usage

``` r
rws_read_meta(conn)
```

## Arguments

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

A data frame of the meta table

## Examples

``` r
conn <- rws_connect()
rws_read_meta(conn)
#> # A tibble: 0 × 4
#> # ℹ 4 variables: TableMeta <chr>, ColumnMeta <chr>, MetaMeta <chr>,
#> #   DescriptionMeta <chr>
rws_write(rws_data, exists = FALSE, conn = conn)
rws_read_meta(conn)
#> # A tibble: 6 × 4
#>   TableMeta ColumnMeta MetaMeta          DescriptionMeta
#>   <chr>     <chr>      <chr>             <chr>          
#> 1 RWS_DATA  DATE       class: Date       NA             
#> 2 RWS_DATA  FACTOR     factor: 'x', 'y'  NA             
#> 3 RWS_DATA  LOGICAL    class: logical    NA             
#> 4 RWS_DATA  ORDERED    ordered: 'y', 'x' NA             
#> 5 RWS_DATA  POSIXCT    tz: Etc/GMT+8     NA             
#> 6 RWS_DATA  UNITS      units: m          NA             
rws_disconnect(conn)
```
