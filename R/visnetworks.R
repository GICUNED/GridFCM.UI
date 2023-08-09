#' Sustituto para Selfdigraph
#'
#' @param wimp
#' @param vertex.vector
#' @param ideal.vector
#' @param width
#' @param height
#' @param color
#' @param layout
#' @param show
#' @param hide.inverse
#'
#' @return
#' @import dplyr
#' @import visNetwork
#' @export
#'
#' @examples
#'

digraph <- function(wimp, vertex.vector = NA, ideal.vector = NA, width="100%",
                    height="1000px", color = "red/green", layout ="graphopt",
                    show = TRUE, hide.inverse = FALSE){

  if(inherits(wimp,"wimp")){
    lpoles <- wimp$constructs[[1]]
    rpoles <- wimp$constructs[[2]]
    poles <- paste(lpoles, "-", rpoles)
    wmatrix <- wimp[["scores"]][["weights"]]
    self <- wimp$self[[2]]
    ideal <- wimp$ideal[[2]]}

  if(inherits(wimp,"scn")){
    lpoles <- wimp$constructs[[1]]
    rpoles <- wimp$constructs[[2]]
    poles <- paste(lpoles, "-", rpoles)
    wmatrix <- wimp$weights
    self <- wimp[["self"]][[1]]
    ideal <- wimp[["self"]][[2]]}

  if(is.na(vertex.vector[1])){
    vertex.vector <-  self
  }else{
    vertex.vector <- vertex.vector
  }

  if(is.na(ideal.vector[1])){
    ideal.vector <- ideal
  }else{
    ideal.vector <- ideal.vector
  }

  vertex.name <- c()
  n <- 1
  for (x in vertex.vector) {
    if(x < 0){vertex.name[n] <- lpoles[n] }
    else{
      if(x > 0){vertex.name[n] <- rpoles[n] }
      else{
        if(x == 0){vertex.name[n] <- poles[n]}
      }
    }
    n <- n + 1
  }

  congruency.vector <- vertex.vector/ideal.vector

  discrepant.color <- .color.selection(color)[1]
  congruent.color <- .color.selection(color)[2]
  undefined.color <- .color.selection(color)[3]
  dilemmatic.color <- .color.selection(color)[4]

  vertex.color <- sapply(congruency.vector, function(x) case_when(
    x < 0 && x != -Inf ~ discrepant.color,
    x > 0 && x != Inf ~ congruent.color,
    x == 0 ~ undefined.color,
    is.infinite(x) ~ dilemmatic.color,
    .default = congruent.color)
  )

  vertex.group <- sapply(congruency.vector, function(x) case_when(
    x < 0 && x != -Inf ~ "Discrepant",
    x > 0 && x != Inf ~ "Congruent",
    x == 0 ~ "Undefined Self",
    is.infinite(x) ~ "Dilemmatic",
    .default = "Dilemmatic")
  )

  level.vector <- vertex.vector
  level.vector[level.vector == 0] <- 1
  level.vector <- level.vector * ideal.vector

  vertex.vadjust <- sapply(abs(vertex.vector), function(x) -4*x^2-25*x-42)

  vertex <- data.frame(
                      id = 1:length(vertex.vector),
                      label = vertex.name,
                      group = vertex.group,
                      size = 30 * abs(vertex.vector) + 20,
                      shape = "dot",
                      title = paste("<p><b>", poles,"</b><br>Self:",
                                    round(vertex.vector,2),"<br>Ideal:",
                                    round(ideal,2),"</p>"),
                      color = vertex.color,
                      shadow = TRUE,
                      hidden = !show,
                      font.size = 20,
                      font.strokeWidth = 3,
                      font.vadjust = vertex.vadjust
                      )

  n <- 1

  for (i in vertex.vector){
    if(i != 0){
      direction.value <- i / abs(i)
      wmatrix[,n] <- wmatrix[,n] * direction.value
      wmatrix[n,] <- wmatrix[n,] * direction.value
    }
    n <- n + 1
  }
  n.vertex <- nrow(wmatrix)

  if(hide.inverse){
    logical.dilemmatic <- ideal == 0

    wmatrix[wmatrix > 0] <- 0
    wmatrix[logical.dilemmatic,] <- 0
    wmatrix[,logical.dilemmatic] <- 0
  }
  weight.vector <- c()
  from.vector <- c()
  to.vector <- c()

  for (i in 1:n.vertex) {
    for (j in 1:n.vertex) {
      weight <- wmatrix[i, j]
      if (weight != 0) {
        weight.vector <- c(weight.vector,weight)
        from.vector <- c(from.vector,i)
        to.vector <- c(to.vector,j)
      }}}

  if(color!= "grey scale" ){
  edges.color <- sapply(weight.vector, function(x)
    ifelse(x > 0 , "grey","#CD5C5C"))
  edges.dashes <- FALSE
  }else{
  edges.color <- "grey"
  edges.dashes <- sapply(weight.vector, function(x)
    ifelse(x > 0 , FALSE,TRUE))
  }

  edge.curved <- logical(length(weight.vector))
  n <- 1
  for (N in 1:dim(wmatrix)[1]) {
    for (M in 1:dim(wmatrix)[1]) {
      if(wmatrix[M,N] != 0 && wmatrix[N,M] != 0){
        edge.curved[n] <- TRUE
      }
      if(wmatrix[N,M] != 0){
        n <- n + 1
      }}}



  edges <- data.frame(
                      from = from.vector,
                      to = to.vector,
                      width = 2 * abs(weight.vector),
                      arrows = "to",
                      dashes = edges.dashes,
                      smooth = edge.curved,
                      color = edges.color,
                      title = round(weight.vector,2)
                      )

  if(layout == "graphopt"){layout <- "layout_with_graphopt"}
  if(layout == "circle"){layout <- "layout_in_circle"}
  if(layout == "tree"){layout <- "layout_as_tree"}
  if(layout == "mds"){layout <- "layout_with_mds"}
  if(layout == "grid"){layout <- "layout_on_grid"}

  if(layout == "rtcircle"){
    visNetwork(vertex, edges, height = height, width = width) %>%
    visIgraphLayout(layout = "layout_as_tree", circular = TRUE) %>%
    visOptions(highlightNearest =
               list(enabled = T, degree = 0, labelOnly = TRUE),
               selectedBy = list(variable = "group",main = "All" )) %>%
    visInteraction(navigationButtons = TRUE,multiselect = TRUE)
  }else{
    visNetwork(vertex, edges, height = height, width = width) %>%
    visIgraphLayout(layout = layout,randomSeed = 33) %>%
    visOptions(highlightNearest =
               list(enabled = T, degree = 0, labelOnly = TRUE),
               selectedBy = list(variable = "group",main = "All" )) %>%
    visInteraction(navigationButtons = TRUE,multiselect = TRUE)
  }
}

#' Sustituto para idealdigraph
#'
#' @param wimp
#' @param inc
#' @param ...
#' @param layout
#'
#' @return
#' @export
#'
#' @examples
#'

idealdigraph.vis <- function(wimp, inc=TRUE, layout = "circle", ...){
  print("entro en idealdigraph.vis")
  ideal.vector <- wimp$ideal[[2]]
  print("ideal.vector: ") 
  print(ideal.vector)
  print(inc)
  digraph(wimp = wimp, hide.inverse = inc, vertex.vector = ideal.vector, layout = layout, ...)
}

#' Sustituto para simdigraph
#'
#' @param scn
#' @param niter
#' @param ...
#'
#' @return
#' @export
#'
#' @examples

simdigraph.vis <- function(scn, niter = 0, ...){

  vertex.vector <- scn[[1]][niter+1,]
  digraph(wimp = scn, vertex.vector = vertex.vector, ...)
}
