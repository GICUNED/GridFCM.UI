## System Dynamics Functions ##

# Scenario Matrix -----------------------------------------------------------

#' Scenario Matrix -- scenariomatrix()
#'
#' @param wimp
#' @param act.vector
#' @param max.iter
#' @param e
#' @param stop.iter
#' @param force.convergence
#' @param quiet
#'
#' @return
#' @export
#'
#' @examples

scenariomatrix <- function(wimp, act.vector = NA, infer = "self dynamics",
                           thr = "saturation", max.iter = 10, e = 0.0001,
                           stop.iter = 3, exclude.dilemmatics = FALSE){


  if(!inherits(wimp,"wimp")){
    stop("The weighted implication grid must be class wimp.")
  }
  if( ncol(wimp[[6]][[3]]) != length(act.vector) && infer != "impact dynamics"){
    stop("The weight matrix and the activation vector must have compatible dimensions.")
  }

  wimp <- .align.wimp(wimp,exclude.dilemmatics = exclude.dilemmatics)
  dim <- length(wimp$constructs$constructs)
  scene.matrix <- t(matrix(wimp[[3]][[2]]))
  trans.matrix <- t(wimp$scores$weights)
  next.matrix <- trans.matrix

  n <- 1
  i <- 0

  while(n <= max.iter && i <= stop.iter){

    if(infer == "self dynamics"){
      message("entro en self dynamicssss.-...")
      next.iter <- scene.matrix[n,] + t(act.vector)

      next.iter <- mapply(.thr, next.iter, thr)

      delta.iter <- next.iter - scene.matrix[n,]
      scene.matrix <- rbind(scene.matrix, next.iter)

      act.vector <- trans.matrix %*% delta.iter
    }

    if(infer == "impact dynamics"){
      if(n == 1){scene.matrix <- t(rep(0,dim))}
      if(exclude.dilemmatics == FALSE){
        n.matrix <- next.matrix
        n.matrix[.which.dilemmatics(wimp),] <- 0
      }else{
        n.matrix <- next.matrix
      }
      sum.columns <- t(n.matrix) %*% rep(1,nrow(trans.matrix))
      next.iter <- t(sum.columns)
      scene.matrix <- rbind(scene.matrix, next.iter)
      next.matrix <- trans.matrix %*% next.matrix
    }

    e.iter <- mean(abs(next.iter - scene.matrix[n,]))

    if(e.iter < e){
      i <- i + 1
    }else{
      i <- 0
    }
    n <- n + 1
  }

  rownames(scene.matrix) <- paste("iter", 0:(n-1))
  colnames(scene.matrix) <- wimp[[2]][[3]]

  if(n < max.iter){
    convergence <- n - (stop.iter + 1)
  }else{
    convergence <- NA
  }

  scene.list <- list()

  scene.list$values <- scene.matrix
  scene.list$convergence <- convergence
  scene.list$constructs <- wimp$constructs
  scene.list$self[[1]] <- wimp$self[[2]]
  scene.list$self[[2]] <- wimp$ideal[[2]]
  scene.list$weights <- wimp[[6]][[3]]
  scene.list$method$infer <- infer
  scene.list$method$threeshold <- thr

  names(scene.list$self) <- c("self","ideal")

  class(scene.list) <- c("scn","list")

  return(scene.list)
}

#' Print method for scn class
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
#'

print.scn <- function(x){
  if(is.na(x$convergence)){
    cat("\n\nConvergencia no alcanzada\n\n")
  }else{
    cat("\n\nConvergencia alcanzada en la iteración número",x$convergence,"\n\n", sep = " ")
  }

  cat("ITERATIONS: \n\n")
  print(x$values)

}

# PCSD -----------------------------------------------------------------

#' Personal Constructs System Dynamics plot -- pcsd()
#'
#' @description Interactive line plot of personal constructs system dinamics.
#' Show \code{\link{scenariomatrix}} values expressed in terms of distance to
#' Ideal-Self for each personal construct across the mathematical iterations.
#'
#' @param scn
#'
#' @param vline
#'
#' @return Interactive plot created with plotly.
#'
#' @import plotly
#'
#' @export
#'
#' @examples

