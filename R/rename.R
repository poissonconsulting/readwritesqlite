#' Rename SQLite Column
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
#' rws_write(list(somedata = rws_data), exists = FALSE, conn = conn)
#' rws_list_tables(conn)
#' rws_rename_table("somedata", "tableb", conn)
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
