userHome_server <- function(input, output, session) {
  # gregar código para manejar eventos y actualizar elementos en la página user.home
  # Lógica del servidor para la página user.home

  # Ejemplo de datos de rejillas (Reemplazar esto con datos reales de la base de datos)
  rejillas <- reactiveVal(data.frame(
    Nombre = c("Rejilla 1", "Rejilla 2", "Rejilla 3"),
    Tipo = c("RepGrid", "WimpGrid", "Fullgrid"),
    stringsAsFactors = FALSE
  ))

  output$rejillas_anteriores <- renderTable({
    req(rejillas())
    rejillas()
  })

  observeEvent(input$crear_nuevo, {
    # Navega a la página de creación de un nuevo análisis de rejilla
    # route_link("nombre_de_la_pagina_de_creacion")
    runjs("window.location.href = '/#!/import';")
  })

}