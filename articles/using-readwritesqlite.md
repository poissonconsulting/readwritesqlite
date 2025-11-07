# Using readwritesqlite

`readwritesqlite` is an R package to enhance reading and writing to
SQLite databases.

## Starting

The first task after loading `readwritesqlite` is to create an object of
class SQLiteConnection. Below we create one in memory although in
general the user will want to specify a path.

``` r
library(readwritesqlite)
conn <- rws_connect(":memory:")
```

## Writing Data

Individual data frames, environments or named lists of data frames can
be written to a connection using
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md).

In the case of a data frame the default table name is the name of the
object (an alternative name can be specified using the `x_name`
argument).

``` r
rws_write(rws_data, exists = FALSE, conn = conn)
rws_list_tables(conn)
#> [1] "rws_data"
```

The fact that
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md)
accepts environments means that the user can easily write all the data
frames in the current environment to a SQLiteConnection.

``` r
a_table <- rws_data[c("date", "logical")]
another_table <- rws_data[c("factor", "ordered")]
not_a_table <- 1
rws_write(environment(), exists = FALSE, all = FALSE, conn = conn)
rws_list_tables(conn)
#> [1] "a_table"       "another_table" "rws_data"
```

Objects which are not data frames are silently filtered from
environments but cause an error with lists.

### Exists

By default the `exists` argument to the
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md)
function is `TRUE`. This means that only existing tables (which were
presumably created by the database designer with appropriate checks and
foreign keys) can be written to. If the user wishes to automatically
create new tables (if they don’t exist) before writing then they should
set `exists = NA`. If the user wishes to only write to previously
non-existent tables then they should set `exists = FALSE`.

### Foreign Keys

The
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md)
function ensures that writing the new data frame(s) to the database does
not violate foreign keys. If any data does the database is left
unchanged.

### Committing Data

By default, if no check or key violations occur the data frame(s) are
written to the database. Otherwise an error message is issued and all
changes are rolled back. If the user wishes to simply check whether data
could be written to a database without actually making any changes then
they can call
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md)
with `commit = FALSE`.

### Deleting Data (and Meta Data)

Meta data is recorded if the user uses
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md)
to write a data frame to an empty table. In order to change or add meta
data the user should read the existing data from the table (using
[`rws_read_sqlite()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read.md)),
modify it accordingly and then re-write it using
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md)
with `delete = TRUE`. The only exception is for factors and ordered
factors. If the existing factor levels are already recorded in the meta
data then the user can pass data with additional or rearranged levels
for factor and with additional levels for ordered factors without
deleting the existing data.

### Replacing Data

If writing data violates a unique or primary key an error message is
returned and the table is unaltered. The only exception to this is if
`replace = TRUE` in which case existing rows which cause unique or
primary key violations are removed.

### Duplicate Data

When passing data frames to
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md)
in the form of an environment or named list, each table must be
represented by just one data frame if `unique = TRUE` (the default).
Duplicates are also not permitted if `delete = TRUE` (because the first
data to be written will be overwritten) or `exists = FALSE` (because the
table will exist when the duplicate is written).

### All Data

When passing data frames to
[`rws_write()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_write.md)
in the form of an environment or named list, if `all = TRUE` (the
default) and `exists` is not `FALSE` then each existing tables must be
represented at least once. This option is useful for checking all the
tables in a data frame are populated when transferring data from an old
to new database.

### Strict

By default `strict = TRUE` and extra columns in an input data frame
cause an error to be thrown. If `strict = FALSE` the error is replaced
by a warning and the additional columns are automatically removed from
the data. When writing environments or list of data with
`exists = TRUE`, the `strict` argument also determines if extra data
frames cause an informative error or are automatically removed with a
warning.

### Silent

If the user wishes to suppress package specific messages or warnings
then they should set `silent = TRUE`. As the default value is
`silent = getOption("rws.silent", FALSE)` the user can silence the
package session-wide with `options(silent = TRUE)`.

## Reading Data

Data can be read using
[`rws_read()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read.md)
which either takes a vector of table names or the connection as the
first argument.
[`rws_read()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read.md)
returns a named list of tibbles. If the connection is the first argument
then the named list consists of all tables in the data base.

``` r
tables <- rws_read(conn)
names(tables)
#> [1] "a_table"       "another_table" "rws_data"
tables$rws_data
#> # A tibble: 3 × 6
#>   logical date       factor ordered posixct             units
#>   <lgl>   <date>     <fct>  <ord>   <dttm>                [m]
#> 1 TRUE    2000-01-01 x      x       2001-01-02 03:04:05  10  
#> 2 FALSE   2001-02-03 y      y       2006-07-08 09:10:11  11.5
#> 3 NA      NA         NA     NA      NA                   NA
```

The table names can of course be manipulated and
[`list2env()`](https://rdrr.io/r/base/list2env.html) used to assign the
data frames to the current environment.

``` r
names(tables) <- toupper(names(tables))
list2env(tables, environment())
```

If the user wishes to read a single data frame they can use
[`rws_read_table()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read_table.md)

``` r
rws_read_table("rws_data", conn = conn)
#> # A tibble: 3 × 6
#>   logical date       factor ordered posixct             units
#>   <lgl>   <date>     <fct>  <ord>   <dttm>                [m]
#> 1 TRUE    2000-01-01 x      x       2001-01-02 03:04:05  10  
#> 2 FALSE   2001-02-03 y      y       2006-07-08 09:10:11  11.5
#> 3 NA      NA         NA     NA      NA                   NA
```

The
[`rws_read_meta()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read_meta.md)
and
[`rws_read_log()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read_log.md)
allow the user to read the meta and log tables.

``` r
rws_read_meta(conn)
#> # A tibble: 10 × 4
#>    TableMeta     ColumnMeta MetaMeta          DescriptionMeta
#>    <chr>         <chr>      <chr>             <chr>          
#>  1 A_TABLE       DATE       class: Date       NA             
#>  2 A_TABLE       LOGICAL    class: logical    NA             
#>  3 ANOTHER_TABLE FACTOR     factor: 'x', 'y'  NA             
#>  4 ANOTHER_TABLE ORDERED    ordered: 'y', 'x' NA             
#>  5 RWS_DATA      DATE       class: Date       NA             
#>  6 RWS_DATA      FACTOR     factor: 'x', 'y'  NA             
#>  7 RWS_DATA      LOGICAL    class: logical    NA             
#>  8 RWS_DATA      ORDERED    ordered: 'y', 'x' NA             
#>  9 RWS_DATA      POSIXCT    tz: Etc/GMT+8     NA             
#> 10 RWS_DATA      UNITS      units: m          NA
```

``` r
rws_read_log(conn)
#> # A tibble: 6 x 5
#>   DateTimeUTCLog      UserLog TableLog      CommandLog NRowLog
#>   <dttm>              <chr>   <chr>         <chr>        <int>
#> 1 2019-07-07 16:09:59 joe     RWS_DATA      CREATE           0
#> 2 2019-07-07 16:10:00 joe     RWS_DATA      INSERT           3
#> 3 2019-07-07 16:10:00 joe     A_TABLE       CREATE           0
#> 4 2019-07-07 16:10:00 joe     A_TABLE       INSERT           3
#> 5 2019-07-07 16:10:00 joe     ANOTHER_TABLE CREATE           0
#> 6 2019-07-07 16:10:00 joe     ANOTHER_TABLE INSERT           3
```

## Cleaning Up

It’s good practice to close a connection once you have finished with it.

``` r
rws_disconnect(conn)
```
