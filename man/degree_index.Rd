% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/WimpIndicesFunctions.R
\name{degree_index}
\alias{degree_index}
\title{Degree Index -- degree_index()}
\usage{
degree_index(wimp, method = "simple")
}
\arguments{
\item{wimp}{Subject's Weigthed ImpGrid. It must be a "wimp" S3 object
imported by  the \code{\link{importwimp}} function.}

\item{method}{Method for calculating centrality. You can use the simple
method with "simple", normalized with "norm", weighted with "weigth",
normalized weighted with "wnorm" and the ego density method with "ego".
Default is Simple Method.}
}
\value{
Returns a list with the centrality data by construct and separated by
 input degree, output degree and total degree (in and out).
}
\description{
Function to calculate the centrality of the constructs.
In this case, centrality is understood as the degree of connection that each
construct maintains with the rest, i.e. the number of links for each vertex.
}
