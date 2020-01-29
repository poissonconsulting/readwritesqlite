context("write")

test_that("rws_write.data.frame checks reserved table names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3))
  expect_error(
    rws_write(local, x_name = "readwritesqlite_log", conn = conn),
    "'readwritesqlite_log' is a reserved table"
  )
  expect_error(
    rws_write(local, x_name = "readwritesqlite_LOG", conn = conn),
    "'readwritesqlite_LOG' is a reserved table"
  )
  expect_error(
    rws_write(local, x_name = "readwritesqlite_meta", conn = conn),
    "'readwritesqlite_meta' is a reserved table"
  )
  expect_error(
    rws_write(local, x_name = "READwritesqlite_meta", conn = conn),
    "'READwritesqlite_meta' is a reserved table"
  )
})

test_that("rws_write.data.frame checks table exists", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3))
  expect_error(
    rws_write(local, conn = conn),
    "^Table 'local' does not exist[.]$"
  )
})

test_that("rws_write.data.frame writes to existing table", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, local)
})

test_that("rws_write.data.frame errors if exists = FALSE and already exists", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  expect_error(rws_write(local, exists = FALSE, conn = conn), "^Table 'local' already exists[.]$")
})

test_that("rws_write.data.frame creates table", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3, select = 1:3)
  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, local)
})

test_that("rws_write.data.frame handling of case", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  DBI::dbCreateTable(conn, "`LOCAL`", local)
  expect_identical(rws_write(local, conn = conn), "local")
  expect_identical(rws_write(local, x_name = "LOCAL", conn = conn), "LOCAL")
  LOCAL <- local
  expect_identical(rws_write(LOCAL, conn = conn), "LOCAL")
  expect_identical(rws_write(LOCAL, x_name = "`LOCAL`", conn = conn), "`LOCAL`")

  remote <- DBI::dbReadTable(conn, "LOCAL")
  expect_identical(remote, rbind(local, local, local))

  REMOTE <- DBI::dbReadTable(conn, "`LOCAL`")
  expect_identical(REMOTE, LOCAL)
})

test_that("rws_write.data.frame deals with \" quoted table names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3, select = 1:3)
  locals <- data.frame(y = 1:2)
  DBI::dbCreateTable(conn, "local", local)
  DBI::dbCreateTable(conn, '"local"', locals)
  expect_identical(rws_list_tables(conn), sort(c("\"local\"", "local")))

  expect_identical(rws_write(local, conn = conn), "local")
  expect_identical(rws_write(locals, x_name = "\"local\"", conn = conn), "\"local\"")
  remotes <- DBI::dbReadTable(conn, "\"local\"")
  expect_identical(remotes, locals)
})

test_that("rws_write.data.frame deals with [ quoted table names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3, select = 1:3)
  locals <- data.frame(y = 1:2)
  DBI::dbCreateTable(conn, "local", local)
  DBI::dbCreateTable(conn, "[local]", locals)
  expect_identical(rws_list_tables(conn), sort(c("[local]", "local")))

  expect_identical(rws_write(local, conn = conn), "local")
  expect_identical(rws_write(locals, x_name = "[local]", conn = conn), "[local]")
  remotes <- as.data.frame(rws_read_table("[local]", conn = conn))
  expect_identical(remotes, locals)
})

test_that("rws_write.data.frame deals with backtick quoted table names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3, select = 1:3)
  locals <- data.frame(y = 1:2)
  DBI::dbCreateTable(conn, "local", local)
  DBI::dbCreateTable(conn, "`local`", locals)
  expect_identical(rws_list_tables(conn), sort(c("`local`", "local")))

  expect_identical(rws_write(local, conn = conn), "local")
  expect_identical(rws_write(locals, x_name = "`local`", conn = conn), "`local`")
  remotes <- DBI::dbReadTable(conn, "`local`")
  expect_identical(remotes, locals)
})

