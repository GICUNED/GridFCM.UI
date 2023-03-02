## WEIGTHED IMPGRID INDECES FUNCTIONS ##

# FCM density -------------------------------------------------------------


#' Fuzzy Cognitive Map density -- density_index()
#'
#' @description Function used to calculate the density of edges of the
#' calculated digraph of the impgrid
#'
#' @param wimp  Subject's Weigthed ImpGrid. It must be a "wimp" S3 object
#' imported by  the \code{\link{importwimp}} function.
#'
#'
#' @return Returns a value from 0 to 1 representing the ratio of the number of
#' edges in the graph over the maximum number of possible edges.
#'
#'
#' @export

density_index <- function(wimp){

  wmat<- wimp$scores[[3]]                                                       # Save Weigth Matrix

  n <- ncol(wmat)

  result <- sum(degree_index(wimp)[,1])/(n*(n-1))                               # divide the number of edges by the number of possible edges

  return(result)
}



# Degree Index Centrality -------------------------------------------------


#' Degree Index -- degree_index()
#'
#' @description Function to calculate the centrality of the constructs.
#' In this case, centrality is understood as the degree of connection that each
#' construct maintains with the rest, i.e. the number of links for each vertex.
#'
#' @param wimp  Subject's Weigthed ImpGrid. It must be a "wimp" S3 object
#' imported by  the \code{\link{importwimp}} function.
#'
#' @param method Method for calculating centrality. You can use the simple
#' method with "simple", normalized with "norm", weighted with "weigth",
#' normalized weighted with "wnorm" and the ego density method with "ego".
#' Default is Simple Method.
#'
#' @return Returns a list with the centrality data by construct and separated by
#'  input degree, output degree and total degree (in and out).
#'
#'
#' @export

degree_index <- function(wimp, method="simple"){


  lpoles <- wimp$constructs[[1]]
  rpoles <- wimp$constructs[[2]]
  poles <- wimp$constructs[[3]]


  wmat <- wimp$scores[[3]]
  N <- dim(wmat)[1]

  if(method == "simple" | method == "norm" | method == "ego"){                  # Simple method-----------------------------------------

    wmat.1 <- wmat/wmat
    wmat.1[is.nan(wmat.1)] <- 0                                                 # Convert all the weights in 1

    Cout <- rowSums(wmat.1)
    Cin <- colSums(wmat.1)                                                      # Sum by rows and columns to find the output and input values
  }

  if(method == "weight" | method == "wnorm"){                                   # Weight method----------------------------------------

    Cout <- rowSums(abs(wmat))
    Cin <- colSums(abs(wmat))                                                   # Sum by rows and columns to find the output and input values
  }

  if(method == "norm" | method == "wnorm"){                                     # Standardized method--------------------------------------

    Cout <- Cout/(N-1)
    Cin <- Cin/(N-1)                                                              # Divide output and input values by maximum possible degree
  }

  if(method == "ego"){                                                          # Ego density method-------------------------------------

    Cout <- Cout/(N*(N-1))
    Cin <- Cin/(N*(N-1))                                                        # Divide output and input values by maximum possible number of edges
  }

  names(Cout) <- poles
  names(Cin) <- poles

  result <- cbind(Cout, Cin , Cout + Cin)
  rownames(result) <- poles
  colnames(result) <- c("Out","In", "All")
  return(result)
}


# Distance Matrix ---------------------------------------------------------

#' Distance Matrix -- dismatrix()
#'
#' @description Function that calculates the shortest distance between each of
#' the pairs of digraph constructions.
#'
#' @param wimp  Subject's Weigthed ImpGrid. It must be a "wimp" S3 object
#' imported by the \code{\link{importwimp}} function.
#'
#' @param mode Method to calculate the distances depending on the direction of
#' the edges.With "out" we calculate them respecting the direction of the edges,
#' "in" through the inverse of the direction of the edges and "all" without
#' taking into account the direction.
#'
#' @return Returns the digraph distance matrix. Matrix that contains the
#' distances of the shortest paths from one construct to another.
#'
#' @export
#'

