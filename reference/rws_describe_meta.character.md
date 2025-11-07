# Add Descriptions to SQL Meta Data Table

Add Descriptions to SQL Meta Data Table

## Usage

``` r
# S3 method for class 'character'
rws_describe_meta(x, column, description, ..., conn)
```

## Arguments

- x:

  A character vector of table name(s).

- column:

  A character vector of column name(s).

- description:

  A character vector of the description(s)

- ...:

  Not used.

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

An invisible copy of the updated meta table.

## See also

Other rws_describe_meta:
[`rws_describe_meta()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_describe_meta.md)

## Examples

``` r
conn <- rws_connect()
rws_write(rws_data, exists = FALSE, conn = conn)
rws_read_meta(conn)
#> # A tibble: 6 × 4
#>   TableMeta ColumnMeta MetaMeta          DescriptionMeta
#>   <chr>     <chr>      <chr>             <chr>          
#> 1 RWS_DATA  DATE       class: Date       NA             
#> 2 RWS_DATA  FACTOR     factor: 'x', 'y'  NA             
#> 3 RWS_DATA  LOGICAL    class: logical    NA             
#> 4 RWS_DATA  ORDERED    ordered: 'y', 'x' NA             
#> 5 RWS_DATA  POSIXCT    tz: Etc/GMT+8     NA             
#> 6 RWS_DATA  UNITS      units: m          NA             
rws_describe_meta("rws_data", "Units", "The site length.", conn = conn)
rws_describe_meta("rws_data", "POSIXct", "Time of the visit", conn = conn)
rws_read_meta(conn)
#> # A tibble: 6 × 4
#>   TableMeta ColumnMeta MetaMeta          DescriptionMeta  
#>   <chr>     <chr>      <chr>             <chr>            
#> 1 RWS_DATA  DATE       class: Date       NA               
#> 2 RWS_DATA  FACTOR     factor: 'x', 'y'  NA               
#> 3 RWS_DATA  LOGICAL    class: logical    NA               
#> 4 RWS_DATA  ORDERED    ordered: 'y', 'x' NA               
#> 5 RWS_DATA  POSIXCT    tz: Etc/GMT+8     Time of the visit
#> 6 RWS_DATA  UNITS      units: m          The site length. 
rws_disconnect(conn)
```
