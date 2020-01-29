context("meta")

test_that("make_meta_data works", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3))

  expect_identical(
    make_meta_data(conn),
    data.frame(
      TableMeta = character(0), ColumnMeta = character(0),
      stringsAsFactors = FALSE
    )
  )
  expect_true(DBI::dbCreateTable(conn, "loCal", local))
  expect_identical(make_meta_data(conn), data.frame(
    TableMeta = "LOCAL",
    ColumnMeta = "X",
    stringsAsFactors = FALSE
  ))
  expect_true(DBI::dbCreateTable(conn, "loCal2", local))
  expect_identical(make_meta_data(conn), data.frame(
    TableMeta = c("LOCAL", "LOCAL2"),
    ColumnMeta = c("X", "X"),
    stringsAsFactors = FALSE
  ))
})

test_that("read_sqlite_meta creates table", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  expect_identical(rws_read_meta(conn), rws_read_meta(conn))
  meta <- rws_read_meta(conn)
  expect_identical(
    colnames(meta),
    c("TableMeta", "ColumnMeta", "MetaMeta", "DescriptionMeta")
  )
  expect_identical(nrow(meta), 0L)
})

test_that("meta handles logical", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  meta <- rws_read_meta(conn)
  expect_identical(meta, tibble::tibble(
    TableMeta = "LOCAL",
    ColumnMeta = "Z",
    MetaMeta = "class: logical",
    DescriptionMeta = NA_character_
  ))
})

test_that("meta handles all classes", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(
    logical = TRUE, date = as.Date("2000-01-01"),
    posixct = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
    units = units::as_units(10, "m"),
    hms = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8")
  )

  local$hms <- hms::as_hms(local$hms)

  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")
  meta <- rws_read_meta(conn)
  expect_identical(meta, tibble::tibble(
    TableMeta = rep("LOCAL", 5),
    ColumnMeta = c("DATE", "HMS", "LOGICAL", "POSIXCT", "UNITS"),
    MetaMeta = c("class: Date", "class: hms", "class: logical", "tz: Etc/GMT+8", "units: m"),
    DescriptionMeta = rep(NA_character_, 5)
  ))
})

test_that("meta errors if meta and then no meta", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))

  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")
  expect_identical(rws_write(local, conn = conn), "local")

  local$z <- as.character(local$z)
  expect_error(
    rws_write(local, conn = conn),
    "^Column 'z' in table 'local' has 'No' meta data for the input data but 'class: logical' for the existing data[.]$"
  )
})

test_that("meta errors if no meta and then meta", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = as.character(c(TRUE, FALSE, NA)), stringsAsFactors = FALSE)

  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")
  expect_identical(rws_write(local, conn = conn), "local")

  local$z <- as.logical(local$z)
  expect_error(
    rws_write(local, conn = conn),
    "^Column 'z' in table 'local' has 'class: logical' meta data for the input data but 'No' for the existing data[.]$"
  )
})

test_that("meta errors if inconsistent meta", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))

  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")
  expect_identical(rws_write(local, conn = conn), "local")

  local$z <- Sys.Date()
  expect_error(
    rws_write(local, conn = conn),
    "^Column 'z' in table 'local' has 'class: Date' meta data for the input data but 'class: logical' for the existing data[.]$"
  )
})

test_that("fix meta inconsistent by deleting", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))

  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")
  expect_identical(rws_write(local, conn = conn), "local")

  local$z <- Sys.Date()
  expect_error(
    rws_write(local, conn = conn),
    "^Column 'z' in table 'local' has 'class: Date' meta data for the input data but 'class: logical' for the existing data[.]$"
  )
  expect_identical(rws_write(local, delete = TRUE, conn = conn), "local")
  expect_identical(rws_write(local, conn = conn), "local")

  local <- data.frame(z = c(TRUE, FALSE, NA))
  expect_error(
    rws_write(local, conn = conn),
    "^Column 'z' in table 'local' has 'class: logical' meta data for the input data but 'class: Date' for the existing data[.]$"
  )
})