test_that("rws_write.data.frame corrects column order", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 4:6, select = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  expect_identical(rws_write(local[2:1], x_name = "local", conn = conn), "local")
  expect_error(
    rws_write(local[c(1, 1, 2)], x_name = "local", conn = conn),
    "^The following column in data 'local' is unrecognised: 'x.1'[.]$"
  )
  expect_warning(
    rws_write(local[c(1, 1, 2)], x_name = "local", conn = conn, strict = FALSE),
    "^The following column in data 'local' is unrecognised: 'x.1'"
  )
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, rbind(local, local, local))
})

test_that("rws_write.data.frame warns for extra columns", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 4:6, y = 1:3)
  DBI::dbCreateTable(conn, "local", local["x"])
  expect_error(
    rws_write(local, conn = conn),
    "^The following column in data 'local' is unrecognised: 'y'[.]$"
  )
  expect_warning(
    rws_write(local, conn = conn, strict = FALSE),
    "^The following column in data 'local' is unrecognised: 'y'[.]$"
  )
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, local["x"])
})

test_that("rws_write.data.frame is case insensitive", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3), seLect = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  colnames(local) <- toupper(colnames(local))

  expect_identical(rws_write(local, conn = conn), "local")
})

test_that("rws_write.data.frame deals with quoted column names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- tibble::tibble(x = factor(1:3), `[x]` = factor(2:4), `"x"` = factor(3:5))
  expect_identical(rws_write(local, conn = conn, exists = FALSE), "local")

  meta <- rws_read_meta(conn)
  expect_identical(meta$ColumnMeta, sort(c("\"x\"", "[x]", "X")))
  expect_identical(
    DBI::dbReadTable(conn, "local"),
    data.frame(
      x = as.character(1:3),
      X.x. = as.character(2:4),
      X.x..1 = as.character(3:5),
      stringsAsFactors = FALSE
    )
  )
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)
})

test_that("rws_write.data.frame can delete", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  rws_write(local, conn = conn)
  rws_write(local, delete = TRUE, conn = conn)
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, local)
})

test_that("rws_write.data.frame can not commit", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  rws_write(local, commit = FALSE, conn = conn)
  remote <- DBI::dbReadTable(conn, "local")
  expect_equal(local[integer(0), , drop = FALSE], remote)
  expect_false(DBI::dbExistsTable(conn, "readwritesqlite_meta"))
  expect_false(DBI::dbExistsTable(conn, "readwritesqlite_log"))
})

test_that("rws_write.list errors with none data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- list(x = 1)
  expect_error(rws_write(y, conn = conn), "^List `y` includes objects which are not data frames[.]$")
})

test_that("rws_write.environment issues warning with no data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- new.env()
  assign("x", 1, envir = y)
  expect_warning(rws_write(y, conn = conn), "^Environment 'y' has no data frames[.]$")
})

test_that("rws_write.list requires named list", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- list(data.frame(x = 1:3))
  expect_error(rws_write(y, conn = conn), "^`x` must be named[.]$",
    class = "chk_error"
  )
})

test_that("rws_write writes list with 1 data frame", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- list(local = data.frame(x = 1:3))

  DBI::dbCreateTable(conn, "local", y$local)
  expect_identical(rws_write(y, conn = conn), "local")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, y$local)
})

test_that("rws_write writes list with 2 data frame", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- list(local = data.frame(x = 1:3), local2 = data.frame(y = 1:4))

  DBI::dbCreateTable(conn, "local", y$local)
  DBI::dbCreateTable(conn, "local2", y$local2)
  expect_identical(rws_write(y, conn = conn), c("local", "local2"))
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, y$local)
  remote2 <- DBI::dbReadTable(conn, "local2")
  expect_identical(remote2, y$local2)
})

