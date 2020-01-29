#' Rename SQLite Table
#'
#' @inheritParams rws_write
#' @param table_name A string of the name of the table.
#' @param new_table_name A string of the new name for the table.
#' @family rws_rename
#' @export
#' @return TRUE
#'
#' @examples
#' conn <- rws_connect()
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_list_tables(conn)
#' rws_rename_table("rws_data", "tableb", conn)
#' rws_list_tables(conn)
#' rws_disconnect(conn)
rws_rename_table <- function(table_name, new_table_name, conn) {
  chk_sqlite_conn(conn, connected = TRUE)
  check_table_name(table_name, exists = TRUE, conn = conn)
  check_table_name(new_table_name, exists = FALSE, conn = conn)

  meta <- rws_read_meta(conn)
  init <- rws_read_init(conn)

  rename_table(table_name, new_table_name, conn = conn)
  table_name <- to_upper(table_name)
  new_table_name <- to_upper(new_table_name)

  meta$TableMeta <- sub(p0("^", table_name, "$"), new_table_name, meta$TableMeta)
  init$TableInit <- sub(p0("^", table_name, "$"), new_table_name, init$TableInit)

  replace_meta_table(meta, conn = conn)
  replace_init_table(init, conn = conn)
  TRUE
}

#' Rename SQLite Column
#'
#' @inheritParams rws_write
#' @inheritParams rws_rename_table
#' @param column_name A string of the column name.
#' @param new_column_name A string of the new name for the column.
#' @family rws_rename
#' @export
#' @return TRUE
#'
#' @examples
#' conn <- rws_connect()
#' rws_write(data.frame(x = 1), x_name = "local", exists = FALSE, conn = conn)
#' rws_read_table("local", conn = conn)
#' rws_rename_column("local", "x", "Y", conn = conn)
#' rws_read_table("local", conn = conn)
#' rws_disconnect(conn)
rws_rename_column <- function(table_name, column_name, new_column_name, conn) {
  chk_sqlite_conn(conn, connected = TRUE)
  check_table_name(table_name, exists = TRUE, conn = conn)

  check_column_name(table_name, column_name, exists = TRUE, conn)
  chk_string(new_column_name)
  if (to_upper(column_name) != to_upper(new_column_name)) {
    check_column_name(table_name, new_column_name, exists = FALSE, conn)
  }

  meta <- rws_read_meta(conn)

  rename_column(table_name, column_name, new_column_name, conn = conn)

  table_name <- to_upper(table_name)
  column_name <- to_upper(column_name)
  new_column_name <- to_upper(new_column_name)

  meta$ColumnMeta[meta$TableMeta == table_name] <-
    sub(p0("^", column_name, "$"), new_column_name, meta$ColumnMeta[meta$TableMeta == table_name])

  replace_meta_table(meta, conn = conn)
  TRUE
}
