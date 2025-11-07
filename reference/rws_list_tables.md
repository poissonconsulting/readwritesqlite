# Table Names

Gets the table names excluding the names of the meta and log tables.

## Usage

``` r
rws_list_tables(conn)
```

## Arguments

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

A character vector of table names.

## Examples

``` r
conn <- rws_connect()
rws_list_tables(conn)
#> character(0)
rws_write(rws_data, exists = FALSE, conn = conn)
rws_list_tables(conn)
#> [1] "rws_data"
rws_disconnect(conn)
```
