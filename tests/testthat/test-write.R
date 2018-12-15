context("write")

test_that("rws_write_sqlite.data.frame checks reserved table names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = as.character(1:3))
  expect_error(rws_write_sqlite(local, x_name =  "readwritesqlite_log", conn = conn),
               "'readwritesqlite_log' is a reserved table")
  expect_error(rws_write_sqlite(local, x_name =  "readwritesqlite_LOG", conn = conn),
               "'readwritesqlite_LOG' is a reserved table")
  expect_error(rws_write_sqlite(local, x_name = "readwritesqlite_meta", conn = conn),
               "'readwritesqlite_meta' is a reserved table")
  expect_error(rws_write_sqlite(local, x_name = "READwritesqlite_meta", conn = conn),
               "'READwritesqlite_meta' is a reserved table")
})

test_that("rws_write_sqlite.data.frame checks table exists", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = as.character(1:3))
  expect_error(rws_write_sqlite(local, conn = conn),
               "table 'local' does not exist")
})

test_that("rws_write_sqlite.data.frame writes to existing table", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, local)
})

test_that("rws_write_sqlite.data.frame errors if exists = FALSE and already exists", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  expect_error(rws_write_sqlite(local, exists = FALSE, conn = conn), "table 'local' already exists")
})

test_that("rws_write_sqlite.data.frame creates table", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 1:3, select = 1:3)
  expect_identical(rws_write_sqlite(local, exists = FALSE, conn = conn), "local")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, local)
})

test_that("rws_write_sqlite.data.frame handling of case", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  DBI::dbCreateTable(conn, "`LOCAL`", local)
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  expect_identical(rws_write_sqlite(local, x_name = "LOCAL", conn = conn), "LOCAL")
  LOCAL <- local
  expect_identical(rws_write_sqlite(LOCAL, conn = conn), "LOCAL")
  expect_identical(rws_write_sqlite(LOCAL, x_name = "`LOCAL`", conn = conn), "`LOCAL`")
  
  remote <- DBI::dbReadTable(conn, "LOCAL")
  expect_identical(remote, rbind(local, local, local))
  
  REMOTE <- DBI::dbReadTable(conn, "`LOCAL`")
  expect_identical(REMOTE, LOCAL)
})

test_that("rws_write_sqlite.data.frame deals with \" quoted table names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 1:3, select = 1:3)
  locals <- data.frame(y = 1:2)
  DBI::dbCreateTable(conn, "local", local)
  DBI::dbCreateTable(conn, '"local"', locals)
  expect_identical(rws_list_tables(conn), sort(c("\"local\"", "local")))
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  expect_identical(rws_write_sqlite(locals, x_name = "\"local\"", conn = conn), "\"local\"")
  remotes <- DBI::dbReadTable(conn, "\"local\"")
  expect_identical(remotes, locals)
})

test_that("rws_write_sqlite.data.frame deals with [ quoted table names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 1:3, select = 1:3)
  locals <- data.frame(y = 1:2)
  DBI::dbCreateTable(conn, "local", local)
  DBI::dbCreateTable(conn, "[local]", locals)
  expect_identical(rws_list_tables(conn), sort(c("[local]", "local")))
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  expect_identical(rws_write_sqlite(locals, x_name = "[local]", conn = conn), "[local]")
  remotes <- as.data.frame(rws_read_sqlite_table("[local]", conn = conn))
  expect_identical(remotes, locals)
})

test_that("rws_write_sqlite.data.frame deals with backtick quoted table names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 1:3, select = 1:3)
  locals <- data.frame(y = 1:2)
  DBI::dbCreateTable(conn, "local", local)
  DBI::dbCreateTable(conn, "`local`", locals)
  expect_identical(rws_list_tables(conn), sort(c("`local`", "local")))
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  expect_identical(rws_write_sqlite(locals, x_name = "`local`", conn = conn), "`local`")
  remotes <- DBI::dbReadTable(conn, "`local`")
  expect_identical(remotes, locals)
})

