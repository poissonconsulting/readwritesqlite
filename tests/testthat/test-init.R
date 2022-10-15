test_that("init makes table", {
  conn <- local_conn()
  
  expect_identical(
    rws_read_init(conn = conn),
    tibble::tibble(
      TableInit = character(0), IsInit = integer(0),
      SFInit = character(0)
    )
  )
  local <- data.frame(x = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(
    rws_read_init(conn = conn),
    tibble::tibble(
      TableInit = "LOCAL", IsInit = 0L,
      SFInit = NA_character_
    )
  )
  DBI::dbAppendTable(conn, "local", local)
  expect_identical(
    rws_read_init(conn = conn),
    tibble::tibble(
      TableInit = "LOCAL", IsInit = 1L,
      SFInit = NA_character_
    )
  )
  local2 <- local[integer(0), , drop = FALSE]
  expect_identical(
    rws_write(local2, conn = conn, exists = NA),
    "local2"
  )
  expect_identical(
    rws_read_init(conn = conn),
    tibble::tibble(
      TableInit = c("LOCAL", "LOCAL2"),
      IsInit = c(1L, 1L),
      SFInit = rep(NA_character_, 2)
    )
  )
  rws_data_sf <- as.data.frame(rws_data_sf)
  rws_data_sf <- tibble::as_tibble(rws_data_sf)
  local3 <- rws_data_sf
  expect_identical(
    rws_write(local3, conn = conn, exists = NA),
    "local3"
  )
  expect_identical(
    rws_read_init(conn = conn),
    tibble::tibble(
      TableInit = c("LOCAL", "LOCAL2", "LOCAL3"),
      IsInit = c(1L, 1L, 1L),
      SFInit = rep(NA_character_, 3)
    )
  )
  local4 <- rws_data_sf
  local4 <- sf::st_sf(local4, sf_column_name = "geometry")
  expect_identical(
    rws_write(local4, conn = conn, exists = NA),
    "local4"
  )
  expect_identical(
    rws_read_init(conn = conn),
    tibble::tibble(
      TableInit = c("LOCAL", "LOCAL2", "LOCAL3", "LOCAL4"),
      IsInit = c(1L, 1L, 1L, 1L),
      SFInit = c(rep(NA_character_, 3), "GEOMETRY")
    )
  )
  local5 <- local4[integer(0), ]
  expect_identical(
    rws_write(local5, conn = conn, exists = NA),
    "local5"
  )
  expect_identical(
    rws_read_init(conn = conn),
    tibble::tibble(
      TableInit = c(
        "LOCAL", "LOCAL2", "LOCAL3",
        "LOCAL4", "LOCAL5"
      ),
      IsInit = c(1L, 1L, 1L, 1L, 1L),
      SFInit = c(rep(NA_character_, 3), "GEOMETRY", "GEOMETRY")
    )
  )


  # local7 <- local4
  # expect_identical(rws_write(local7, conn = conn, meta = FALSE, exists = NA),
  #                  "local7")
  # expect_identical(rws_read_init(conn = conn),
  #                  tibble::tibble(TableInit = c("LOCAL", "LOCAL2", "LOCAL3",
  #                                               "LOCAL4", "LOCAL5", "LOCAL6", "LOCAL7"),
  #                                 IsInit = c(1L, 1L, 1L, 1L, 1L, 0L, 1L),
  #                                 SFInit = c(rep(NA_character_, 3),
  #                                            rep("GEOMETRY", 2), NA_character_)))
})

#
# test_that("sfc data frames stays sfc even if sf written", {
# 
#   conn <- local_conn()
#
#   local <- rws_data_sf
#   expect_identical(rws_write(local, exists = NA, conn = conn), "local")
#   sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
#   expect_identical(sf, data.frame(TableSF = character(0), ColumnSF = character(0),
#                                   stringsAsFactors = FALSE))
#
#   remote <- rws_read_table("local", conn = conn)
#   expect_identical(remote, local)
#
#   local2 <- sf::st_sf(local, sf_column_name = "geometry")
#   expect_identical(rws_write(local2, conn = conn, x_name = "local"), "local")
#   expect_identical(sf, data.frame(TableSF = character(0), ColumnSF = character(0),
#                                   stringsAsFactors = FALSE))
#
#   remote <- rws_read_table("local", conn = conn)
#   local2 <- rbind(local2, local2)
#   expect_identical(remote, local2)
# })
#
# test_that("sfc data frames stays sf even if sfc written", {
# 
#   conn <- local_conn()
#
#   local <- rws_data_sf
#   local <- sf::st_sf(local, sf_column_name = "geometry")
#
#   expect_identical(rws_write(local, exists = NA, conn = conn), "local")
#   sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
#   expect_identical(sf, data.frame(TableSF = "LOCAL", ColumnSF = "GEOMETRY",
#                                   stringsAsFactors = FALSE))
#
#   local2 <- as.data.frame(local)
#
#   expect_identical(rws_write(local2, exists = NA, conn = conn,
#                                     x_name = "local"), "local")
#   sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
#
#   expect_identical(sf, data.frame(TableSF = "LOCAL", ColumnSF = "GEOMETRY",
#                                   stringsAsFactors = FALSE))
#
#   remote <- rws_read_table("local", conn = conn)
#   local <- rbind(local, local)
#   expect_identical(remote, local)
# })
#
# test_that("sf data frames stays sf even if sfc written", {
# 
#   conn <- local_conn()
#
#   local <- rws_data_sf
#   local <- sf::st_sf(local, sf_column_name = "geometry")
#
#   expect_identical(rws_write(local, exists = NA, conn = conn), "local")
#   sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
#   expect_identical(sf, data.frame(TableSF = "LOCAL", ColumnSF = "GEOMETRY",
#                                   stringsAsFactors = FALSE))
#
#   local2 <- as.data.frame(local)
#
#   expect_identical(rws_write(local2, exists = NA, conn = conn,
#                                     x_name = "local"), "local")
#   sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
#
#   expect_identical(sf, data.frame(TableSF = "LOCAL", ColumnSF = "GEOMETRY",
#                                   stringsAsFactors = FALSE))
#
#   remote <- rws_read_table("local", conn = conn)
#   local <- rbind(local, local)
#   expect_identical(remote, local)
# })
#
# test_that("sf data frames reset if delete = TRUE", {
# 
#   conn <- local_conn()
#
#   local <- rws_data_sf
#   local <- sf::st_sf(local, sf_column_name = "geometry")
#
#   expect_identical(rws_write(local, exists = NA, conn = conn), "local")
#   sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
#   expect_identical(sf, data.frame(TableSF = "LOCAL", ColumnSF = "GEOMETRY",
#                                   stringsAsFactors = FALSE))
#
#   local2 <- as.data.frame(local)
#
#   expect_identical(rws_write(local2, exists = NA, conn = conn,
#                                     delete = TRUE, x_name = "local"), "local")
#   sf <- DBI::dbReadTable(conn, "readwritesqlite_sf")
#
#   expect_identical(sf, data.frame(TableSF = character(0), ColumnSF = character(0),
#                                   stringsAsFactors = FALSE))
#
#   remote <- rws_read_table("local", conn = conn)
#   local <- rbind(local, local)
#   expect_identical(remote, local)
# })
