# Drop SQLite Table

Drops SQLite table using DROP TABLE.

## Usage

``` r
rws_drop_table(table_name, conn)
```

## Arguments

- table_name:

  A string of the name of the table.

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

TRUE

## Details

Also drops rows from meta and init tables.

## References

<https://www.sqlite.org/lang_droptable.html>

## See also

Other rws_rename:
[`rws_rename_column()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_rename_column.md),
[`rws_rename_table()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_rename_table.md)

## Examples

``` r
conn <- rws_connect()
rws_write(rws_data, exists = FALSE, conn = conn)
rws_list_tables(conn)
#> [1] "rws_data"
rws_drop_table("rws_data", conn = conn)
#> [1] TRUE
rws_list_tables(conn)
#> character(0)
rws_disconnect(conn)
```
