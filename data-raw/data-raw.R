rws_data <- tibble::tibble(logical = c(TRUE, FALSE, NA), 
                   date = as.Date(c("2000-01-01", "2001-02-03", NA)),
                   factor = factor(c("x", "y", NA)),
                   ordered = ordered(c("x", "y", NA), levels = c("y", "x", NA)),
                   posixct = as.POSIXct(c("2001-01-02 03:04:05", "2006-07-08 09:10:11", NA), tz = "Etc/GMT+8"),
                   units = units::as_units(c(10, 11.5, NA), "m"),
                   geometry = sf::st_sfc(sf::st_point(c(0,1)), 
                                         sf::st_point(c(1,0)), 
                                         sf::st_point(c(1,1)), crs = 4326))
rws_data <- sf::st_sf(rws_data)

usethis::use_data(rws_data, overwrite = TRUE)
