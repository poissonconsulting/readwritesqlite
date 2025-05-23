% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rename.R
\name{rws_rename_table}
\alias{rws_rename_table}
\title{Rename SQLite Table}
\usage{
rws_rename_table(table_name, new_table_name, conn)
}
\arguments{
\item{table_name}{A string of the name of the table.}

\item{new_table_name}{A string of the new name for the table.}

\item{conn}{A \link[RSQLite:SQLiteConnection-class]{RSQLite::SQLiteConnection} to a database.}
}
\value{
TRUE
}
\description{
Rename SQLite Table
}
\examples{
conn <- rws_connect()
rws_write(rws_data, exists = FALSE, conn = conn)
rws_list_tables(conn)
rws_rename_table("rws_data", "tableb", conn)
rws_list_tables(conn)
rws_disconnect(conn)
}
\seealso{
Other rws_rename: 
\code{\link{rws_drop_table}()},
\code{\link{rws_rename_column}()}
}
\concept{rws_rename}
