# Opens SQLite Database Connection

Opens a
[RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
to a SQLite database with foreign key constraints enabled.

## Usage

``` r
rws_connect(dbname = ":memory:", exists = NA)
```

## Arguments

- dbname:

  The path to the database file. SQLite keeps each database instance in
  one single file. The name of the database *is* the file name, thus
  database names should be legal file names in the running platform.
  There are two exceptions:

  - `""` will create a temporary on-disk database. The file will be
    deleted when the connection is closed.

  - `":memory:"` or `"file::memory:"` will create a temporary in-memory
    database.

- exists:

  A flag specifying whether the table(s) must already exist.

## Value

A
[RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
to a SQLite database with foreign key constraints enabled.

## See also

[`rws_disconnect()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_disconnect.md)

## Examples

``` r
conn <- rws_connect()
print(conn)
#> <SQLiteConnection>
#>   Path: :memory:
#>   Extensions: TRUE
rws_disconnect(conn)
```
