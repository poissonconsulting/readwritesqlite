# Add Data Frame of Descriptions to SQL Meta Data Table

Add Data Frame of Descriptions to SQL Meta Data Table

## Usage

``` r
# S3 method for class 'data.frame'
rws_describe_meta(x, ..., conn)
```

## Arguments

- x:

  A data frame with columns Table, Column, Description.

- ...:

  Not used.

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

## Value

An invisible character vector of the previous descriptions.

## See also

Other rws_read:
[`rws_read()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read.md),
[`rws_read.SQLiteConnection()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read.SQLiteConnection.md),
[`rws_read.character()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_read.character.md)