test_that("meta reads logical", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))

  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")

  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("meta reads all classes", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(
    logical = TRUE,
    date = as.Date("2000-01-01"),
    posixct = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
    units = units::as_units(10, "m"),
    hms = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
    geometry = sf::st_sfc(sf::st_point(c(0, 1)), crs = 4326),
    factor = factor("fac"),
    ordered = ordered("ordered")
  )

  local$hms <- hms::as_hms(local$hms)

  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")
  expect_identical(
    readwritesqlite:::table_schema("local", conn),
    paste0(
      "CREATE TABLE `local` (\n  `logical` INTEGER,\n  ",
      "`date` REAL,\n  `posixct` REAL,\n  ",
      "`units` REAL,\n  `hms` REAL,\n  ",
      "`geometry` BLOB,\n  `factor` TEXT,\n  `ordered` TEXT\n)"
    )
  )
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("meta = FALSE same as just writing", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(
    logical = TRUE,
    date = as.Date("2000-01-01"),
    posixct = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
    units = units::as_units(10, "m"),
    hms = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
    geometry = sf::st_sfc(sf::st_point(c(0, 1)), crs = 4326),
    factor = factor("fac"),
    ordered = ordered("ordered")
  )

  local$hms <- hms::as_hms(local$hms)


  expect_identical(rws_write(local, meta = FALSE, exists = FALSE, conn = conn), "local")
  expect_identical(
    readwritesqlite:::table_schema("local", conn),
    paste0(
      "CREATE TABLE `local` (\n  `logical` INTEGER,\n  ",
      "`date` REAL,\n  `posixct` REAL,\n  `units` REAL,\n  `hms` REAL,\n  ",
      "`geometry` BLOB,\n  `factor` TEXT,\n  `ordered` TEXT\n)"
    )
  )
  remote <- rws_read_table("local", conn = conn)
  remote$geometry <- NULL
  expect_equal(remote, tibble::tibble(
    logical = 1L,
    date = 10957,
    posixct = 978433445,
    units = 10,
    hms = 11045,
    factor = "fac",
    ordered = "ordered"
  ))

  expect_error(rws_write(local, conn = conn), "Column 'logical' in table 'local' has 'class: logical' meta data for the input data but 'No' for the existing data[.]")
})

test_that("meta logical logical different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- c(TRUE, FALSE, NA)
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- DBI::dbReadTable(conn, "local")
  expect_identical(remote2, data.frame(
    zinteger = c(1L, 0L, NA),
    zreal = c(1, 0, NA),
    znumeric = c(1L, 0L, NA),
    ztext = c("TRUE", "FALSE", NA),
    zblob = c(1, 0, NA), stringsAsFactors = FALSE
  ))
})

test_that("meta Date different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- as.Date(c("2001-02-03", "2002-03-04", NA))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- DBI::dbReadTable(conn, "local")
  expect_identical(remote2, data.frame(
    zinteger = c(11356L, 11750L, NA),
    zreal = c(11356, 11750, NA),
    znumeric = c(11356L, 11750L, NA),
    ztext = c("2001-02-03", "2002-03-04", NA),
    zblob = c(11356, 11750, NA), stringsAsFactors = FALSE
  ))
})

test_that("meta POSIXct different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- as.POSIXct(c(
    "2001-01-02 03:04:05", "2007-08-09 10:11:12", NA
  ), tz = "Etc/GMT+8")

  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- DBI::dbReadTable(conn, "local")
  expect_identical(remote2, data.frame(
    zinteger = c(978433445L, 1186683072L, NA),
    zreal = c(978433445, 1186683072, NA),
    znumeric = c(978433445L, 1186683072L, NA),
    ztext = c("2001-01-02 03:04:05", "2007-08-09 10:11:12", NA),
    zblob = c(978433445, 1186683072, NA),
    stringsAsFactors = FALSE
  ))
})

test_that("meta hms different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- as.POSIXct(c(
    "2001-01-02 03:04:05", "2007-08-09 10:11:12", NA
  ), tz = "Etc/GMT+8")

  z <- hms::as_hms(z)

  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- DBI::dbReadTable(conn, "local")
  expect_identical(remote2, data.frame(
    zinteger = c(11045L, 36672L, NA),
    zreal = c(11045, 36672, NA),
    znumeric = c(11045L, 36672L, NA),
    ztext = c("03:04:05", "10:11:12", NA),
    zblob = c(11045, 36672, NA),
    stringsAsFactors = FALSE
  ))
})