test_that("rws_write_sqlite.data.frame corrects column order", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 4:6, select = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  expect_identical(rws_write_sqlite(local[2:1], x_name = "local", conn = conn), "local")
  expect_error(rws_write_sqlite(local[c(1,1,2)], x_name = "local", conn = conn), 
               "the following column in data 'local' is unrecognised: 'x.1'")
  expect_warning(rws_write_sqlite(local[c(1,1,2)], x_name = "local", conn = conn, strict = FALSE), 
                 "the following column in data 'local' is unrecognised: 'x.1'")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, rbind(local, local, local))
})

test_that("rws_write_sqlite.data.frame warns for extra columns", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 4:6, y = 1:3)
  DBI::dbCreateTable(conn, "local", local["x"])
  expect_error(rws_write_sqlite(local, conn = conn), 
               "the following column in data 'local' is unrecognised: 'y'")
  expect_warning(rws_write_sqlite(local, conn = conn, strict = FALSE), 
                 "the following column in data 'local' is unrecognised: 'y'")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, local["x"])
})

test_that("rws_write_sqlite.data.frame is case insensitive", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = as.character(1:3), seLect = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  colnames(local) <- toupper(colnames(local))
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
})

test_that("rws_write_sqlite.data.frame deals with quoted column names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- tibble::tibble(x = factor(1:3), `[x]` = factor(2:4), `"x"` = factor(3:5))
  expect_identical(rws_write_sqlite(local, conn = conn, exists = FALSE), "local")
  
  meta <- rws_read_sqlite_meta(conn)
  expect_identical(meta$ColumnMeta, sort(c("\"x\"", "[x]", "X")))
  expect_identical(DBI::dbReadTable(conn, "local"),
                   data.frame(x = as.character(1:3),
                              X.x. = as.character(2:4),
                              X.x..1 = as.character(3:5),
                              stringsAsFactors = FALSE))
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, local)
})

test_that("rws_write_sqlite.data.frame can delete", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  rws_write_sqlite(local, conn = conn)
  rws_write_sqlite(local, delete = TRUE, conn = conn)
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, local)
})

test_that("rws_write_sqlite.data.frame can not commit", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  rws_write_sqlite(local, commit = FALSE, conn = conn)
  remote <- DBI::dbReadTable(conn, "local")
  expect_equal(local[integer(0),,drop = FALSE], remote)
  expect_false(DBI::dbExistsTable(conn, "readwritesqlite_meta"))
  expect_false(DBI::dbExistsTable(conn, "readwritesqlite_log"))
})

test_that("rws_write_sqlite.list errors with none data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  y <- list(x = 1)
  expect_error(rws_write_sqlite(y, conn = conn), "list 'y' includes objects which are not data frames")
})

test_that("rws_write_sqlite.environment issues warning with no data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  y <- new.env()
  assign("x", 1, envir = y)
  expect_warning(rws_write_sqlite(y, conn = conn), "environment 'y' has no data frames")
})

test_that("rws_write_sqlite.list requires named list", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  y <- list(data.frame(x = 1:3))
  expect_error(rws_write_sqlite(y, conn = conn), "x must be named")
})

test_that("rws_write_sqlite writes list with 1 data frame", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  y <- list(local = data.frame(x = 1:3))
  
  DBI::dbCreateTable(conn, "local", y$local)
  expect_identical(rws_write_sqlite(y, conn = conn), "local")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, y$local)
})

test_that("rws_write_sqlite writes list with 2 data frame", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  y <- list(local = data.frame(x = 1:3), local2 = data.frame(y = 1:4))
  
  DBI::dbCreateTable(conn, "local", y$local)
  DBI::dbCreateTable(conn, "local2", y$local2)
  expect_identical(rws_write_sqlite(y, conn = conn), c("local", "local2"))
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, y$local)
  remote2 <- DBI::dbReadTable(conn, "local2")
  expect_identical(remote2, y$local2)
})

test_that("rws_write_sqlite writes list with 2 identically named data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  y <- list(local = data.frame(x = 1:3), LOCAL = data.frame(x = 1:4))
  
  DBI::dbCreateTable(conn, "LOCAL", y$local)
  expect_identical(rws_write_sqlite(y, conn = conn, unique = FALSE), c("local", "LOCAL"))
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, rbind(y$local, y$LOCAL))
})

