# Changelog

## readwritesqlite 0.2.0.9016

### Continuous integration

- Use reviewdog for external PRs
  ([\#60](https://github.com/poissonconsulting/readwritesqlite/issues/60)).

## readwritesqlite 0.2.0.9015

### Chore

- Auto-update from GitHub Actions.

  Run:
  <https://github.com/poissonconsulting/readwritesqlite/actions/runs/17450832054>

## readwritesqlite 0.2.0.9014

### Continuous integration

- Cleanup and fix macOS
  ([\#59](https://github.com/poissonconsulting/readwritesqlite/issues/59)).

## readwritesqlite 0.2.0.9013

### Continuous integration

- Format with air, check detritus, better handling of `extra-packages`
  ([\#58](https://github.com/poissonconsulting/readwritesqlite/issues/58)).

## readwritesqlite 0.2.0.9012

### Testing

- Skip if pool is not installed
  ([\#57](https://github.com/poissonconsulting/readwritesqlite/issues/57)).

## readwritesqlite 0.2.0.9011

### Continuous integration

- Enhance permissions for workflow
  ([\#56](https://github.com/poissonconsulting/readwritesqlite/issues/56)).

## readwritesqlite 0.2.0.9010

### Continuous integration

- Permissions, better tests for missing suggests, lints
  ([\#55](https://github.com/poissonconsulting/readwritesqlite/issues/55)).

## readwritesqlite 0.2.0.9009

### Continuous integration

- Only fail covr builds if token is given
  ([\#54](https://github.com/poissonconsulting/readwritesqlite/issues/54)).

- Always use `_R_CHECK_FORCE_SUGGESTS_=false`
  ([\#53](https://github.com/poissonconsulting/readwritesqlite/issues/53)).

## readwritesqlite 0.2.0.9008

### Continuous integration

- Correct installation of xml2
  ([\#52](https://github.com/poissonconsulting/readwritesqlite/issues/52)).

## readwritesqlite 0.2.0.9007

### Chore

- Auto-update from GitHub Actions.

  Run:
  <https://github.com/poissonconsulting/readwritesqlite/actions/runs/14636202234>

### Continuous integration

- Explain
  ([\#51](https://github.com/poissonconsulting/readwritesqlite/issues/51)).

- Add xml2 for covr, print testthat results
  ([\#50](https://github.com/poissonconsulting/readwritesqlite/issues/50)).

- Fix
  ([\#49](https://github.com/poissonconsulting/readwritesqlite/issues/49)).

- Sync
  ([\#48](https://github.com/poissonconsulting/readwritesqlite/issues/48)).

## readwritesqlite 0.2.0.9006

### Continuous integration

- Avoid failure in fledge workflow if no changes
  ([\#46](https://github.com/poissonconsulting/readwritesqlite/issues/46)).

## readwritesqlite 0.2.0.9005

### Continuous integration

- Fetch tags for fledge workflow to avoid unnecessary NEWS entries
  ([\#45](https://github.com/poissonconsulting/readwritesqlite/issues/45)).

## readwritesqlite 0.2.0.9004

### Continuous integration

- Use larger retry count for lock-threads workflow
  ([\#44](https://github.com/poissonconsulting/readwritesqlite/issues/44)).

## readwritesqlite 0.2.0.9003

### Continuous integration

- Ignore errors when removing pkg-config on macOS
  ([\#43](https://github.com/poissonconsulting/readwritesqlite/issues/43)).

## readwritesqlite 0.2.0.9002

### Continuous integration

- Overwrite from actions-sync
  ([\#42](https://github.com/poissonconsulting/readwritesqlite/issues/42)).

## readwritesqlite 0.2.0.9001

- Internal changes.

## readwritesqlite 0.2.0.9000

- Same as previous version.

## readwritesqlite 0.2.0

CRAN release: 2022-10-16

- Added
  [`rws_export_gpkg()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_export_gpkg.md).
- Now R \>= 4.0
- Switched to testthat 3.
- Previously soft deprecated functions now warn unconditionally.

## readwritesqlite 0.1.2

CRAN release: 2020-07-13

### New Features

- Extended to also work with pool objects.

### Deprecated

- Removed geometry sfc column from rws_data.

### Internal

- Removed trailing spaces on sf (\>= 0.9-1) projections which are
  causing write error.

## readwritesqlite 0.1.1

CRAN release: 2020-04-07

- Fix failing CRAN tests with sf (\>= 0.9-1)

## readwritesqlite 0.1.0

CRAN release: 2020-01-29

### New Features

- Added
  [`rws_drop_table()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_drop_table.md).
- Added
  [`rws_rename_table()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_rename_table.md)
  and
  [`rws_rename_column()`](https://poissonconsulting.github.io/readwritesqlite/reference/rws_rename_column.md).
- Updated error messages to tidyverse style.

### Deprecated Functions

- Deprecated
  [`check_sqlite_connection()`](https://poissonconsulting.github.io/readwritesqlite/reference/chk_sqlite_conn.md)
  for
  [`chk_sqlite_conn()`](https://poissonconsulting.github.io/readwritesqlite/reference/chk_sqlite_conn.md).

### Dependencies

- Moved `sf` and `units` packages to Suggests.
- Replaced dependency on `err` and `checkr` with `chk`.

## readwritesqlite 0.0.2

CRAN release: 2019-07-23

- Update for release hms 0.5.0
  - Replace hms::is.hms with hms::is_hms
  - Replace hms::as.hms with hms::as_hms
- Fix tests for release RSQLite 2.1.1.9003

## readwritesqlite 0.0.1

CRAN release: 2019-07-11

- Initial release
