context("describe")

test_that("describe with scalars works", {
  conn <- rws_open_connection(":memory:")
  teardown(rws_close_connection(conn))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  meta <- rws_describe_meta("local", "Z", "A logical vector.", conn = conn)
  expect_identical(meta, tibble::tibble(TableMeta = "LOCAL",
                                        ColumnMeta = "Z",
                                        MetaMeta = "class: logical",
                                        DescriptionMeta = "A logical vector."))
  expect_identical(rws_read_meta(conn), meta)
})

test_that("describe with vector works", {
  conn <- rws_open_connection(":memory:")
  teardown(rws_close_connection(conn))
  
  local <- data.frame(z = c(TRUE, FALSE, NA), y = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  meta <- rws_describe_meta("local", c("y", "Z"), c("stuff", "A logical vector."), conn = conn)
  expect_identical(meta, tibble::tibble(TableMeta = c("LOCAL", "LOCAL"),
                                        ColumnMeta = c("Y", "Z"),
                                        MetaMeta = c(NA, "class: logical"),
                                        DescriptionMeta = c("stuff", "A logical vector.")))
  expect_identical(rws_read_meta(conn), meta)
})

test_that("describe errors with strict", {
  conn <- rws_open_connection(":memory:")
  teardown(rws_close_connection(conn))
  
  local <- data.frame(z = c(TRUE, FALSE, NA), y = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  expect_error(rws_describe_meta("local", c("y", "Z2"), c("stuff", "A logical vector."), conn = conn), "all description tables and columns must exist in the meta table")
  meta <- rws_describe_meta("local", c("y", "Z2"), c("stuff", "A logical vector."),
                            strict = FALSE, conn = conn)
  
  expect_identical(meta, tibble::tibble(TableMeta = c("LOCAL", "LOCAL"),
                                        ColumnMeta = c("Y", "Z"),
                                        MetaMeta = c(NA, "class: logical"),
                                        DescriptionMeta = c("stuff", NA)))
  expect_identical(rws_read_meta(conn), meta)
})

test_that("describe replace works", {
  conn <- rws_open_connection(":memory:")
  teardown(rws_close_connection(conn))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write(local, conn = conn), "local")
  meta <- rws_describe_meta("local", "Z", "A logical vector.", conn = conn)
  expect_identical(meta, tibble::tibble(TableMeta = "LOCAL",
                                        ColumnMeta = "Z",
                                        MetaMeta = "class: logical",
                                        DescriptionMeta = "A logical vector."))
  meta <- rws_describe_meta("local", "Z", " More info.", conn = conn)
  expect_identical(meta, tibble::tibble(TableMeta = "LOCAL",
                                        ColumnMeta = "Z",
                                        MetaMeta = "class: logical",
                                        DescriptionMeta = " More info."))
  meta <- rws_describe_meta("local", "Z", " More info.", paste0 = TRUE, conn = conn)
  expect_identical(meta, tibble::tibble(TableMeta = "LOCAL",
                                        ColumnMeta = "Z",
                                        MetaMeta = "class: logical",
                                        DescriptionMeta = " More info. More info."))
  
  meta <- rws_describe_meta("local", "Z", NA_character_, paste0 = TRUE, conn = conn)
  expect_identical(meta, tibble::tibble(TableMeta = "LOCAL",
                                        ColumnMeta = "Z",
                                        MetaMeta = "class: logical",
                                        DescriptionMeta = " More info. More info."))
  meta <- rws_describe_meta("local", "Z", NA_character_, paste0 = FALSE, conn = conn)
  expect_identical(meta, tibble::tibble(TableMeta = "LOCAL",
                                        ColumnMeta = "Z",
                                        MetaMeta = "class: logical",
                                        DescriptionMeta = NA_character_))
})
