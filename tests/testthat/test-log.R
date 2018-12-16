context("log")

test_that("rws_read_sqlite_log creates table", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  log <- rws_read_sqlite_log(conn)
  
  expect_identical(nrow(log), 0L)
  expect_identical(colnames(log), c("DateTimeUTCLog", "UserLog", "TableLog",
                                    "CommandLog", "NRowLog"))
  expect_identical(attr(log$DateTimeUTCLog, "tzone"), "UTC")
})

test_that("rws_write_sqlite data.frame logs commands", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3))
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(nrow(rws_read_sqlite_log(conn)), 0L)
  rws_write_sqlite(local, conn = conn)
  expect_identical(nrow(rws_read_sqlite_log(conn)), 1L)
  rws_write_sqlite(local, conn = conn)
  expect_identical(nrow(rws_read_sqlite_log(conn)), 2L)
  rws_write_sqlite(local, delete = TRUE, conn = conn)
  expect_identical(nrow(rws_read_sqlite_log(conn)), 4L)
  rws_write_sqlite(local, delete = TRUE, log = FALSE, conn = conn)
  expect_identical(nrow(rws_read_sqlite_log(conn)), 4L)
  rws_write_sqlite(local, log = FALSE, conn = conn)
  expect_identical(nrow(rws_read_sqlite_log(conn)), 4L)
  log <- rws_read_sqlite_log(conn)
  expect_identical(log$TableLog,
                   rep("LOCAL", 4L))
  expect_identical(log$CommandLog,
                   c("INSERT", "INSERT", "DELETE", "INSERT"))
  expect_identical(log$NRowLog, c(3L, 3L, 6L, 3L))
})


test_that("rws_write_sqlite list logs commands", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- list(local = data.frame(x = as.character(1:3)),
            LOCAl = data.frame(x = as.character(1:3)))
  expect_identical(nrow(rws_read_sqlite_log(conn)), 0L)
  rws_write_sqlite(y["local"], exists = FALSE, conn = conn)
  expect_identical(nrow(rws_read_sqlite_log(conn)), 2L)
  expect_error(rws_write_sqlite(y, conn = conn),
               "unique = TRUE but the following table name is duplicated: 'local'")
  rws_write_sqlite(y, conn = conn, unique = FALSE)
  expect_identical(nrow(rws_read_sqlite_log(conn)), 4L)
  expect_error(rws_write_sqlite(y, delete = TRUE, conn = conn),
  "unique = TRUE and delete = TRUE but the following table name is duplicated: 'local'")
  rws_write_sqlite(y["LOCAl"], delete = TRUE, conn = conn)
  expect_identical(nrow(rws_read_sqlite_log(conn)), 6L)
  log <- rws_read_sqlite_log(conn)
  expect_identical(log$TableLog, rep("LOCAL", 6L))
  expect_identical(log$CommandLog,
                   c("CREATE", "INSERT", "INSERT", "INSERT", "DELETE", "INSERT"))
  expect_identical(log$NRowLog, c(0L, 3L, 3L, 3L, 9L, 3L))
})
