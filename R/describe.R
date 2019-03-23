#' Add Descriptions to SQL Meta Data Table
#'
#' @param x An object specifying the table(s) to read.
#' @inheritParams rws_write
#' @return xx
#' @family rws_describe_sqlite_meta
#' @export
rws_describe_sqlite_meta <- function(x, ..., conn) {
  UseMethod("rws_describe_sqlite_meta")
}

#' Add Descriptions to SQL Meta Data Table
#'
#' @inheritParams rws_write
#' @param x A character vector of table name(s).
#' @param column A character vector of column name(s).
#' @param description A character vector of the description(s)
#' @inheritParams rws_write
#' 
#' @return An invisible character vector of the previous descriptions.
#' @family rws_read_sqlite
#' @export
rws_describe_sqlite_meta.character <- function(x, column, description, ..., conn) {
  check_vector(x, "")
  check_vector(column, "")
  check_vector(description, c("", NA))
  check_sqlite_connection(conn)
  check_unused(...)
  
  rws_describe_sqlite_meta(data.frame(
    Table = x, Column = column, Description = description, 
    stringsAsFactors = FALSE))
}


#' Add Data Frame of Descriptions to SQL Meta Data Table
#'
#' @inheritParams rws_write
#' @param x A data frame with columns Table, Column, Description.
#' 
#' @return An invisible character vector of the previous descriptions.
#' @family rws_read_sqlite
#' @export
rws_describe_sqlite_meta.data.frame <- function(x, ..., conn) {
  check_data(x, values = list(Table = "", Column = "", Description = c("", NA)))
  check_sqlite_connection(conn, connected = TRUE)
  check_unused(...)
  
  if(!nrow(x)) return(character(0))
  
  x <- x[c("Table", "Column", "Description")]
  if(anyDuplicated(x[c("Table", "Column")])) 
    err("columns 'Table' and 'Column' in data 'x' must be unique")

  x$RowX <- 1:nrow(x)
  
  meta <- rws_read_meta(conn)
  meta$RowMeta <- 1:nrow(meta)
  
  meta <- merge(meta, x, by.x = c("TableMeta", "ColumnMeta"), 
                by.y = c("Table", "Column"), all = TRUE)
  
  if(any(is.na(meta$MetaX))) 
    err("columns 'Table' and 'Column' in data 'x' must all match 'TableMeta' and 'ColumnMeta' in the meta table")
  
  meta <- meta[order(meta$RowX),]
  description <- meta$DescriptionMeta[!is.na(meta$RowMeta)]
  
  meta <- meta[order(meta$RowMeta),]
  
  meta <- meta[c("TableMeta", "ColumnMeta", "MetaMeta", "DescriptionMeta")]

  replace_meta_table(meta)
  invisible(description)
}
