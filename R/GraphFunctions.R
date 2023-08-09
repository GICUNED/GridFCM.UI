## GRAPH FUNCTIONS ##

# PCSD -----------------------------------------------------------------

#' Personal Constructs System Dynamics plot -- pcsd()
#'
#' @description Interactive line plot of personal constructs system dinamics.
#' Show \code{\link{scenariomatrix}} values expressed in terms of distance to
#' Ideal-Self for each personal construct across the mathematical iterations.
#'
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

  iter <- nrow(scn$values)


  ideal.vector <- scn$self[[2]]
  ideal.matrix <- matrix(ideal.vector, ncol = length(ideal.vector),             # Create a matrix with Ideal-Self values repeated by rows.
                         nrow = iter, byrow = TRUE)

  res <- scn$values


  x <- c(0:(iter -1))
  y <- c(0:length(poles))
  y <- as.character(y)
  df <- data.frame(x, abs(res - ideal.matrix) / 2)                              # Dataframe with the standardised distances between self-now and ideal-self.
  colnames(df) <- y

  fig <- plotly::plot_ly(df, x = ~x, y = df[,2], name = poles[1],
                         type = 'scatter',
                         mode = 'lines+markers',line = list(shape = "spline"))  # Build PCSD with plotly.

  for (n in 3:(length(poles)+1)) {
    fig <- fig %>% plotly::add_trace(y = df[,n], name = poles[n-1],
                                     mode = 'lines+markers'
                                     ,line = list(shape = "spline"))
  }
  fig <- fig %>% plotly::layout(
    xaxis = list(
      title = "ITERATIONS"
    ),
    yaxis = list(
      title = "DISTANCE TO IDEAL SELF",
      range = c(-0.05,1.05)
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


# PCSD Derivative ---------------------------------------------------------

#' PCSD derivative -- pcsd_derivative()
#'
#' @description This function represents the first derivative for each of the
#' PCSD curves.
#'
#' @param scn
#'
#' @return Return a plot create via plotly r-package.
#'
#' @import plotly
#'
#' @export

pcsd_derivative <- function(scn){


  lpoles <- scn$constructs[[1]]
  rpoles <- scn$constructs[[2]]
  poles <- scn$constructs[[3]]


  iter <- scn$convergence                                                       # Save convergence value.

  ideal.vector <- scn$self[[2]]
  ideal.matrix <- matrix(ideal.vector, ncol = length(ideal.vector),             # Create a matrix with Ideal-Self values repeated by rows.
                         nrow = iter + 4, byrow = TRUE)


  res.pre <- scn$values
  res.pre <- abs(res.pre - ideal.matrix) / 2

  print(res.pre)

  x <- c(0:(iter + 2))
  y <- c(0:length(poles))

  res <- matrix(ncol = length(poles), nrow = iter + 3)

  for (i in 1:length(poles)) {
    res[,i] <- diff(res.pre[,i])/diff(0:(iter + 3))                               # Calculate de diffs
  }

  y <- as.character(y)

  df <- data.frame(x,res)                                                       # Made a dataframe with the results.
  colnames(df) <- y

  fig <- plotly::plot_ly(df, x = ~x, y = df[,2], name = poles[1],
                         type = 'scatter', mode = 'lines+markers',
                         line = list(shape = "spline"))

  for (n in 3:(length(poles)+1)) {
    fig <- fig %>% plotly::add_trace(y = df[,n], name = poles[n-1],
                                     mode = 'lines+markers',
                                     line = list(shape = "spline"))
  }

  fig <- fig %>% plotly::layout(xaxis = list(
    title = "ITERATIONS"),
    yaxis = list(
      title = "DERIVATIVE"))

  fig <- fig %>% plotly::layout(legend=list(
    title=list(text='<b>PERSONAL CONSTRUCTS</b>')))

  fig                                                                           # Config the plot and run it.
}


# Simulation Digraph ------------------------------------------------------

#' Digraph of simulation scenario -- simdigraph()
#'
#' @param scn
#' @param niter
#' @param layout
#' @param vertex.size
#' @param edge.width
#' @param color
#'
#' @return
#'
#' @import igraph
#' @export
#'
#' @examples
#'

simdigraph <- function(scn,niter = 0, layout = "graphopt", vertex.size = 1, edge.width = 1, color = "red/green"){

  lpoles <- scn$constructs[[1]]                                                 # Save constructs names (left and rigth poles)
  rpoles <- scn$constructs[[2]]

  wmat <- scn$weights                                                           # Save weight matrix

  results <- scn$values[niter + 1,]                                             # Save the vector corresponding to the iteration to be represented
  ideal <- scn$self[[2]]

  n <- 1                                                                        # Orient the weight matrix according the vertex status.
  # This change the colour of the edges depending on vertex status.
  for (i in results){
    if(i != 0){
      direction.value <- i / abs(i)
      wmat[,n] <- wmat[,n] * direction.value
      wmat[n,] <- wmat[n,] * direction.value
    }
    n <- n + 1
  }

  graph.map <- graph.adjacency(wmat,mode = "directed",weighted = T)             # Initial empty network.


  # Edge Config -------------------------------------------------------------



  E(graph.map)$width <- sapply(E(graph.map)$weight, function(x)                 # Edge width
    abs(x * 3 * edge.width))

  if(color == "grey scale"){
    E(graph.map)$lty <- sapply(E(graph.map)$weight, function(x)                 # Edge colour
      ifelse(x < 0, 2, 1 ))
  }else{
    E(graph.map)$color <- sapply(E(graph.map)$weight, function(x)
      ifelse(x < 0, "red", "black" ))
  }


  edge.curved <- rep(0, length(E(graph.map)))                                   # Edge curvature.
  n <- 1
  for (N in 1:dim(wmat)[1]) {
    for (M in 1:dim(wmat)[1]) {
      if(wmat[M,N] != 0 && wmat[N,M] != 0){
        edge.curved[n] <- 0.25
      }
      if(wmat[N,M] != 0){
        n <- n + 1
      }
    }
  }

  # Vertex Config -----------------------------------------------------------


  congruency.vector <- results/ideal                                            # vertex colour


  discrepant.color <- .color.selection(color)[1]
  congruent.color <- .color.selection(color)[2]
  undefined.color <- .color.selection(color)[3]
  dilemmatic.color <- .color.selection(color)[4]


  V(graph.map)$color <- sapply(congruency.vector, function(x)
    ifelse(x < 0 && x != -Inf, discrepant.color,
           ifelse(x > 0 && x != Inf, congruent.color,
                  ifelse(x == 0,undefined.color, dilemmatic.color))))


  n <- 1                                                                        # Vertex name.
  for (pole.name.vertex in results) {
    if(pole.name.vertex < 0){V(graph.map)$name[n] <- lpoles[n] }
    else{
      if(pole.name.vertex > 0){V(graph.map)$name[n] <- rpoles[n] }
      else{
        if(pole.name.vertex == 0){V(graph.map)$name[n] <- paste(lpoles[n],"-",
                                                                rpoles[n],sep =
                                                                  " ")}
      }
    }
    n <- n + 1
  }
                                                                                # Vertex size
  V(graph.map)$size <- sapply(results, function(x) 5 + abs(x * vertex.size * 15))


  # Final config ------------------------------------------------------------

  E(graph.map)$arrow.size <- edge.width * 0.5
  V(graph.map)$shape <- "circle"
  V(graph.map)$label.cex <- 0.75
  V(graph.map)$label.family <- "sans"
  V(graph.map)$label.font <- 2
  V(graph.map)$label.color <- "#323232"


  # Layouts -----------------------------------------------------------------

  if(layout == "rtcircle"){
    graph.map <- add_layout_(graph.map,as_tree(circular = TRUE, mode = "out"))
  }
  if(layout == "tree"){
    graph.map <- add_layout_(graph.map,as_tree())
  }
  if(layout == "circle"){
    graph.map <- add_layout_(graph.map,in_circle())
  }
  if(layout == "graphopt"){
    set.seed(3394)
    matrix.seed <- matrix(rnorm(2 * dim(grid)[1]), ncol = 2)

    graph.map <- add_layout_(graph.map,with_graphopt(start = matrix.seed))
  }
  if(layout == "mds"){
    graph.map <- add_layout_(graph.map,with_mds())
  }
  if(layout == "grid"){
    graph.map <- add_layout_(graph.map,on_grid())
  }



  plot.igraph(graph.map, edge.curved = edge.curved)                             # Show the digraph on the screen.
}


# Self Digraph ------------------------------------------------------------


#' Self digraph
#'
#' @param wimp
#' @param layout
#' @param vertex.size
#' @param edge.width
#' @param color
#'
#' @return
#'
#' @import igraph
#' @export
#'
#' @examples
#'

selfdigraph <- function(wimp, layout = "circle", vertex.size = 1, edge.width = 1, color = "red/green"){

  lpoles <- wimp$constructs[[1]]                                                # Save constructs names (left and rigth poles)
  rpoles <- wimp$constructs[[2]]

  wmat <- wimp$scores[[3]]                                                      # Save weight matrix

  results <- wimp$self[[2]]
  ideal <- wimp$ideal[[2]]

  n <- 1                                                                        # Orient the weight matrix according the vertex status.
  # This change the colour of the edges depending on vertex status.
  for (i in results){
    if(i != 0){
      direction.value <- i / abs(i)
      wmat[,n] <- wmat[,n] * direction.value
      wmat[n,] <- wmat[n,] * direction.value
    }
    n <- n + 1
  }

  graph.map <- graph.adjacency(wmat,mode = "directed",weighted = T)             # Initial empty network.


  # Edge Config -------------------------------------------------------------



  E(graph.map)$width <- sapply(E(graph.map)$weight, function(x)                 # Edge width
    abs(x * 3 * edge.width))


  if(color == "grey scale"){
    E(graph.map)$lty <- sapply(E(graph.map)$weight, function(x)                 # Edge colour
      ifelse(x < 0, 2, 1 ))
  }else{
    E(graph.map)$color <- sapply(E(graph.map)$weight, function(x)
      ifelse(x < 0, "red", "black" ))
  }

  edge.curved <- rep(0, length(E(graph.map)))                                   # Edge curvature.
  n <- 1
  for (N in 1:dim(wmat)[1]) {
    for (M in 1:dim(wmat)[1]) {
      if(wmat[M,N] != 0 && wmat[N,M] != 0){
        edge.curved[n] <- 0.25
      }
      if(wmat[N,M] != 0){
        n <- n + 1
      }
    }
  }

  # Vertex Config -----------------------------------------------------------


  congruency.vector <- results/ideal                                            # vertex colour

  discrepant.color <- .color.selection(color)[1]
  congruent.color <- .color.selection(color)[2]
  undefined.color <- .color.selection(color)[3]
  dilemmatic.color <- .color.selection(color)[4]

  V(graph.map)$color <- sapply(congruency.vector, function(x)
    ifelse(x < 0 && x != -Inf, discrepant.color,
           ifelse(x > 0 && x != Inf, congruent.color,
                  ifelse(x == 0,undefined.color, dilemmatic.color))))


  n <- 1                                                                        # Vertex name.
  for (pole.name.vertex in results) {
    if(pole.name.vertex < 0){V(graph.map)$name[n] <- lpoles[n] }
    else{
      if(pole.name.vertex > 0){V(graph.map)$name[n] <- rpoles[n] }
      else{
        if(pole.name.vertex == 0){V(graph.map)$name[n] <- paste(lpoles[n],"-",
                                                                rpoles[n],sep =
                                                                  " ")}
      }
    }
    n <- n + 1
  }
  # Vertex size
  V(graph.map)$size <- sapply(results, function(x) 5 + abs(x * vertex.size * 15))


  # Final config ------------------------------------------------------------

  E(graph.map)$arrow.size <- edge.width * 0.5
  V(graph.map)$shape <- "circle"
  V(graph.map)$label.cex <- 0.75
  V(graph.map)$label.family <- "sans"
  V(graph.map)$label.font <- 2
  V(graph.map)$label.color <- "#323232"


  # Layouts -----------------------------------------------------------------

  if(layout == "rtcircle"){
    graph.map <- add_layout_(graph.map,as_tree(circular = TRUE, mode = "out"))
  }
  if(layout == "tree"){
    graph.map <- add_layout_(graph.map,as_tree())
  }
  if(layout == "circle"){
    graph.map <- add_layout_(graph.map,in_circle())
  }
  if(layout == "graphopt"){
    set.seed(3394)
    matrix.seed <- matrix(rnorm(2 * dim(grid)[1]), ncol = 2)

    graph.map <- add_layout_(graph.map,with_graphopt(start = matrix.seed))
  }
  if(layout == "mds"){
    graph.map <- add_layout_(graph.map,with_mds())
  }
  if(layout == "grid"){
    graph.map <- add_layout_(graph.map,on_grid())
  }



  plot.igraph(graph.map, edge.curved = edge.curved)                             # Show the digraph on the screen.
}


# Ideal Digraph -----------------------------------------------------------


#' Ideal digraph
#'
#' @param wimp
#' @param inc
#' @param layout
#' @param vertex.size
#' @param edge.width
#' @param color
#'
#' @return
#'
#' @import igraph
#' @export
#'
#' @examples
#'

idealdigraph <- function(wimp, inc = FALSE, layout = "circle", vertex.size = 1, edge.width = 1, color = "red/green"){

  lpoles <- wimp$constructs[[1]]                                                # Save constructs names (left and rigth poles)
  rpoles <- wimp$constructs[[2]]

  wmat <- wimp$scores[[3]]                                                      # Save weight matrix

  results <- wimp$ideal[[2]]
  ideal <- wimp$ideal[[2]]




  n <- 1                                                                        # Orient the weight matrix according the vertex status.
  # This change the colour of the edges depending on vertex status.
  for (i in results){
    if(i != 0){
      direction.value <- i / abs(i)
      wmat[,n] <- wmat[,n] * direction.value
      wmat[n,] <- wmat[n,] * direction.value
    }
    n <- n + 1
  }

  if(inc){
    logical.dilemmatic <- ideal == 0

    wmat[wmat > 0] <- 0
    wmat[logical.dilemmatic,] <- 0
    wmat[,logical.dilemmatic] <- 0
  }

  graph.map <- graph.adjacency(wmat,mode = "directed",weighted = T)             # Initial empty network.


  # Edge Config -------------------------------------------------------------



  E(graph.map)$width <- sapply(E(graph.map)$weight, function(x)                 # Edge width
    abs(x * 3 * edge.width))


  if(color == "grey scale"){
    E(graph.map)$lty <- sapply(E(graph.map)$weight, function(x)                 # Edge colour
      ifelse(x < 0, 2, 1 ))
  }else{
    E(graph.map)$color <- sapply(E(graph.map)$weight, function(x)
      ifelse(x < 0, "red", "black" ))
  }

  edge.curved <- rep(0, length(E(graph.map)))                                   # Edge curvature.
  n <- 1
  for (N in 1:dim(wmat)[1]) {
    for (M in 1:dim(wmat)[1]) {
      if(wmat[M,N] != 0 && wmat[N,M] != 0){
        edge.curved[n] <- 0.25
      }
      if(wmat[N,M] != 0){
        n <- n + 1
      }
    }
  }

  # Vertex Config -----------------------------------------------------------


  congruency.vector <- results/ideal                                            # vertex colour

  discrepant.color <- .color.selection(color)[1]
  congruent.color <- .color.selection(color)[2]
  undefined.color <- .color.selection(color)[3]
  dilemmatic.color <- .color.selection(color)[4]

  V(graph.map)$color <- sapply(congruency.vector, function(x)
    ifelse(x < 0 && x != -Inf, discrepant.color,
           ifelse(x > 0 && x != Inf, congruent.color,
                  ifelse(x == 0,undefined.color, dilemmatic.color))))


  n <- 1                                                                        # Vertex name.
  for (pole.name.vertex in results) {
    if(pole.name.vertex < 0){V(graph.map)$name[n] <- lpoles[n] }
    else{
      if(pole.name.vertex > 0){V(graph.map)$name[n] <- rpoles[n] }
      else{
        if(pole.name.vertex == 0){V(graph.map)$name[n] <- paste(lpoles[n],"-",
                                                                rpoles[n],sep =
                                                                  " ")}
      }
    }
    n <- n + 1
  }
  # Vertex size
  V(graph.map)$size <- sapply(results, function(x) 5 + abs(x * vertex.size * 15))


  # Final config ------------------------------------------------------------

  E(graph.map)$arrow.size <- edge.width * 0.5
  V(graph.map)$shape <- "circle"
  V(graph.map)$label.cex <- 0.75
  V(graph.map)$label.family <- "sans"
  V(graph.map)$label.font <- 2
  V(graph.map)$label.color <- "#323232"


  # Layouts -----------------------------------------------------------------

  if(layout == "rtcircle"){
    graph.map <- add_layout_(graph.map,as_tree(circular = TRUE, mode = "out"))
  }
  if(layout == "tree"){
    graph.map <- add_layout_(graph.map,as_tree())
  }
  if(layout == "circle"){
    graph.map <- add_layout_(graph.map,in_circle())
  }
  if(layout == "graphopt"){
    set.seed(3394)
    matrix.seed <- matrix(rnorm(2 * dim(grid)[1]), ncol = 2)

    graph.map <- add_layout_(graph.map,with_graphopt(start = matrix.seed))
  }
  if(layout == "mds"){
    graph.map <- add_layout_(graph.map,with_mds())
  }
  if(layout == "grid"){
    graph.map <- add_layout_(graph.map,on_grid())
  }



  plot.igraph(graph.map, edge.curved = edge.curved)                             # Show the digraph on the screen.
}