test_that("rws_write_sqlite errors if list with 2 identically named data frames and complete = TRUE", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  y <- list(local = data.frame(x = 1:3), LOCAL = data.frame(x = 1:4))
  
  DBI::dbCreateTable(conn, "LOCAL", y$local)
  expect_error(rws_write_sqlite(y, unique = TRUE, conn = conn), 
               "unique = TRUE but the following table name is duplicated: 'local'")
})

test_that("rws_write_sqlite errors if complete = TRUE and not all data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  y <- list(local = data.frame(x = 1:3))
  
  DBI::dbCreateTable(conn, "LOCAL", y$local)
  DBI::dbCreateTable(conn, "LOCAL2", y$local)
  expect_error(rws_write_sqlite(y, all = TRUE, conn = conn), 
               "all = TRUE and exists != FALSE but the following table name is not represented: 'LOCAL2'")
})

test_that("rws_write_sqlite errors if strict = TRUE and exists = TRUE and extra data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  y <- list(local = data.frame(x = 1:3), local2 = data.frame(y = 1:2))
  
  DBI::dbCreateTable(conn, "LOCAL", y$local)
  expect_error(rws_write_sqlite(y, conn = conn), 
               "exists = TRUE but the following data frame in 'y' is unrecognised: 'local2'")
  expect_warning(rws_write_sqlite(y, strict = FALSE, conn = conn), 
                 "exists = TRUE but the following data frame in 'y' is unrecognised: 'local2'")
})

test_that("rws_write_sqlite writes environment", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local = data.frame(x = 1:3)
  z <- 1
  
  expect_identical(rws_write_sqlite(environment(), conn = conn, exists = FALSE), "local")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, local)
})

test_that("rws_write_sqlite not commits", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  y <- list(local = data.frame(x = 1:3), LOCAL = data.frame(x = 1:4))
  
  expect_identical(rws_write_sqlite(y, exists = NA, commit = FALSE, unique = FALSE, conn = conn), c("local", "LOCAL"))
  expect_identical(DBI::dbListTables(conn), character(0))
  expect_identical(rws_write_sqlite(y, exists = NA, commit = TRUE, unique = FALSE, conn = conn), c("local", "LOCAL"))
  expect_identical(DBI::dbListTables(conn), c("local", "readwritesqlite_init", "readwritesqlite_log", "readwritesqlite_meta"))
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, rbind(y$local, y$LOCAL))
})

test_that("foreign keys switched on one data frame at a time", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")
  
  DBI::dbGetQuery(conn, "CREATE TABLE local2 (
                  x INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")
  
  y <- list(local = data.frame(x = 1:4), local2 = data.frame(x = 1:3))
  
  expect_error(rws_write_sqlite(y$local2, x_name = "local2", conn = conn), 
               "FOREIGN KEY constraint failed")
  
  expect_identical(rws_write_sqlite(y$local, x_name = "local", conn = conn), "local")
  expect_identical(rws_write_sqlite(y$local2, x_name = "local2", conn = conn), "local2")
})

test_that("foreign keys switched off for two data frame", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")
  
  DBI::dbGetQuery(conn, "CREATE TABLE local2 (
                  x INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")
  
  expect_false(foreign_keys(TRUE, conn))
  y <- list(local2 = data.frame(x = 1:3), local = data.frame(x = 1:4))
  expect_identical(rws_write_sqlite(y, conn = conn), c("local2", "local"))
  expect_true(foreign_keys(TRUE, conn))
})

test_that("foreign keys pick up foreign key violation for two data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")
  
  DBI::dbGetQuery(conn, "CREATE TABLE local2 (
                  x INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")
  
  expect_false(foreign_keys(FALSE, conn))
  expect_false(defer_foreign_keys(TRUE, conn))
  y <- list(local2 = data.frame(x = 1:3), local = data.frame(x = 2:3))
  expect_error(rws_write_sqlite(y, conn = conn), "FOREIGN KEY constraint failed")
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
  expect_error(rws_write_sqlite(env, conn = conn),
               "exists = TRUE but the following data frame in 'x' is unrecognised: 'local2'")
  
  expect_warning(rws_write_sqlite(env, strict = FALSE, conn = conn),
                 "exists = TRUE but the following data frame in 'x' is unrecognised: 'local2'")
  expect_warning(rws_write_sqlite(env, strict = FALSE, conn = conn),
                 "the following column in data 'local' is unrecognised: 'z'")
  remote <- DBI::dbReadTable(conn, "local")
  expect_identical(remote, rbind(local[1], local[1]))
  expect_identical(rws_list_tables(conn), "local")
})

