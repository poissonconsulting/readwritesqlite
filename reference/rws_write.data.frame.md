# Write a Data Frame to a SQLite Database

Write a Data Frame to a SQLite Database

## Usage

``` r
# S3 method for class 'data.frame'
rws_write(
  x,
  exists = TRUE,
  delete = FALSE,
  replace = FALSE,
  meta = TRUE,
  log = TRUE,
  commit = TRUE,
  strict = TRUE,
  x_name = substitute(x),
  silent = getOption("rws.silent", FALSE),
  conn,
  ...
)
```

## Arguments

- x:

  A data frame.

- exists:

  A flag specifying whether the table(s) must already exist.

- delete:

  A flag specifying whether to delete existing rows before inserting
  data. If `meta = TRUE` the meta data is deleted.

- replace:

  A flag specifying whether to replace any existing rows whose inclusion
  would violate unique or primary key constraints.

- meta:

  A flag specifying whether to preserve meta data.

- log:

  A flag specifying whether to log the table operations.

- commit:

  A flag specifying whether to commit the operations (calling with
  commit = FALSE can be useful for checking data).

- strict:

  A flag specifying whether to error if x has extraneous columns or if
  exists = TRUE extraneous data frames.

- x_name:

  A string of the name of the object.

- silent:

  A flag specifying whether to suppress messages and warnings.

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

- ...:

  Not used.

## See also

Other rws_write:
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md),
[`rws_write.environment()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.environment.md),
[`rws_write.list()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.list.md)

## Examples

``` r
conn <- rws_connect()
rws_list_tables(conn)
#> character(0)
rws_write(rws_data, exists = FALSE, conn = conn)
rws_write(rws_data, x_name = "moredata", exists = FALSE, conn = conn)
rws_list_tables(conn)
#> [1] "moredata" "rws_data"
rws_disconnect(conn)
```
