# Example Data

An sf tibble of example data.

## Usage

``` r
rws_data
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 3
rows and 6 columns.

## Examples

``` r
rws_data
#> # A tibble: 3 × 6
#>   logical date       factor ordered posixct             units
#>   <lgl>   <date>     <fct>  <ord>   <dttm>                [m]
#> 1 TRUE    2000-01-01 x      x       2001-01-02 03:04:05  10  
#> 2 FALSE   2001-02-03 y      y       2006-07-08 09:10:11  11.5
#> 3 NA      NA         NA     NA      NA                   NA  
```
