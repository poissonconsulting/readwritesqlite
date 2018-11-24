log_schema <- function () {
  "CREATE TABLE readwritesqlite_log (
  DateTimeUTCLog TEXT NOT NULL,
  UserLog TEXT NOT NULL,
  TableLog TEXT NOT NULL,
  CommandLog TEXT NOT NULL,
  NRowLog INTEGER NOT NULL,
  CHECK (
    DATETIME(DateTimeUTCLog) IS DateTimeUTCLog AND
    CommandLog IN ('UPDATE', 'DELETE', 'INSERT') AND
    NRowLog >= 1
  )
);"
}

check_log_table <- function(conn) {
  log_schema <- log_schema()
  if (!dbExistsTable(conn, "readwritesqlite_log")) {
    dbExecute(conn, log_schema)
  } else {
    log_schema <- sub(";$", "", log_schema)
    schema <- table_schema("readwritesqlite_log", conn)
    if(!identical(schema, log_schema))
      err("table 'readwritesqlite_log' has an invalid schema")
  }
}

log_command <- function(conn, name, command, nrow) {
  check_log_table(conn)
  data <- data.frame(DateTimeUTCLog = sys_date_time_utc(),
                     UserLog = user(),
                     TableLog = name,
                     CommandLog = command,
                     NRowLog = nrow,
                     stringsAsFactors = FALSE)
  dbWriteTable(conn, "readwritesqlite_log", data, row.names = FALSE, 
               append = TRUE)
}

#' Read dbWriteSQLiteLog Table
#'
#' The table is created if it doesn't exist.
#'
#' @inheritParams write_sqlite
#' @return A data frame of the dbWriteSQLiteLog table
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' read_sqlite_log(con)
#' DBI::dbDisconnect(con)
read_sqlite_log <- function(conn = getOption("readwritesqlite.conn", NULL)) {
  check_log_table(conn)
  data <- dbReadTable(conn, "readwritesqlite_log")
  data$DateTimeUTCLog <- as.POSIXct(data$DateTimeUTCLog, tz = "UTC")
  as_conditional_tibble(data)
}
