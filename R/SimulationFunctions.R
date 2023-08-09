## Simulation Functions ##

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

scenariomatrix <- function(wimp, act.vector, infer = "linear transform",
                           thr = "linear", max.iter = 30, e = 0.0001,
                           stop.iter = 3){


  if(!inherits(wimp,"wimp")){
    stop("The weighted implication grid must be class wimp.")
  }
  if( ncol(wimp[[6]][[3]]) != length(act.vector)){
    stop("The weight matrix and the activation vector must have compatible dimensions.")
  }

  scene.matrix <- t(matrix(wimp[[3]][[2]]))

  n <- 1
  i <- 0

  while(n <= max.iter && i <= stop.iter){

    if(infer == "linear transform"){
      next.iter <- scene.matrix[n,] + t(act.vector)

      if(thr == "linear"){next.iter <- sapply(next.iter, .lineal.thr)}

      delta.iter <- next.iter - scene.matrix[n,]
      scene.matrix <- rbind(scene.matrix, next.iter)

      act.vector <- t(wimp[[6]][[3]]) %*% delta.iter
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