test_that("meta hms preserves decimal", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- as.POSIXct(c(
    "2001-01-02 03:04:05", "2007-08-09 10:11:12", NA
  ), tz = "Etc/GMT+8")

  z[1] <- z[1] + 0.5
  z <- hms::as_hms(z)

  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- DBI::dbReadTable(conn, "local")
  expect_identical(remote2, data.frame(
    zinteger = c(11045.5, 36672, NA),
    zreal = c(11045.5, 36672, NA),
    znumeric = c(11045.5, 36672, NA),
    ztext = c("03:04:05.5", "10:11:12.0", NA),
    zblob = c(11045.5, 36672, NA),
    stringsAsFactors = FALSE
  ))
})

test_that("meta units different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- units::as_units(c(10, 11.5, NA), "m3")

  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob NONE
              )")

  expect_identical(rws_write(local, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- DBI::dbReadTable(conn, "local")
  expect_identical(remote2, data.frame(
    zinteger = c(10, 11.5, NA),
    zreal = c(10, 11.5, NA),
    znumeric = c(10, 11.5, NA),
    ztext = c("10.0", "11.5", NA),
    zblob = c(10, 11.5, NA), stringsAsFactors = FALSE
  ))
})

test_that("meta sfc different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- sf::st_sfc(c(
    sf::st_point(c(0, 1)),
    sf::st_point(c(0, 1)),
    sf::st_point(c(0, 1))
  ), crs = 4326)

  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    ztextold = z,
    zblob = z
  )

  colnames(local) <- c("zinteger", "zreal", "znumeric", "ztext", "ztextold", "zblob")

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  ztextold TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")

  # modify ztextold to resemble old multipoint style
  query <- "UPDATE `local` SET `ztextold` = 'MULTIPOINT (0 1, 0 1, 0 1)'"
  DBI::dbExecute(conn, query)

  skip_if_not_installed("sf", minimum_version = "0.8-1")

  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- DBI::dbReadTable(conn, "local")
  expect_identical(
    vapply(remote2, is.blob, TRUE),
    c(
      zinteger = TRUE, zreal = TRUE, znumeric = TRUE,
      ztext = FALSE, ztextold = FALSE, zblob = TRUE
    )
  )
  expect_identical(remote2$ztext, "MULTIPOINT ((0 1), (0 1), (0 1))")
})

test_that("meta factor different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- factor(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- DBI::dbReadTable(conn, "local")
  expect_identical(remote2, data.frame(
    zinteger = c("x", "y", NA),
    zreal = c("x", "y", NA),
    znumeric = c("x", "y", NA),
    ztext = c("x", "y", NA),
    zblob = c("x", "y", NA),
    stringsAsFactors = FALSE
  ))
})

test_that("meta factor 11 level", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- factor(c(1:11, NA), levels = c(1:11))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
})


test_that("meta ordered different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- ordered(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- DBI::dbReadTable(conn, "local")
  expect_identical(remote2, data.frame(
    zinteger = c("x", "y", NA),
    zreal = c("x", "y", NA),
    znumeric = c("x", "y", NA),
    ztext = c("x", "y", NA),
    zblob = c("x", "y", NA), stringsAsFactors = FALSE
  ))
})

test_that("meta factor without meta then meta errors", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- factor(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  DBI::dbWriteTable(conn, "local", local, append = TRUE)
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(lapply(local, as.character)))

  remote2 <- DBI::dbReadTable(conn, "local")
  expect_identical(remote2, data.frame(
    zinteger = c("x", "y", NA),
    zreal = c("x", "y", NA),
    znumeric = c("x", "y", NA),
    ztext = c("x", "y", NA),
    zblob = c("x", "y", NA), stringsAsFactors = FALSE
  ))

  remote2 <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(lapply(local, as.character)))
  expect_error(
    rws_write(local, conn = conn),
    "Column 'zinteger' in table 'local' has 'factor: 'y', 'x'' meta data for the input data but 'No' for the existing data[.]"
  )
})

