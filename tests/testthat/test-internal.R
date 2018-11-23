context("internal")

test_that("table_name gets table name from schema", {
  expect_identical(table_name("CREATE TABL Data ("), character(0))
  expect_identical(table_name("CREATE TABLE Data ("), "Data")
  expect_identical(table_name("CREATE TABLE Data(TABLE"), "Data")
  expect_identical(table_name("create table data ("), "data")
  expect_identical(table_name("CREATE TABLE `local` (\n"), "local")
  expect_identical(table_name("CREATE TABLE `local` (\n"), "local")
})

test_that("table_foreign_keys gets foreign keys from schema", {
  expect_identical(table_foreign_keys("REFERENCE Station ("), character(0))
  expect_identical(table_foreign_keys("REFERENCES Station ("), "Station")
  expect_identical(table_foreign_keys("REFERENCES Station ( REFERENCES Station2("),
                   c("Station", "Station2"))
})