test_that("sf data frames with single geometry passed back", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- sf::st_sf(rws_data["geometry"])
  
  DBI::dbCreateTable(conn, "local", local)  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  init <- DBI::dbReadTable(conn, "readwritesqlite_init")
  expect_identical(init, data.frame(TableInit = "LOCAL", 
                                    IsInit = 1L, SFInit = "GEOMETRY",
                                  stringsAsFactors = FALSE))
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, local)
})

test_that("sf data frames with two geometries and correct one passed back", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  
  local <- rws_data["geometry"]
  colnames(local) <- "first"
  local$second <- local$first
  local <- sf::st_sf(local, sf_column_name = "second")
  
  DBI::dbCreateTable(conn, "local", local)  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
  expect_identical(sf, data.frame(TableSF = "LOCAL", ColumnSF = "SECOND",
                                  stringsAsFactors = FALSE))
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, local)
})

test_that("sf can change sf_column", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- rws_data["geometry"]
  colnames(local) <- "first"
  local$second <- local$first
  local <- sf::st_sf(local, sf_column_name = "second")
  
  DBI::dbCreateTable(conn, "local", local)  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
  expect_identical(sf, data.frame(TableSF = "LOCAL", ColumnSF = "SECOND",
                                  stringsAsFactors = FALSE))
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, local)
  local
})

test_that("sf data frames with two geometries and lots of other stuff and correct one passed back", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- rws_data
  local$second <- local$geometry
  local <- sf::st_sf(local, sf_column_name = "second")
  
  expect_identical(rws_write_sqlite(local, exists = NA, conn = conn), "local")
  sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
  expect_identical(sf, data.frame(TableSF = "LOCAL", ColumnSF = "SECOND",
                                  stringsAsFactors = FALSE))
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, local)
})

test_that("initialized even with no rows of data", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- rws_data
  local$second <- local$geometry
  local <- sf::st_sf(local, sf_column_name = "second")
  local <- local[integer(0),]
  
  expect_identical(rws_write_sqlite(local, exists = NA, conn = conn), "local")
  sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
  expect_identical(sf, data.frame(TableSF = "LOCAL", ColumnSF = "SECOND",
                                  stringsAsFactors = FALSE))
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, local)
})

test_that("initialized meta with no rows of data and not overwritten unless delete = TRUE", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- rws_data["date"]
  local <- local[integer(0),]
  
  expect_identical(rws_write_sqlite(local, exists = NA, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, local)
  local[] <- lapply(local, as.character)
  expect_error(rws_write_sqlite(local, conn = conn),
               "column 'date' in table 'local' has 'No' meta data for the input data but 'class: Date' for the existing data")
  local <- data.frame(date = "2000-01-01", stringsAsFactors = FALSE)
  
  expect_error(rws_write_sqlite(local, conn = conn),
               "column 'date' in table 'local' has 'No' meta data for the input data but 'class: Date' for the existing data")
  
  expect_identical(rws_write_sqlite(local, delete = TRUE, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("initialized with no rows of data and no metadata and not overwritten unless delete = TRUE", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- rws_data["date"]
  local[] <- lapply(local, as.character)
  local <- local[integer(0),]
  
  expect_identical(rws_write_sqlite(local, exists = NA, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, local)
  local2 <- rws_data["date"]
  local2 <- local2[integer(0),]
  # expect_error(rws_write_sqlite(local2, conn = conn, x_name = "local"), 
  #              "column 'date' in table 'local' has 'class: Date' meta data for the input data but 'No' for the existing data")
  # 
  # expect_identical(rws_write_sqlite(local2, delete = TRUE, conn = conn, x_name = "local"), "local")
  # 
  # remote <- rws_read_sqlite_table("local", conn = conn)
  # expect_identical(remote, local2)
})
