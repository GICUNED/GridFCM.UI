## IMPORT FUNCTIONS ##

# Import Weigthed ImpGrid -------------------------------------------------

#' Import Weighted ImpGrid
#'
#' @param path
#' @param sheet
#'
#' @return
#' @export
#'
#' @import readxl
#'
#' @examples


importwimp <- function(path, sheet = 1){

  wimp <- list()
  class(wimp) <- c("wimp","list")

  xlsx <- read_excel(path, sheet = sheet)

  n.constructs <- dim(xlsx)[1]

  # Scale -------------------------------------------------------------------


  scale.min <- as.numeric(names(xlsx)[1])
  scale.max <- as.numeric(names(xlsx)[n.constructs + 3])
  scale.center <- (scale.min + scale.max)/2

  scale <- c(scale.min,scale.max)
  names(scale) <- c("min","max")

  wimp$scale <- scale


  # Constructs --------------------------------------------------------------

  left.poles <- as.vector(xlsx[,1])[[1]]
  right.poles <- as.vector(xlsx[,n.constructs + 3])[[1]]

  constructs <- paste(left.poles,"—",right.poles,sep = "")

  wimp$constructs[[1]] <- left.poles
  wimp$constructs[[2]] <- right.poles
  wimp$constructs[[3]] <- constructs

  names(wimp[["constructs"]]) <- c("left.poles","right.poles","constructs")


  # Self vector -------------------------------------------------------------

  direct.scores <- as.matrix(xlsx[,1:n.constructs+1])

  direct.self <- diag(direct.scores)

  standarized.self <- (direct.self - (scale.center * rep(1,n.constructs))) / (0.5 * (scale.max - scale.min))

  wimp$self[[1]] <- direct.self
  wimp$self[[2]] <- standarized.self
  names(wimp$self) <- c("direct","standarized")


  # Ideal vector ------------------------------------------------------------

  direct.ideal <- as.vector(xlsx[,n.constructs + 2])[[1]]
  standarized.ideal <- (direct.ideal - (scale.center * rep(1,n.constructs))) / (0.5 * (scale.max - scale.min))

  wimp$ideal[[1]] <- direct.ideal
  wimp$ideal[[2]] <- standarized.ideal
  names(wimp$ideal) <- c("direct","standarized")


  # Hypothetical vector -----------------------------------------------------

  standarized.hypothetical <- rep(0,n.constructs)

  n <- 1
  for (i in standarized.self) {

    if(i != 0){
      standarized.hypothetical[n] <- standarized.self[n] / (-1 * abs(standarized.self[n]))
    }
    if(i == 0 && standarized.ideal != 0 ){
      standarized.hypothetical[n] <- standarized.ideal[n] / abs(standarized.ideal[n])
    }
    if(i == 0 && standarized.ideal == 0){
      standarized.hypothetical[n] <- 1
    }
    n <- n + 1
  }

  direct.hypothetical <- (scale.center * rep(1,n.constructs)) + (standarized.hypothetical * (0.5 * (scale.max - scale.min)))

  wimp$hypothetical[[1]] <- direct.hypothetical
  wimp$hypothetical[[2]] <- standarized.hypothetical
  names(wimp$hypothetical) <- c("direct","standarized")


  # Scores ------------------------------------------------------------------

  imp.matrix <- t((direct.scores - (scale.center * matrix(rep(1,n.constructs * n.constructs),ncol = n.constructs))) / (0.5 * (scale.max - scale.min)))

  num.weight.matrix <- imp.matrix - matrix(standarized.self,nrow = n.constructs,ncol = n.constructs,byrow = TRUE)
  den.weigth.matrix <- matrix(standarized.hypothetical,nrow = n.constructs,ncol = n.constructs) - matrix(standarized.self,nrow = n.constructs,ncol = n.constructs)
  weight.matrix <- num.weight.matrix / den.weigth.matrix

  wimp$scores[[1]] <- direct.scores
  wimp$scores[[2]] <- imp.matrix
  wimp$scores[[3]] <- weight.matrix
  names(wimp$scores) <- c("direct","implications","weights")

  # OpenRepGrid adaptation --------------------------------------------------

  openrepgrid.object <- importExcel(path, sheetIndex = sheet)
  wimp$openrepgrid <- openrepgrid.object

  # Function return ---------------------------------------------------------


  return(wimp)
}

#' Print method for wimp class
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
#'

print.wimp <- function(x){
  print(x$openrepgrid)
  bertin(x$openrepgrid)
}
