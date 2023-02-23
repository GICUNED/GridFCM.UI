### HIDE FUNCTIONS ###

# Lineal Threshold Function -----------------------------------------------


.lineal.thr <- function(x){

  if(x <= -1){ result <- -1}
  if(-1 < x && x < 1){ result <- x}
  if(x >= 1){ result <- 1}

  return(result)
}


# color function ----------------------------------------------------------

.color.selection <- function(x){                                                # Order: c(discrepant, congruent, undefined , dilemmatic)

  if(x == "red/green"){
    res <- c("#F52722","#A5D610","grey","yellow")
  }

  if(x == "grey scale"){
    res <- c("#808080","#ffffff","#f2f2f2","#e5e5e5")
  }

  return(res)

}
