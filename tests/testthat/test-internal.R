context("internal")

test_that("schema_table_name gets table name from schema", {
  expect_identical(schema_table_name("CREATE TABL Data ("), character(0))
  expect_identical(schema_table_name("CREATE TABLE Data ("), "Data")
  expect_identical(schema_table_name("CREATE TABLE Data(TABLE"), "Data")
  expect_identical(schema_table_name("create table data ("), "data")
  expect_identical(schema_table_name("CREATE TABLE `local` (\n"), "local")
  expect_identical(schema_table_name("CREATE TABLE `local` (\n"), "local")
})

test_that("schema_references gets foreign keys from schema", {
  expect_identical(schema_references("REFERENCE Station ("), character(0))
  expect_identical(schema_references("REFERENCES Station ("), "Station")
  expect_identical(schema_references("REFERENCES Station ( REFERENCES Station2("),
                   c("Station", "Station2"))
})
