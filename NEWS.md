# readwritesqlite 0.1.1

- Fix failing CRAN tests with latest sf (>= 0.9.1)

# readwritesqlite 0.1.0

## New Features

- Added `rws_drop_table()`.
- Added `rws_rename_table()` and `rws_rename_column()`.
- Updated error messages to tidyverse style.

## Deprecated Functions

- Deprecated `check_sqlite_connection()` for `chk_sqlite_conn()`.

## Dependencies

- Moved `sf` and `units` packages to Suggests.
- Replaced dependency on `err` and `checkr` with `chk`.

# readwritesqlite 0.0.2

- Update for release hms 0.5.0 
    - Replace hms::is.hms with hms::is_hms
    - Replace hms::as.hms with hms::as_hms
- Fix tests for release RSQLite 2.1.1.9003

# readwritesqlite 0.0.1

- Initial release
