# Export all spatial datasets in a database as geopackages.

Export all spatial datasets in a database as geopackages.

## Usage

``` r
rws_export_gpkg(conn, dir, overwrite = FALSE)
```

## Arguments

- conn:

  A
  [RSQLite::SQLiteConnection](https://rsqlite.r-dbi.org/reference/SQLiteConnection-class.html)
  to a database.

- dir:

  A string of the path to the directory to save the geopackages in.

- overwrite:

  A flag specifying whether to overwrite existing geopackages.

## Value

An invisible named vector of the file names and new file names saved.

## Details

If more than one spatial column is present in a table, a separate
geopackage will be exported for each, and the other spatial columns will
be dropped.
