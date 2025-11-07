# Write a Named List of Data Frames to a SQLite Database

Write a Named List of Data Frames to a SQLite Database

## Usage

``` r
# S3 method for class 'list'
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
  all = TRUE,
  unique = TRUE,
  ...
)
```

## Arguments

- x:

  A named list of data frames.

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

- all:

  A flag specifying whether all the existing tables in the data base
  must be represented.

- unique:

  A flag specifying whether each table must represented by no more than
  one data frame.

- ...:

  Not used.

## See also

Other rws_write:
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md),
[`rws_write.data.frame()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.data.frame.md),
[`rws_write.environment()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.environment.md)

## Examples

``` r
conn <- rws_connect()
rws_list_tables(conn)
#> character(0)
rws_write(list(somedata = rws_data, anothertable = rws_data), exists = FALSE, conn = conn)
rws_list_tables(conn)
#> [1] "anothertable" "somedata"    
rws_disconnect(conn)
```
