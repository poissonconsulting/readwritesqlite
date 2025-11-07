# Read All Tables from a SQLite Database

Read All Tables from a SQLite Database

## Usage

``` r
# S3 method for class 'SQLiteConnection'
rws_read(x, meta = TRUE, ...)
```

## Arguments

- x:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

- meta:

  A flag specifying whether to preserve meta data.

- ...:

  Not used.

## Value

A named list of the data frames.

## See also

Other rws_read:
[`rws_describe_meta.data.frame()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_describe_meta.data.frame.md),
[`rws_read()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read.md),
[`rws_read.character()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read.character.md)

## Examples

``` r
conn <- rws_connect()
rws_write(rws_data, exists = FALSE, conn = conn)
rws_write(rws_data[c("date", "ordered")],
  x_name = "data2", exists = FALSE, conn = conn
)
rws_read(conn)
#> $data2
#> # A tibble: 3 × 2
#>   date       ordered
#>   <date>     <ord>  
#> 1 2000-01-01 x      
#> 2 2001-02-03 y      
#> 3 NA         NA     
#> 
#> $rws_data
#> # A tibble: 3 × 6
#>   logical date       factor ordered posixct             units
#>   <lgl>   <date>     <fct>  <ord>   <dttm>                [m]
#> 1 TRUE    2000-01-01 x      x       2001-01-02 03:04:05  10  
#> 2 FALSE   2001-02-03 y      y       2006-07-08 09:10:11  11.5
#> 3 NA      NA         NA     NA      NA                   NA  
#> 
rws_disconnect(conn)
```
