#' Drop SQLite Table
#'
#' Drops SQLite table using DROP TABLE.
#'
#' Also drops rows from meta and init tables.
#'
#' @inheritParams rws_write
#' @param table_name A string of the name of the table.
#' @references <https://www.sqlite.org/lang_droptable.html>
#' @family rws_rename
#' @export
#' @return TRUE
#'
#' @examples
#' conn <- rws_connect()
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_list_tables(conn)
#' rws_drop_table("rws_data", conn = conn)
#' rws_list_tables(conn)
#' rws_disconnect(conn)
rws_drop_table <- function(table_name, conn) {
  chk_sqlite_conn(conn, connected = TRUE)
  check_table_name(table_name, exists = TRUE, conn = conn)

  meta <- rws_read_meta(conn)
  init <- rws_read_init(conn)

  drop_table(table_name, conn = conn)
  table_name <- to_upper(table_name)

  meta <- meta[meta$TableMeta != table_name, , drop = FALSE]
  init <- init[init$TableInit != table_name, , drop = FALSE]

  replace_meta_table(meta, conn = conn)
  replace_init_table(init, conn = conn)
  TRUE
}
