## PCSD INDECES FUNTIONS ##


# AUC Index ---------------------------------------------------------------

#' PCSD AUC Index -- auc_index()
#'
#' @description This function calculates the area under the PCSD curve for each
#' construct.
#'
#' @param scn
#'
#' @report Returns a vector with the AUC index of each construct.
#'
#' @import MESS
#'
#' @export

auc_index <- function(scn){

  lpoles <- scn$constructs[[1]]
  rpoles <- scn$constructs[[2]]
  poles <- scn$constructs[[3]]


  iter <- scn$convergence                                                       # Save convergence value.

  ideal.vector <- scn$self[[2]]
  ideal.matrix <- matrix(ideal.vector, ncol = length(ideal.vector),             # Create a matrix with Ideal-Self values repeated by rows.
                         nrow = iter + 4, byrow = TRUE)

  res <- scn$values
  res <- abs(res - ideal.matrix) / 2

  matrix <- matrix(ncol= length(poles), nrow = 1)

  for (n in 1:length(poles)) {                                                  # Calculate AUC for each construct curve.
    matrix[,n] <- MESS::auc(c(0:(iter + 3)), res[,n], type = "spline")/(iter + 4)
  }

  result <- as.vector(matrix)

  names(result) <- poles                                                        # Name de vector's elements.


  return(result)
}

# PCSD Stability Index ----------------------------------------------------

#' PCSD Stability Index -- stability_index()
#'
#' @description This function returns the standard deviation for each
#' construct over the mathematical iterations of the PCSD.
#'
#' @param scn
#'
#' @return Returns a vector with the standard deviation of each of the
#' constructs.
#'
#' @importFrom stats sd
#' @importFrom stats rnorm
#'
#' @export

stability_index <- function(scn){


  lpoles <- scn$constructs[[1]]
  rpoles <- scn$constructs[[2]]
  poles <- scn$constructs[[3]]


  iter <- scn$convergence                                                       # Save convergence value.

  ideal.vector <- scn$self[[2]]
  ideal.matrix <- matrix(ideal.vector, ncol = length(ideal.vector),             # Create a matrix with Ideal-Self values repeated by rows.
                         nrow = iter + 4, byrow = TRUE)

  res <- scn$values
  res <- abs(res - ideal.matrix) / 2


  result <- apply(res, 2, sd)                                                   # Calculate SD for each construct.

  names(result) <- poles                                                        # Name de vector's elements.

  return(result)
}


# PCSD Summary ------------------------------------------------------------

#' PCSD summary -- pcsd_summary()
#'
#' @description This function returns a summary of the PCSD. It informs us the
#' initial and final value of each construct and the difference between them.
#'
#' @param scn
#'
#' @return Returns a matrix with the PCSD summary.
#'
#'
#' @export

pcsd_summary <- function(scn){


  lpoles <- scn$constructs[[1]]
  rpoles <- scn$constructs[[2]]
  poles <- scn$constructs[[3]]


  iter <- scn$convergence                                                       # Save convergence value.

  ideal.vector <- scn$self[[2]]
  ideal.matrix <- matrix(ideal.vector, ncol = length(ideal.vector),             # Create a matrix with Ideal-Self values repeated by rows.
                         nrow = iter + 4, byrow = TRUE)

  res <- scn$values
  res <- abs(res - ideal.matrix) / 2



  result <- res[c(1,iter),]                                                     # Extract the first vector and the last vector from the iteration matrix.
  result <- t(result)
  result <- cbind(result, result[,2] - result[,1])                              # Calculate the difference between the first vector and the last one and add it to the results.

  rownames(result) <- poles
  colnames(result) <- c("Initial value", "Final value", "Difference")

  return(result)
}

