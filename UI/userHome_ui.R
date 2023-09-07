user_home_ui <-  fluidPage(
    shiny.i18n::usei18n(i18n),
div(class = "custom-margins",
    h2(i18n$t("Bienvenido a la página de inicio del usuario"), class = "pagetitlecustom"),
    p(i18n$t("Aquí puedes agregar más contenido para mostrar al usuario después de iniciar sesión"), class = "desccustom mb-4"),
    column(12, class="d-flex mb-4 justify-content-center", actionButton("crear_nuevo", i18n$t("Nuevo análisis de rejilla"), status = 'success', icon = icon("plus"))),
    fluidRow(class = "table-container",
      shinycssloaders::withSpinner(tableOutput("rejillas_anteriores"), type = 4, color = "#022a0c", size = 0.6)),
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