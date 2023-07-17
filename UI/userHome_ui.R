user_home_ui <-  fluidPage(
    shiny.i18n::usei18n(i18n),
div(class = "custom-margins",
    h2("Bienvenido a la página de inicio del usuario", class = "pagetitlecustom"),
    p("Aquí puedes agregar más contenido para mostrar al usuario después de iniciar sesión", class = "desccustom mb-6"),
    column(12, class="d-flex mb-4 justify-content-center", actionButton("crear_nuevo", "Nuevo análisis de rejilla", status = 'success', icon = icon("plus"))),
    fluidRow(class = "table-container",
      tableOutput("rejillas_anteriores")),
  )


  
  )

observeEvent(input$ROUTE_PATH, {
    route_path <- input$ROUTE_PATH
    if (route_path == "/") {
      updateTabItems(session, "sidebar", "page1", selected = TRUE)
    } else if (route_path == "/user_home") {
      updateTabItems(session, "sidebar", "page2", selected = TRUE)
    }
  })