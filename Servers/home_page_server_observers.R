home_server <- function(input, output, session) {
  # Colocar aquí las funciones y observadores específicos para la página de inicio
  
  component <- reactive({
    if (is.null(get_query_param()$add)) {
      return(0)
    }
    as.numeric(get_query_param()$add)
  })
  
  output$power_of_input <- renderUI({
    HTML(paste(
      "I display input increased by <code>add</code> GET parameter from app url and pass result to <code>output$power_of_input</code>: ",
      as.numeric(input$int) + component()))
  })
  
  
  
  observeEvent(input$go_to_home, {
    runjs("window.location.href = '/';")
    
  })

}