test_that("meta factor rearrange levels", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- factor(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")
  expect_identical(rws_write(local, conn = conn), "local")

  z <- factor(c("x", "y", NA), levels = c("x", "y"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  expect_identical(rws_write(local, conn = conn), "local")

  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(rbind(local, local, local)))
})

test_that("meta factor add levels", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- factor(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")

  z <- factor(c("x", "y", "z"), levels = c("z", "y", "x"))
  local2 <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  expect_identical(rws_write(local2, x_name = "local", conn = conn), "local")

  remote <- rws_read_table("local", conn = conn)
  expect_identical(levels(remote$zinteger), c("z", "y", "x"))
  expect_identical(remote$zinteger, factor(c("x", "y", NA, "x", "y", "z"),
    levels = c("z", "y", "x")
  ))
})

test_that("meta ordered add and rearrange levels", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- ordered(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  DBI::dbExecute(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")

  expect_identical(rws_write(local, conn = conn), "local")

  z <- ordered(c("x", "y", "z"), levels = c("z", "x", "y"))
  local2 <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  expect_error(
    rws_write(local2, x_name = "local", conn = conn),
    "^Column 'zinteger' in table 'local' has 'ordered: 'z', 'x', 'y'' meta data for the input data but 'ordered: 'y', 'x'' for the existing data[.]$"
  )

  z <- ordered(c("x", "y", "z"), levels = c("z", "y", "x"))
  local2 <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z
  )

  expect_identical(rws_write(local2, x_name = "local", conn = conn), "local")

  remote <- rws_read_table("local", conn = conn)
  expect_identical(levels(remote$zinteger), c("z", "y", "x"))
  expect_identical(remote$zinteger, ordered(c("x", "y", NA, "x", "y", "z"),
    levels = c("z", "y", "x")
  ))
})

test_that("read_meta_levels", {
  expect_identical(read_meta_levels("factor:  '1', '3'"), c("1", "3"))
  expect_identical(read_meta_levels("ordered:'4'"), c("4"))
  expect_identical(read_meta_levels("'1', '3', '10'"), c("1", "3", "10"))
  expect_identical(read_meta_levels(character(0)), character(0))
  expect_identical(read_meta_levels("factor:  "), character(0))
})

test_that("meta TRUE then FALSE then read with TRUE", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(fac = factor(c("this", "that", NA)))
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  remote <- rws_read_table("local", meta = TRUE, conn = conn)
  expect_equal(remote, tibble::as_tibble(local))
  remote <- rws_read_table("local", meta = FALSE, conn = conn)
  expect_identical(
    remote,
    tibble::tibble(fac = c("this", "that", NA))
  )
  local <- data.frame(fac = factor("other"))
  expect_error(
    rws_write(local, meta = TRUE, conn = conn),
    "^Column 'fac' in table 'local' has 'factor: 'other'' meta data for the input data but 'factor: 'that', 'this'' for the existing data[.]$"
  )
  expect_identical(rws_write(local, meta = FALSE, conn = conn), "local")
  remote <- rws_read_table("local", meta = FALSE, conn = conn)
  expect_identical(
    remote,
    tibble::tibble(fac = c("this", "that", NA, "other"))
  )
  remote <- rws_read_table("local", meta = TRUE, conn = conn)
  expect_identical(
    remote,
    tibble::tibble(fac = factor(c("this", "that", NA, NA)))
  )
  local <- data.frame(fac = 4)
  expect_identical(rws_write(local, meta = FALSE, conn = conn), "local")
  remote <- rws_read_table("local", meta = FALSE, conn = conn)
  expect_identical(
    remote,
    tibble::tibble(fac = c("this", "that", NA, "other", "4.0"))
  )
  remote <- rws_read_table("local", meta = TRUE, conn = conn)
  expect_identical(
    remote,
    tibble::tibble(fac = factor(c("this", "that", NA, NA, NA)))
  )
})
