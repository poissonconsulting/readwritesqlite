# Rename SQLite Table

Rename SQLite Table

## Usage

``` r
rws_rename_table(table_name, new_table_name, conn)
```

## Arguments

- table_name:

  A string of the name of the table.

- new_table_name:

  A string of the new name for the table.

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

TRUE

## See also

Other rws_rename:
[`rws_drop_table()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_drop_table.md),
[`rws_rename_column()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_rename_column.md)

## Examples

``` r
conn <- rws_connect()
rws_write(rws_data, exists = FALSE, conn = conn)
rws_list_tables(conn)
#> [1] "rws_data"
rws_rename_table("rws_data", "tableb", conn)
#> [1] TRUE
rws_list_tables(conn)
#> [1] "tableb"
rws_disconnect(conn)
```
