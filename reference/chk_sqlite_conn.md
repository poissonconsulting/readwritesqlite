# Check SQLite Connection

`chk_sqlite_conn` checks if a SQLite connection.

## Usage

``` r
chk_sqlite_conn(x, connected = NA, x_name = NULL)

check_sqlite_connection(
  x,
  connected = NA,
  x_name = substitute(x),
  error = TRUE
)
```

## Arguments

- x:

  The object to check.

- connected:

  A logical scalar specifying whether x should be connected.

- x_name:

  A string of the name of object x or NULL.

- error:

  A flag specifying whether to through an error if the check fails.

## Value

`NULL`, invisibly. Called for the side effect of throwing an error if
the condition is not met.

## Functions

- `check_sqlite_connection()`: Check SQLite Connection

## Examples

``` r
conn <- rws_connect()
chk_sqlite_conn(conn)
rws_disconnect(conn)
try(chk_sqlite_conn(conn, connected = TRUE))
#> Error in eval(expr, envir) : `conn` must be connected.
```
