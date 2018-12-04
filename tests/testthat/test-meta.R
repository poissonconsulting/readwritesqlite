context("metad")

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
#  expect_identical(rws_write_sqlite(local), "local")
  
#  meta <- rws_read_sqlite_meta()
#  expect_identical(meta, tibble::tibble(TableMeta = "LOCAL",
                                        # ColumnMeta = "Z",
                                        # MetaMeta = "class: logical",
                                        # DescriptionMeta = NA_character_))
                                        # 
#  remote <- rws_read_sqlite("local")
#  expect_identical(remote$local, tibble::as_tibble(local))
})


