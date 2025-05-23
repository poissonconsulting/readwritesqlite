% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rename.R
\name{rws_rename_column}
\alias{rws_rename_column}
\title{Rename SQLite Column}
\usage{
rws_rename_column(table_name, column_name, new_column_name, conn)
}
\arguments{
\item{table_name}{A string of the name of the table.}

\item{column_name}{A string of the column name.}

\item{new_column_name}{A string of the new name for the column.}

\item{conn}{A \link[RSQLite:SQLiteConnection-class]{RSQLite::SQLiteConnection} to a database.}
}
\value{
TRUE
}
\description{
Rename SQLite Column
}
\examples{
conn <- rws_connect()
rws_write(data.frame(x = 1), x_name = "local", exists = FALSE, conn = conn)
rws_read_table("local", conn = conn)
rws_rename_column("local", "x", "Y", conn = conn)
rws_read_table("local", conn = conn)
rws_disconnect(conn)
}
\seealso{
Other rws_rename: 
\code{\link{rws_drop_table}()},
\code{\link{rws_rename_table}()}
}
\concept{rws_rename}