test_that("rws_write writes list with 2 identically named data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- list(local = data.frame(x = 1:3), LOCAL = data.frame(x = 1:4))

  DBI::dbCreateTable(conn, "LOCAL", y$local)
  expect_identical(rws_write(y, conn = conn, unique = FALSE), c("local", "LOCAL"))
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, rbind(y$local, y$LOCAL))
})

test_that("rws_write errors if list with 2 identically named data frames and complete = TRUE", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- list(local = data.frame(x = 1:3), LOCAL = data.frame(x = 1:4))

  DBI::dbCreateTable(conn, "LOCAL", y$local)
  expect_error(
    rws_write(y, unique = TRUE, conn = conn),
    "^The following table name is duplicated: 'local'; but unique = TRUE[.]$"
  )
})

test_that("rws_write errors if complete = TRUE and not all data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- list(local = data.frame(x = 1:3))

  DBI::dbCreateTable(conn, "LOCAL", y$local)
  DBI::dbCreateTable(conn, "LOCAL2", y$local)
  expect_error(
    rws_write(y, all = TRUE, conn = conn),
    "^The following table name is not represented: 'LOCAL2'; but all = TRUE and exists != FALSE[.]$"
  )
})

test_that("rws_write errors if strict = TRUE and exists = TRUE and extra data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- list(local = data.frame(x = 1:3), local2 = data.frame(y = 1:2))

  DBI::dbCreateTable(conn, "LOCAL", y$local)
  expect_error(
    rws_write(y, conn = conn),
    "^The following data frame in 'y' is unrecognised: 'local2'; but exists = TRUE[.]$"
  )
  expect_warning(
    rws_write(y, strict = FALSE, conn = conn),
    "^The following data frame in 'y' is unrecognised: 'local2'; but exists = TRUE[.]$"
  )
})

test_that("rws_write writes environment", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3)
  z <- 1

  expect_identical(rws_write(environment(), conn = conn, exists = FALSE), "local")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, local)
})

test_that("rws_write not commits", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  y <- list(local = data.frame(x = 1:3), LOCAL = data.frame(x = 1:4))

  expect_identical(rws_write(y, exists = NA, commit = FALSE, unique = FALSE, conn = conn), c("local", "LOCAL"))
  expect_identical(DBI::dbListTables(conn), character(0))
  expect_identical(rws_write(y, exists = NA, commit = TRUE, unique = FALSE, conn = conn), c("local", "LOCAL"))
  expect_identical(DBI::dbListTables(conn), c("local", "readwritesqlite_init", "readwritesqlite_log", "readwritesqlite_meta"))
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, rbind(y$local, y$LOCAL))
})

