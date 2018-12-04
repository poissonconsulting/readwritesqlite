has_units <- function(x) {
  is.logical(x) || dttr::is.Date(x) || dttr::is.POSIXct(x) 
  #|| poisspatial::is.sfc(x)|| has_measurement_units(x)
}

