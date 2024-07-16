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

scenariomatrix <- function(wimp, act.vector = NA, infer = "self dynamics",
                           thr = "saturation", max.iter = 10, e = 0.0001,
                           stop.iter = 3, exclude.dilemmatics = FALSE){
  
  if(!inherits(wimp,"wimp")){
    stop("The weighted implication grid must be class wimp.")
  }
  if( ncol(wimp[[6]][[3]]) != length(act.vector) && infer != "impact dynamics"){
    stop("The weight matrix and the activation vector must have compatible dimensions.")
  }

  ideal <- wimp$ideal$standarized
  swap.vector <- ideal/abs(ideal)
  swap.vector[is.nan(swap.vector)] <- 1

  if(infer == "self dynamics"){
  act.vector <- act.vector * swap.vector
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
