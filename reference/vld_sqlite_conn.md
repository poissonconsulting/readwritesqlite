# Validate SQLite Connection

Validate SQLite Connection

## Usage

``` r
vld_sqlite_conn(x, connected = NA)
```

## Arguments

- x:

  The object to check.

- connected:

  A logical scalar specifying whether x should be connected.

## Value

A flag indicating whether the object was validated.

## Examples

``` r
conn <- rws_connect()
vld_sqlite_conn(conn)
#> [1] TRUE
rws_disconnect(conn)
vld_sqlite_conn(conn, connected = TRUE)
#> [1] FALSE
```
