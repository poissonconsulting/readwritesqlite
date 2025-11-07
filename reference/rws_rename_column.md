# Rename SQLite Column

Rename SQLite Column

## Usage

``` r
rws_rename_column(table_name, column_name, new_column_name, conn)
```

## Arguments

- table_name:

  A string of the name of the table.

- column_name:

  A string of the column name.

- new_column_name:

  A string of the new name for the column.

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

TRUE

## See also

Other rws_rename:
[`rws_drop_table()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_drop_table.md),
[`rws_rename_table()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_rename_table.md)

## Examples

``` r
conn <- rws_connect()
rws_write(data.frame(x = 1), x_name = "local", exists = FALSE, conn = conn)
rws_read_table("local", conn = conn)
#> # A tibble: 1 × 1
#>       x
#>   <dbl>
#> 1     1
rws_rename_column("local", "x", "Y", conn = conn)
#> [1] TRUE
rws_read_table("local", conn = conn)
#> # A tibble: 1 × 1
#>       Y
#>   <dbl>
#> 1     1
rws_disconnect(conn)
```