test_that("replace rows PRIMARY KEY constraints", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  DBI::dbExecute(conn, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL,
                  y INTEGER)")

  local <- data.frame(x = 1:3, y = 2:4)
  expect_identical(rws_write(local, conn = conn), "local")
  local$x <- c(1:2, 4L)
  local$y <- local$y + 10L
  expect_error(rws_write(local, conn = conn), "UNIQUE constraint failed: local.x")
  expect_identical(rws_write(local, replace = TRUE, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::tibble(x = 1:4, y = c(12L, 13L, 4L, 14L)))
  expect_identical(rws_write(local, replace = TRUE, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::tibble(x = 1:4, y = c(12L, 13L, 4L, 14L)))
  expect_error(rws_write(local, conn = conn), "UNIQUE constraint failed: local.x")

  expect_identical(rws_write(local, delete = TRUE, replace = TRUE, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote$x[1] <- 5L
  expect_identical(rws_write(local, delete = TRUE, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  expect_identical(
    sort(DBI::dbListTables(conn)),
    c("local", "readwritesqlite_init", "readwritesqlite_log", "readwritesqlite_meta")
  )
})

test_that("replace rows UNIQUE constraints in unique key", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  DBI::dbExecute(conn, "CREATE TABLE local (
                  x INTEGER UNIQUE NOT NULL,
                  y INTEGER)")

  local <- data.frame(x = 1:3, y = 2:4)
  expect_identical(rws_write(local, conn = conn), "local")
  local$x <- c(1:2, 4L)
  local$y <- local$y + 10L
  expect_error(rws_write(local, conn = conn), "UNIQUE constraint failed: local.x")
  expect_identical(rws_write(local, replace = TRUE, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(sort(remote$x), 1:4)
  expect_identical(sort(remote$y), c(4L, 12L, 13L, 14L))
  expect_identical(rws_write(local, replace = TRUE, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(sort(remote$x), 1:4)
  expect_identical(sort(remote$y), c(4L, 12L, 13L, 14L))
  expect_error(rws_write(local, conn = conn), "UNIQUE constraint failed: local.x")

  expect_identical(rws_write(local, delete = TRUE, replace = TRUE, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote$x[1] <- 5L
  expect_identical(rws_write(local, delete = TRUE, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("replace rows with FOREIGN key", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  DBI::dbExecute(conn, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")

  DBI::dbExecute(conn, "CREATE TABLE local2 (
                  x INTEGER NOT NULL PRIMARY KEY,
                  y INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")

  local <- data.frame(x = 1:4)
  expect_identical(rws_write(local, conn = conn), "local")

  local2 <- data.frame(x = c(1:2, 4L))
  local2$y <- local2$x + 10L
  expect_identical(rws_write(local2, conn = conn), "local2")

  expect_error(rws_write(local2, conn = conn), "UNIQUE constraint failed: local2.x")
  rws_write(local2, conn = conn, replace = TRUE)
})

test_that("foreign keys switched on one data frame at a time", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  DBI::dbExecute(conn, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")

  DBI::dbExecute(conn, "CREATE TABLE local2 (
                  x INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")

  y <- list(local = data.frame(x = 1:4), local2 = data.frame(x = 1:3))

  expect_error(
    rws_write(y$local2, x_name = "local2", conn = conn),
    "FOREIGN KEY constraint failed"
  )

  expect_identical(rws_write(y$local, x_name = "local", conn = conn), "local")
  expect_identical(rws_write(y$local2, x_name = "local2", conn = conn), "local2")
})

test_that("foreign keys switched off for two data frame", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  DBI::dbExecute(conn, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")

  DBI::dbExecute(conn, "CREATE TABLE local2 (
                  x INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")

  expect_false(foreign_keys(TRUE, conn))
  y <- list(local2 = data.frame(x = 1:3), local = data.frame(x = 1:4))
  expect_identical(rws_write(y, conn = conn), c("local2", "local"))
  expect_true(foreign_keys(TRUE, conn))
})

test_that("foreign keys pick up foreign key violation for two data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  DBI::dbExecute(conn, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")

  DBI::dbExecute(conn, "CREATE TABLE local2 (
                  x INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")

  expect_false(foreign_keys(FALSE, conn))
  expect_false(defer_foreign_keys(TRUE, conn))
  y <- list(local2 = data.frame(x = 1:3), local = data.frame(x = 2:3))
  expect_error(rws_write(y, conn = conn), "FOREIGN KEY constraint failed")
  expect_false(foreign_keys(TRUE, conn))
  expect_false(defer_foreign_keys(TRUE, conn))
})

test_that("strict environment with extra data frame and extra column", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  env <- new.env()

  local <- data.frame(x = 1:2, z = 2:3)

  assign("local", local, envir = env)
  assign("local2", local, envir = env)
  assign("not", 1, envir = env)

  DBI::dbCreateTable(conn, "local", local[1])
  expect_error(
    rws_write(env, conn = conn),
    "^The following data frame in 'x' is unrecognised: 'local2'; but exists = TRUE[.]$"
  )

  expect_warning(
    rws_write(env, strict = FALSE, conn = conn),
    "^The following data frame in 'x' is unrecognised: 'local2'; but exists = TRUE[.]$"
  )
  expect_warning(
    rws_write(env, strict = FALSE, conn = conn),
    "^The following column in data 'local' is unrecognised: 'z'[.]$"
  )
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, rbind(local[1], local[1]))
  expect_identical(rws_list_tables(conn), "local")
})

test_that("sf data frames with single geometry passed back", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- readwritesqlite::rws_data

  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  init <- DBI::dbReadTable(conn, "readwritesqlite_init")
  expect_identical(init, data.frame(
    TableInit = "LOCAL",
    IsInit = 1L, SFInit = "GEOMETRY",
    stringsAsFactors = FALSE
  ))
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)
})

test_that("sf data frames with two geometries and correct one passed back", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- as.data.frame(readwritesqlite::rws_data)
  local <- tibble::as_tibble(local)
  local <- local["geometry"]
  colnames(local) <- "first"
  local$second <- local$first
  local <- sf::st_sf(local, sf_column_name = "second")

  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  init <- DBI::dbReadTable(conn, "readwritesqlite_init")
  expect_identical(init, data.frame(
    TableInit = "LOCAL", IsInit = 1L, SFInit = "SECOND",
    stringsAsFactors = FALSE
  ))
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)
})

test_that("sf can change sf_column", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- as.data.frame(readwritesqlite::rws_data)
  local <- tibble::as_tibble(local)
  local <- local["geometry"]
  colnames(local) <- "first"
  local$second <- local$first
  local <- sf::st_sf(local, sf_column_name = "second")

  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  init <- DBI::dbReadTable(conn, "readwritesqlite_init")
  expect_identical(init, data.frame(
    TableInit = "LOCAL", IsInit = 1L, SFInit = "SECOND",
    stringsAsFactors = FALSE
  ))
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)
  local
})

test_that("sf data frames with two geometries and lots of other stuff and correct one passed back", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- as.data.frame(readwritesqlite::rws_data)
  local <- tibble::as_tibble(local)
  local$second <- local$geometry
  local <- sf::st_sf(local, sf_column_name = "second")

  expect_identical(rws_write(local, exists = NA, conn = conn), "local")
  init <- DBI::dbReadTable(conn, "readwritesqlite_init")
  expect_identical(init, data.frame(
    TableInit = "LOCAL", IsInit = 1L, SFInit = "SECOND",
    stringsAsFactors = FALSE
  ))
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)
})

test_that("initialized even with no rows of data", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- as.data.frame(readwritesqlite::rws_data)
  local <- tibble::as_tibble(local)
  local$second <- local$geometry
  local <- sf::st_sf(local, sf_column_name = "second")
  local <- local[integer(0), ]

  expect_identical(rws_write(local, exists = NA, conn = conn), "local")
  init <- DBI::dbReadTable(conn, "readwritesqlite_init")
  expect_identical(init, data.frame(
    TableInit = "LOCAL", IsInit = 1L, SFInit = "SECOND",
    stringsAsFactors = FALSE
  ))
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)
})

test_that("initialized meta with no rows of data and not overwritten unless delete = TRUE", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- as.data.frame(readwritesqlite::rws_data)
  local <- local["date"]
  local <- tibble::as_tibble(local)
  local <- local[integer(0), ]

  expect_identical(rws_write(local, exists = NA, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)
  local[] <- lapply(local, as.character)
  expect_error(
    rws_write(local, conn = conn),
    "^Column 'date' in table 'local' has 'No' meta data for the input data but 'class: Date' for the existing data[.]$"
  )
  local <- data.frame(date = "2000-01-01", stringsAsFactors = FALSE)

  expect_error(
    rws_write(local, conn = conn),
    "^Column 'date' in table 'local' has 'No' meta data for the input data but 'class: Date' for the existing data[.]$"
  )

  expect_identical(rws_write(local, delete = TRUE, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("initialized with no rows of data and no metadata and not overwritten unless delete = TRUE", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- as.data.frame(readwritesqlite::rws_data)
  local <- local["date"]
  local <- tibble::as_tibble(local)
  local[] <- lapply(local, as.character)
  local <- local[integer(0), ]

  expect_identical(rws_write(local, exists = NA, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)

  local2 <- as.data.frame(readwritesqlite::rws_data)
  local2 <- local2["date"]
  local2 <- tibble::as_tibble(local2)
  local2 <- local2[integer(0), ]
  expect_error(
    rws_write(local2, conn = conn, x_name = "local"),
    "^Column 'date' in table 'local' has 'class: Date' meta data for the input data but 'No' for the existing data[.]$"
  )

  expect_identical(rws_write(local2, delete = TRUE, conn = conn, x_name = "local"), "local")

  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local2)
})

test_that("initialized with no rows of data and no metadata and not overwritten unless delete = TRUE", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- as.data.frame(readwritesqlite::rws_data)
  local <- local["date"]
  local <- tibble::as_tibble(local)
  local[] <- lapply(local, as.character)
  local <- local[integer(0), ]

  expect_identical(rws_write(local, exists = NA, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)
  local2 <- as.data.frame(readwritesqlite::rws_data)
  local2 <- local2["date"]
  local2 <- tibble::as_tibble(local2)
  local2 <- local2[integer(0), ]
  expect_error(
    rws_write(local2, conn = conn, x_name = "local"),
    "^Column 'date' in table 'local' has 'class: Date' meta data for the input data but 'No' for the existing data[.]$"
  )

  expect_identical(rws_write(local2, delete = TRUE, conn = conn, x_name = "local"), "local")

  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local2)
})

test_that("meta then inconsistent data then error meta but delete reset", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- as.data.frame(readwritesqlite::rws_data)
  local$geometry <- NULL
  attr(local, "sf_column") <- NULL
  attr(local, "agr") <- NULL
  local <- tibble::as_tibble(local)
  expect_identical(rws_write(local, exists = NA, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)

  local2 <- local
  local2[] <- lapply(local2, function(x) {
    return("garbage")
  })
  local2 <- local2[1, ]

  expect_error(
    rws_write(local2, conn = conn, x_name = "local"),
    "^Column 'logical' in table 'local' has 'No' meta data for the input data but 'class: logical' for the existing data[.]$"
  )
  expect_identical(rws_write(local2, conn = conn, meta = FALSE, x_name = "local"), "local")
  expect_warning(remote <- rws_read_table("local", conn = conn), "Column `logical`: mixed type, first seen values of type integer, coercing other values of type string")
  expect_identical(remote, tibble::tibble(
    logical = c(TRUE, FALSE, NA, FALSE),
    date = as.Date(c("2000-01-01", "2001-02-03", NA, "1970-01-01")),
    factor = factor(c("x", "y", NA, NA), levels = c("x", "y")),
    ordered = ordered(c("x", "y", NA, NA), levels = c("y", "x")),
    posixct = as.POSIXct(c("2001-01-02 03:04:05", "2006-07-08 09:10:11", NA, "1969-12-31 16:00:00"),
      tz = "Etc/GMT+8"
    ),
    units = units::as_units(c(10, 11.5, NA, 0), "m")
  ))
  expect_warning(remote2 <- rws_read_table("local", meta = FALSE, conn = conn), "Column `logical`: mixed type, first seen values of type integer, coercing other values of type string")
  expect_identical(remote2, tibble::tibble(
    logical = c(1L, 0L, NA, 0L),
    date = c(10957, 11356, NA, 0),
    factor = c("x", "y", NA, "garbage"),
    ordered = c("x", "y", NA, "garbage"),
    posixct = c(978433445, 1152378611, NA, 0),
    units = c(10, 11.5, NA, 0)
  ))

  expect_identical(rws_write(local, delete = TRUE, conn = conn), "local")
  remote <- rws_read_table("local", conn = conn)
  expect_identical(remote, local)
})
