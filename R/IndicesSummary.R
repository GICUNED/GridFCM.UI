## INDICES SUMMARY FUNCTIONS ##

# Wimp Indices ------------------------------------------------------------

#' Title
#'
#' @param wimp
#'
#' @return
#' @export
#'
#' @examples
#'

wimpindices <- function(wimp){

  list <- list()

  list$density <- density_index(wimp)

  list$distance <- dismatrix(wimp)

  list$centrality[[1]] <- degree_index(wimp)
  list$centrality[[2]] <- close_index(wimp)
  list$centrality[[3]] <- betw_index(wimp)
  names(list$centrality) <- c("degree", "closeness", "betweenness")

  list$inconsistences <- inc_index(wimp)

  return(list)
}

# PCSD Indices ------------------------------------------------------------

#' Title
#'
#' @param scn
#'
#' @return
#' @export
#'
#' @examples
#'

pcsdindices <- function(scn){

  list <- list()

  list$convergence <- scn$convergence

  list$summary <- pcsd_summary(scn)

  list$auc <- auc_index(scn)

  list$stability <- stability_index(scn)

  return(list)
}

# Repgrid Indices ---------------------------------------------------------

#' Title
#'
#' @param grid
#'
#' @return
#' @export
#' @import OpenRepGrid
#' @examples
#'

gridindices <- function(grid){

  list <- list()

  list$pvaff <- indexPvaff(grid)

  list$intensity <- indexIntensity(grid)
  names(list$intensity) <- c("Constructs","Elements","Global Constructs","Global Elements","Total")

  list$conflict <- indexConflict1(grid)[[3]]

  list$bias <- indexBias(grid)

  list$dilemmas[[1]] <- indexDilemma(grid)[[1]]
  list$dilemmas[[2]] <- indexDilemma(grid)[[4]]
  names(list$dilemmas) <- c("Congruency","Dilemmas")

  list$distances[[1]] <- distance(grid, along = 1)
  list$distances[[2]] <- distance(grid, along = 2)
  names(list$distances) <- c("Constructs","Elements")

  return(list)
}
