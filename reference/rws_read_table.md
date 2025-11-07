# Read a Table from a SQLite Database

Read a Table from a SQLite Database

## Usage

``` r
rws_read_table(x, meta = TRUE, conn)
```

## Arguments

- x:

  A string of the table name.

- meta:

  A flag specifying whether to preserve meta data.

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

A data frame of the table.

## Examples

``` r
conn <- rws_connect()
rws_write(rws_data, exists = FALSE, conn = conn)
rws_write(rws_data[c("date", "ordered")],
  x_name = "data2", exists = FALSE, conn = conn
)
rws_read_table("data2", conn = conn)
#> # A tibble: 3 × 2
#>   date       ordered
#>   <date>     <ord>  
#> 1 2000-01-01 x      
#> 2 2001-02-03 y      
#> 3 NA         NA     
rws_disconnect(conn)
```
