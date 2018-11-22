context("metad")

test_that("dbReadMetaTableSQLite creates table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  meta <- dbReadMetaTableSQLite(con)
  expect_identical(colnames(meta),
                   c("TableMeta", "ColumnMeta", "MetaMeta", "DescriptionMeta"))
  expect_identical(nrow(meta), 0L)
})

