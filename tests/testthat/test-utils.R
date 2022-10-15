test_that("rws_table_names", {

  conn <- local_conn()

  expect_identical(rws_list_tables(conn), character(0))
  local <- data.frame(x = 1:3)
  z <- 1

  rws_write(local, exists = FALSE, conn = conn)
  expect_identical(rws_list_tables(conn), "local")
})
