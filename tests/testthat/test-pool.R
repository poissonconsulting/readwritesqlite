test_that("sf data frames with single geometry passed back", {
  pool <-  pool::dbPool(drv = RSQLite::SQLite(), host = ":memory:")
  conn <- pool::poolCheckout(pool)
  teardown(pool::poolReturn(conn))
  teardown(pool::poolClose(pool))
  
  local <- readwritesqlite:::rws_data_sf
  
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  init <- DBI::dbReadTable(conn, "readwritesqlite_init")
  expect_identical(init, data.frame(
    TableInit = "LOCAL",
    IsInit = 1L, SFInit = "GEOMETRY",
    stringsAsFactors = FALSE
  ))
  remote <- rws_read_table("local", conn = conn)
  expect_identical(class(remote), c("sf", "tbl_df", "tbl", "data.frame"))
  expect_identical(colnames(remote), colnames(local))
  expect_identical(nrow(remote), 3L)
  expect_identical(remote$logical, local$logical)
  expect_identical(remote$date, local$date)
  expect_identical(remote$posixct, local$posixct)
  expect_identical(remote$units, local$units)
  expect_identical(remote$factor, local$factor)
  expect_identical(remote$ordered, local$ordered)
  expect_equivalent(remote$geometry, local$geometry)
})
