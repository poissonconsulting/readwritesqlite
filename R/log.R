log_schema <- function () {
  p("CREATE TABLE", .log_table_name, "(
  DateTimeUTCLog TEXT NOT NULL,
  UserLog TEXT NOT NULL,
  TableLog TEXT NOT NULL,
  CommandLog TEXT NOT NULL,
  NRowLog INTEGER NOT NULL,
  CHECK (
    DATETIME(DateTimeUTCLog) IS DateTimeUTCLog AND
    CommandLog IN ('CREATE', 'UPDATE', 'DELETE', 'INSERT', 'DROP') AND
    NRowLog >= 0
));")
}

confirm_log_table <- function(conn) {
  log_schema <- log_schema()
  if (!tables_exists(.log_table_name, conn)) {
    execute(log_schema, conn)
  } else {
    log_schema <- sub(";$", "", log_schema)
    schema <- table_schema(.log_table_name, conn)
    if(!identical(schema, log_schema))
      err("table '", .log_table_name, "' has an invalid schema")
  }
}

log_command <- function(table_name, command, nrow, conn) {
  confirm_log_table(conn)
  data <- data.frame(DateTimeUTCLog = sys_date_time_utc(),
                     UserLog = user(),
                     TableLog = to_upper(table_name),
                     CommandLog = command,
                     NRowLog = nrow,
                     stringsAsFactors = FALSE)
  DBI::dbAppendTable(conn, .log_table_name, data)
}

#' Read Log Data Table from SQLite Database
#'
#' The table is created if it doesn't exist.
#'
#' @inheritParams rws_write
#' @return A data frame of the log table
#' @aliases rws_read_sqlite_log
#' @export
#' @examples
#' conn <- rws_connect()
#' rws_read_log(conn)
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' \dontrun{
#' rws_read_log(conn)
#' }
#' rws_disconnect(conn)
rws_read_log <- function(conn) {
  confirm_log_table(conn)
  data <- read_data(.log_table_name, meta = FALSE, conn = conn)
  data$DateTimeUTCLog <- as.POSIXct(data$DateTimeUTCLog, tz = "UTC")
  as_tibble_sf(data)
}
