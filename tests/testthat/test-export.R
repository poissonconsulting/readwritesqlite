test_that("rws_export_gpkg works", {
  conn <- local_conn()
  
  sf_data <- readwritesqlite:::rws_data_sf
  sf_data$geometry2 <- sf_data$geometry
  sf_data <- activate_sfc(sf_data, "geometry")
  
  rws_write(list(data1 = sf_data), exists = FALSE, conn = conn)
  
  sf_data_deact <- as.data.frame(sf_data)
  
  rws_write(list(data2 = sf_data_deact), exists = FALSE, conn = conn)

  dir <- tempdir()
  rws_export_gpkg(conn = conn, dir = dir, overwrite = FALSE)
  
  files <- list.files(dir, full.names = TRUE)
  
  expect_true(all(c("data1_geometry2.gpkg", "data1.gpkg", "data2_geometry.gpkg", "data2_geometry2.gpkg") 
                  %in% basename(files)))
  
  expect_error(rws_export_gpkg(conn = conn, dir = dir), 
               "File data1.gpkg already exisits. Set 'overwrite' = TRUE to overwrite.")
  
  table_expected_changes <- sf_data_deact[,!names(sf_data_deact) == "geometry2"]
  names(table_expected_changes)[names(table_expected_changes) == "geometry"] <- "geom"
  table_exported <- sf::st_read(file.path(dir, "data1_geometry2.gpkg"), quiet = TRUE) 
  unlink(dir, recursive = TRUE)
  
  expect_identical(names(table_exported), names(table_expected_changes))
  
  expect_identical(class(table_exported$logical), "logical")
  expect_identical(class(table_exported$date), "Date")
  expect_identical(class(table_exported$posixct), c("POSIXct", "POSIXt"))
  expect_identical(class(table_exported$geom), c("sfc_POINT", "sfc"))
  
})


