context("internal")

test_that("test query_table_names", {
  expect_identical(query_table_names(""), character(0))
  expect_identical(query_table_names("FROM"), character(0))
  expect_identical(query_table_names("FROM table"), "TABLE")
  expect_identical(query_table_names("SELECT * FROM table2"), "TABLE2")
  expect_identical(
    query_table_names("SELECT col1, col2 FROM table3, table2"),
    c("TABLE2", "TABLE3")
  )
  expect_identical(
    query_table_names(
      "SELECT col1, col2 FROM table3, table2 INNER JOIN xx"
    ),
    c("TABLE2", "TABLE3", "XX")
  )

  expect_identical(
    query_table_names(
      "SELECT col1, col2 FROM table3,  table2 , TableN OUTER JOIN (SELECT * FROM table0 INNER JOIN tablec) newname"
    ),
    c("TABLE0", "TABLE2", "TABLE3", "TABLEC", "TABLEN")
  )

  expect_identical(
    query_table_names(
      "SELECT `col1`, `col2` FROM `table3`,  [table2] , TableN OUTER JOIN (SELECT * FROM table0 INNER JOIN \"tablec\") newname"
    ),
    sort(c("\"tablec\"", "[table2]", "`table3`", "TABLE0", "TABLEN"))
  )
})
