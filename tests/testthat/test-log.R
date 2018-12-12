context("log")

test_that("rws_read_sqlite_log creates table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  log <- rws_read_sqlite_log()
  
  expect_identical(nrow(log), 0L)
  expect_identical(colnames(log), c("DateTimeUTCLog", "UserLog", "TableLog",
                                    "CommandLog", "NRowLog"))
  expect_identical(attr(log$DateTimeUTCLog, "tzone"), "UTC")
})

test_that("rws_write_sqlite data.frame logs commands", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3))
  DBI::dbCreateTable(con, "local", local)
  expect_identical(nrow(rws_read_sqlite_log()), 0L)
  rws_write_sqlite(local)
  expect_identical(nrow(rws_read_sqlite_log()), 1L)
  rws_write_sqlite(local)
  expect_identical(nrow(rws_read_sqlite_log()), 2L)
  rws_write_sqlite(local, delete = TRUE)
  expect_identical(nrow(rws_read_sqlite_log()), 4L)
  log <- rws_read_sqlite_log()
  expect_identical(log$TableLog,
                   rep("LOCAL", 4L))
  expect_identical(log$CommandLog,
                   c("INSERT", "INSERT", "DELETE", "INSERT"))
  expect_identical(log$NRowLog, c(3L, 3L, 6L, 3L))
})


test_that("rws_write_sqlite list logs commands", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  y <- list(local = data.frame(x = as.character(1:3)),
            LOCAl = data.frame(x = as.character(1:3)))
  expect_identical(nrow(rws_read_sqlite_log()), 0L)
  rws_write_sqlite(y["local"], exists = FALSE)
  expect_identical(nrow(rws_read_sqlite_log()), 2L)
  rws_write_sqlite(y)
  expect_identical(nrow(rws_read_sqlite_log()), 4L)
  expect_error(rws_write_sqlite(y, delete = TRUE),
  "delete = TRUE but the following table name is duplicated: 'local'")
  rws_write_sqlite(y["LOCAl"], delete = TRUE)
  expect_identical(nrow(rws_read_sqlite_log()), 6L)
  log <- rws_read_sqlite_log()
  expect_identical(log$TableLog, rep("LOCAL", 6L))
  expect_identical(log$CommandLog,
                   c("CREATE", "INSERT", "INSERT", "INSERT", "DELETE", "INSERT"))
  expect_identical(log$NRowLog, c(0L, 3L, 3L, 3L, 9L, 3L))
})
