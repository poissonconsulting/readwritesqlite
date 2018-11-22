log_schema <- function () {
  "CREATE TABLE dbWriteSQLiteLog (
  DateTimeUTCLog TEXT NOT NULL,
  UserLog TEXT NOT NULL,
  TableLog TEXT NOT NULL,
  CommandLog TEXT NOT NULL,
  NRowLog INTEGER NOT NULL,
  CHECK (
    DATETIME(DateTimeUTCLog) IS DateTimeUTCLog AND
    CommandLog IN ('UPDATE', 'DELETE', 'INSERT') AND
    NRowLog >= 1
  ),
  PRIMARY KEY (DateTimeUTCLog, UserLog)
);"
}

check_log_table <- function(conn) {
  if (!dbExistsTable(conn, "dbWriteSQLiteLog")) {
    dbExecute(conn, log_schema())
  } else {
    stop()
    # check schema
  }
}

log_data <- function(conn, name, command, nrow) {
  check_log_table(conn)
  data <- data.frame(DateTimeUTCLog = sys_date_time_utc(),
                     UserLog = user(),
                     TableLog = name,
                     CommandLog = command,
                     NRowLog = nrow,
                     stringsAsFactors = FALSE)
  dbWriteTable(conn, "dbWriteSQLiteLog", data, row.names = FALSE, append = TRUE)
}