pcsd <- function(scn, vline = NA){



  lpoles <- scn$constructs[[1]]
  rpoles <- scn$constructs[[2]]
  poles <- scn$constructs[[3]]
  dim <- length(poles)
  infer <- scn$method$infer
  iter <- nrow(scn$values)


  self.vector <- scn$self[[1]]
  self.matrix <- matrix(self.vector, ncol = length(self.vector),
                        nrow = iter, byrow = TRUE)

  res <- scn$values


  x <- c(0:(iter -1))
  y <- c(0:length(poles))
  y <- as.character(y)

  if(infer == "self dynamics"){
    df <- data.frame(x, (res - self.matrix))
  }
  if(infer == "impact dynamics"){
    df <- data.frame(x, (res/dim))
  }

  max.value.df <- max(abs(df[,-1])) + 0.05 * max(abs(df[,-1]))

  colnames(df) <- y

  fig <- plotly::plot_ly(df, x = ~x, y = df[,2], name = poles[1],
                         type = 'scatter',
                         mode = 'lines+markers',line = list(shape = "spline"))  # Build PCSD with plotly.

  for (n in 3:(length(poles)+1)) {
    fig <- fig %>% plotly::add_trace(y = df[,n], name = poles[n-1],
                                     mode = 'lines+markers',
                                     line = list(shape = "spline"))
  }
  fig <- fig %>% plotly::layout(
    xaxis = list(
      title = "ITERATIONS"
    ),
    yaxis = list(
      title = .label.y(infer),
      range = c(-max.value.df,max.value.df)
    )
  )
  fig <- fig %>% plotly::layout(legend=list(
    title=list(text='<b>PERSONAL CONSTRUCTS</b>')
  )
  )

  fig <- fig %>% add_lines(
    x = vline,
    y = c(0,1),
    line = list(
      color = "grey",
      dash = "dot"
    ),
    inherit = FALSE,
    showlegend = FALSE
  )

  fig                                                                           # Run the results.
}

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


  iter <- nrow(scn$values)                                                      # Save convergence value.

  ideal.vector <- scn$self[[2]]
  ideal.matrix <- matrix(ideal.vector, ncol = length(ideal.vector),             # Create a matrix with Ideal-Self values repeated by rows.
                         nrow = iter, byrow = TRUE)

  res <- scn$values
  res <- abs(res - ideal.matrix) / 2

  matrix <- matrix(ncol= length(poles), nrow = 1)

  for (n in 1:length(poles)) {                                                  # Calculate AUC for each construct curve.
    matrix[,n] <- MESS::auc(c(0:(iter - 1)), res[,n], type = "spline")/(iter + 4)
  }

  result <- t(matrix)

  rownames(result) <- poles                                                     # Name vector's elements.
  colnames(result) <- "AUC"


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


  iter <- nrow(scn$values)                                                        # Save convergence value.

  ideal.vector <- scn$self[[2]]
  ideal.matrix <- matrix(ideal.vector, ncol = length(ideal.vector),             # Create a matrix with Ideal-Self values repeated by rows.
                         nrow = iter, byrow = TRUE)

  res <- scn$values
  res <- abs(res - ideal.matrix) / 2


  result <- apply(res, 2, sd)                                                   # Calculate SD for each construct.

  result <- matrix(result)
  rownames(result) <- poles                                                     # Name vector's elements.
  colnames(result) <- "Standard Deviation"

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


  iter <- nrow(scn$values)                                                      # Save convergence value.

  ideal.vector <- scn$self[[2]]
  ideal.matrix <- matrix(ideal.vector, ncol = length(ideal.vector),             # Create a matrix with Ideal-Self values repeated by rows.
                         nrow = iter, byrow = TRUE)

  res <- scn$values
  res <- abs(res - ideal.matrix) / 2



  result <- res[c(1,iter),]                                                     # Extract the first vector and the last vector from the iteration matrix.
  result <- t(result)
  result <- cbind(result, result[,2] - result[,1])                              # Calculate the difference between the first vector and the last one and add it to the results.

  rownames(result) <- poles
  colnames(result) <- c("Initial value", "Final value", "Difference")

  return(result)
}
