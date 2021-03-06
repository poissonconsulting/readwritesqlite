% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vld.R
\name{vld_sqlite_conn}
\alias{vld_sqlite_conn}
\title{Validate SQLite Connection}
\usage{
vld_sqlite_conn(x, connected = NA)
}
\arguments{
\item{x}{The object to check.}

\item{connected}{A logical scalar specifying whether x should be connected.}
}
\value{
A flag indicating whether the object was validated.
}
\description{
Validate SQLite Connection
}
\examples{
conn <- rws_connect()
vld_sqlite_conn(conn)
rws_disconnect(conn)
vld_sqlite_conn(conn, connected = TRUE)
}
