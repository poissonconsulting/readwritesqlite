log_schema <- function () {
  p("CREATE TABLE", .log_table_name, "(
  DateTimeUTCLog TEXT NOT NULL,
  UserLog TEXT NOT NULL,
  TableLog TEXT NOT NULL,
  CommandLog TEXT NOT NULL,
  NRowLog INTEGER NOT NULL,
  CHECK (
    DATETIME(DateTimeUTCLog) IS DateTimeUTCLog AND
    CommandLog IN ('CREATE', 'UPDATE', 'DELETE', 'INSERT') AND
    NRowLog >= 0
  ));")
}

check_log_table <- function(conn) {
  log_schema <- log_schema()
  if (!tables_exists(.log_table_name, conn)) {
    dbExecute(conn, log_schema)
  } else {
    log_schema <- sub(";$", "", log_schema)
    schema <- table_schema(.log_table_name, conn)
    if(!identical(schema, log_schema))
      err("table '", .log_table_name, "' has an invalid schema")
  }
}

log_command <- function(conn, name, command, nrow) {
  check_log_table(conn)
  name <- to_upper(as.sqlite_name(name))
  data <- data.frame(DateTimeUTCLog = sys_date_time_utc(),
                     UserLog = user(),
                     TableLog = name,
                     CommandLog = command,
                     NRowLog = nrow,
                     stringsAsFactors = FALSE)
  dbWriteTable(conn, .log_table_name, data, row.names = FALSE, 
               append = TRUE)
}

#' Read Log Data Table from SQLite Database
#'
#' The table is created if it doesn't exist.
#'
#' @inheritParams rws_write_sqlite
#' @return A data frame of the log table
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' rws_read_sqlite_meta(con)
#' DBI::dbDisconnect(con)
rws_read_sqlite_log <- function(conn = getOption("rws.conn", NULL)) {
  check_log_table(conn)
  data <- dbReadTable(conn, .log_table_name)
  data$DateTimeUTCLog <- as.POSIXct(data$DateTimeUTCLog, tz = "UTC")
  as_conditional_tibble(data)
}
