test_that("rws_get_sqlite_query works with meta = FALSE", {
  conn <- local_conn()

  local <- data.frame(x = 1:3)
  local2 <- as_tibble_sf(local[1:2, , drop = FALSE])
  DBI::dbWriteTable(conn, "local", local)
  DBI::dbWriteTable(conn, "local2", local2)

  data <- rws_query("SELECT * FROM local", meta = FALSE, conn = conn)
  expect_equal(data, local, ignore_attr = TRUE)
  data2 <- rws_query("SELECT * FROM local2", meta = FALSE, conn = conn)
  expect_identical(data2, local2)
})

test_that("rws_get_sqlite_query works with meta = TRUE and logical", {
  conn <- local_conn()

  local <- as_tibble_sf(data.frame(z = c(TRUE, FALSE, NA)))
  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")

  data <- rws_query("SELECT * FROM local", meta = FALSE, conn = conn)
  expect_equal(data, data.frame(z = c(1L, 0L, NA_integer_)), ignore_attr = TRUE)
  data2 <- rws_query("SELECT * FROM local", meta = TRUE, conn = conn)
  expect_identical(data2, local)
})


test_that("rws_get_sqlite_query works with meta = TRUE and logical", {
  conn <- local_conn()

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
  remote <- rws_query("SELECT * FROM local", conn = conn)
  expect_identical(class(remote), c("tbl_df", "tbl", "data.frame"))
  expect_identical(colnames(remote), colnames(local))
  expect_identical(nrow(remote), 1L)
  expect_identical(remote$logical, local$logical)
  expect_identical(remote$date, local$date)
  expect_identical(remote$posixct, local$posixct)
  expect_identical(remote$units, local$units)
  expect_identical(remote$hms, local$hms)
  expect_identical(remote$factor, local$factor)
  expect_identical(remote$ordered, local$ordered)
  expect_equal(remote$geometry, local$geometry, ignore_attr = TRUE)
})

test_that("rws_get_sqlite_query teases apart two", {
  conn <- local_conn()

  local <- as_tibble_sf(data.frame(x = 1:3, z = c(TRUE, FALSE, NA), a = c(TRUE, TRUE, FALSE)))
  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")
  local2 <- as_tibble_sf(data.frame(x = 2:4, z2 = c(1, 2, NA), a = c(TRUE, FALSE, TRUE)))
  expect_identical(rws_write(local2, exists = FALSE, conn = conn), "local2")

  data <- rws_query("SELECT * FROM local", conn = conn)
  expect_identical(data, local)
  local3 <- as_tibble_sf(data.frame(x = 2:4, z2 = c(FALSE, NA, TRUE), a = 2:4))
  expect_identical(rws_write(local3, exists = FALSE, conn = conn), "local3")
  data <- rws_query("SELECT * FROM local", conn = conn)

  expect_identical(data, local)

  data <- rws_query("SELECT local.a AS a FROM local INNER JOIN local2 ON local.x = local2.x", conn = conn)
  expect_identical(data, as_tibble_sf(data.frame(a = c(TRUE, FALSE))))

  data <- rws_query("SELECT local.a AS a FROM local INNER JOIN local3 ON local.x = local3.x", conn = conn)
  expect_identical(data, as_tibble_sf(data.frame(a = c(1L, 0L))))
})
