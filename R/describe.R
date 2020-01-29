#' Add Descriptions to SQL Meta Data Table
#'
#' @param x An object specifying the descriptions.
#' @inheritParams rws_write
#' @return An invisible copy of the updated meta table.
#' @family rws_describe_meta
#' @export
rws_describe_meta <- function(x, ..., conn) {
  UseMethod("rws_describe_meta")
}

#' Add Descriptions to SQL Meta Data Table
#'
#' @inheritParams rws_write
#' @param x A character vector of table name(s).
#' @param column A character vector of column name(s).
#' @param description A character vector of the description(s)
#' @inheritParams rws_write
#'
#' @return An invisible copy of the updated meta table.
#' @family rws_describe_meta
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_read_meta(conn)
#' rws_describe_meta("rws_data", "Units", "The site length.", conn = conn)
#' rws_describe_meta("rws_data", "POSIXct", "Time of the visit", conn = conn)
#' rws_read_meta(conn)
#' rws_disconnect(conn)
rws_describe_meta.character <- function(x, column, description, ..., conn) {
  chk_s3_class(x, "character")
  chk_not_any_na(x)
  chk_s3_class(column, "character")
  chk_not_any_na(column)
  chk_s3_class(description, "character")
  chk_sqlite_conn(conn, connected = TRUE)
  chk_unused(...)

  rws_describe_meta(data.frame(
    Table = x, Column = column, Description = description,
    stringsAsFactors = FALSE
  ), conn = conn)
}

#' Add Data Frame of Descriptions to SQL Meta Data Table
#'
#' @inheritParams rws_write
#' @param x A data frame with columns Table, Column, Description.
#' @return An invisible character vector of the previous descriptions.
#' @family rws_read
#' @export
rws_describe_meta.data.frame <- function(x, ..., conn) {
  chk_s3_class(x, "data.frame")
  chk_superset(colnames(x), c("Table", "Column", "Description"))
  chk_s3_class(x$Table, "character")
  chk_not_any_na(x$Table)
  chk_s3_class(x$Column, "character")
  chk_not_any_na(x$Column)
  chk_s3_class(x$Description, "character")
  chk_sqlite_conn(conn, connected = TRUE)
  chk_unused(...)

  if (!nrow(x)) {
    return(invisible(rws_read_meta(conn)))
  }

  x <- x[c("Table", "Column", "Description")]
  x$Table <- to_upper(x$Table)
  x$Column <- to_upper(x$Column)

  if (anyDuplicated(x[c("Table", "Column")])) {
    err("Columns 'Table' and 'Column' in data 'x' must be unique.")
  }

  x$Row <- 1:nrow(x)

  meta <- rws_read_meta(conn)
  meta$RowMeta <- 1:nrow(meta)

  meta <- merge(meta, x,
    by.x = c("TableMeta", "ColumnMeta"),
    by.y = c("Table", "Column"), all = TRUE
  )

  if (any(is.na(meta$RowMeta))) {
    err("All description tables and columns must exist in the meta table.")
  }

  meta$DescriptionMeta[!is.na(meta$Row)] <- meta$Description[!is.na(meta$Row)]
  meta <- meta[order(meta$RowMeta), ]

  meta <- meta[c("TableMeta", "ColumnMeta", "MetaMeta", "DescriptionMeta")]

  replace_meta_table(meta, conn = conn)
  invisible(as_tibble_sf(meta))
}
