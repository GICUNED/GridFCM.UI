# another_page_server_observers.R

another_server <- function(input, output, session) {
  # Colocar aquí las funciones y observadores específicos para la página "otra"
  # Manejar el input y output en la página "another"
  output$another_output <- renderText({
    paste("You typed:", input$another_input)
  })
  observeEvent(input$go_to_another, {
    runjs("window.location.href = '/#!/another';")
  })
}