dismatrix <- function(wimp,mode="out"){

  poles <- wimp$constructs[[3]]
  wmat <- wimp$scores[[3]]


  G <- igraph::graph.adjacency(wmat,mode = "directed",weighted = T)              # Use the igraph package to calculate the distances

  result <- igraph::shortest.paths(G, weights = NA,mode = mode)

  rownames(result) <- poles
  colnames(result) <- poles

  return(result)
}


# Closeness Centrality Index ----------------------------------------------

#' Closeness index -- close_index()
#'
#' @description Function to calculate the closeness of a construct to the rest
#' of the constructs within the digraph.
#'
#' @param wimp  Subject's Weigthed ImpGrid. It must be a "wimp" S3 object
#' imported by the \code{\link{importwimp}} function.
#'
#' @param norm If TRUE, the values will be standardized. Default is TRUE.
#'
#' @return Returns a vector with the closeness index for each of the
#' constructs.
#'
#' @export
#'

close_index <- function(wimp, norm = TRUE){


  lpoles <- wimp$constructs[[1]]
  rpoles <- wimp$constructs[[2]]
  poles <- wimp$constructs[[3]]

  dist <- dismatrix(wimp)                                                        # Calculate dist matrix.
  N <- dim(dist)[1]

  result <- 1/(rowSums(dist))

  if(norm){
    result <- (N-1)/(rowSums(dist))                                             # Sum the distance of each construct with the rest and normalize.
  }

  result <- matrix(result)
  rownames(result) <- poles                                                     # Name vector's elements.
  colnames(result) <- "Closeness"

  return(result)
}

# Betweeness Centrality Index ---------------------------------------------

#' Betweeness index -- betw_index()
#'
#' @description Function that calculates the betweenness of each of the
#' constructs. This is the number of times a geodesic path (shortest path)
#' between two other constructs passes through that construct in the digraph.
#'
#' @param wimp  Subject's Weigthed ImpGrid. It must be a "wimp" S3 object
#' imported by the \code{\link{importwimp}} function.
#'
#' @param norm If TRUE, the values will be standardized. Default is TRUE.
#'
#' @return Returns a vector with the betweeness index for each of the
#' constructs.
#'
#' @export
#'

betw_index <- function(wimp,norm=TRUE){

  lpoles <- wimp$constructs[[1]]
  rpoles <- wimp$constructs[[2]]
  poles <- wimp$constructs[[3]]


  wmat <- wimp$scores[[3]]

  G <- igraph::graph.adjacency(wmat,mode = "directed",weighted = T)

  result <- igraph::betweenness(G,normalized = norm,weights = NA )              # Igraph function to betweeness index.

  result <- matrix(result)
  rownames(result) <- poles                                                     # Name vector's elements.
  colnames(result) <- "Betweenness"

  return(result)
}



# Ideal Inconsistencies Index ---------------------------------------------



#' Ideal Inconsitencies -- inc_index()
#'
#' @description WIP
#'
#' @param wimp  Subject's Weigthed ImpGrid. It must be a "wimp" S3 object
#' imported by the \code{\link{importwimp}} function.
#'
#' @return WIP.
#'
#'
#' @export
#'

inc_index <- function(wimp){


  ideal <- wimp$ideal[[2]]


  lpoles <- wimp$constructs[[1]]
  rpoles <- wimp$constructs[[2]]
  poles <- wimp$constructs[[3]]

  w.mat <- wimp$scores[[3]]


  n <- 1
  for (i in ideal) {                                                             # Orient the weight matrix according the ideal status.
    if(i != 0){                                                                  # This is for change the colour of the edges depending on vertex status.
      i.value <- i / abs(i)
      w.mat[,n] <- w.mat[,n] * i.value
      w.mat[n,] <- w.mat[n,] * i.value
    }
    n <- n + 1
  }

  w.mat <- w.mat/abs(w.mat)
  w.mat[is.nan(w.mat)] <- 0

  logical.dilemmatic <- ideal == 0

  w.mat[logical.dilemmatic,] <- 0
  w.mat[,logical.dilemmatic] <- 0

  in.inc <- colSums(w.mat == -1)
  out.inc <- rowSums(w.mat == -1)
  all.inc <- in.inc + out.inc

  result <- cbind(in.inc, out.inc, all.inc)
  rownames(result) <- poles
  colnames(result) <- c("IN","OUT","ALL")

  return(result)
}
