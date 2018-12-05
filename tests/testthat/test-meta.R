context("metad")

test_that("make_meta_data works", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  
  local <- data.frame(x = as.character(1:3))
  
  expect_identical(make_meta_data(con), 
                   data.frame(TableMeta = character(0), ColumnMeta = character(0), 
                              stringsAsFactors = FALSE))
  expect_true(DBI::dbCreateTable(con, "loCal", local))
  expect_identical(make_meta_data(con), data.frame(TableMeta = "LOCAL",
                                                       ColumnMeta = "X",
                                                       stringsAsFactors = FALSE))
  expect_true(DBI::dbCreateTable(con, "loCal2", local))
  expect_identical(make_meta_data(con), data.frame(TableMeta = c("LOCAL", "LOCAL2"),
                                                       ColumnMeta = c("X", "X"),
                                                       stringsAsFactors = FALSE))
})

test_that("read_sqlite_meta creates table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  meta <- rws_read_sqlite_meta()
  expect_identical(colnames(meta),
                   c("TableMeta", "ColumnMeta", "MetaMeta", "DescriptionMeta"))
  expect_identical(nrow(meta), 0L)
})

test_that("meta handles logical", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  DBI::dbCreateTable(con, "local", local)
  expect_identical(rws_write_sqlite(local), "local")
  meta <- rws_read_sqlite_meta()
  expect_identical(meta, tibble::tibble(TableMeta = "LOCAL",
  ColumnMeta = "Z",
  MetaMeta = "class: logical",
  DescriptionMeta = NA_character_))
})
