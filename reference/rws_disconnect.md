# Close SQLite Database Connection

Closes a
[RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
to a SQLite database.

## Usage

``` r
rws_disconnect(conn)
```

## Arguments

- conn:

  An `RSQLite::SQLiteConnection()`.

## See also

[`rws_connect()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_connect.md)

## Examples

``` r
conn <- rws_connect()
rws_disconnect(conn)
print(conn)
#> <SQLiteConnection>
#>   DISCONNECTED
```
