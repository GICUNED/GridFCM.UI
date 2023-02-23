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


  iter <- scn$convergence                                                       # Save convergence value.

  ideal.vector <- scn$self[[2]]
  ideal.matrix <- matrix(ideal.vector, ncol = length(ideal.vector),             # Create a matrix with Ideal-Self values repeated by rows.
                         nrow = iter + 4, byrow = TRUE)

  res <- scn$values


  x <- c(0:(iter + 3))
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
