repgrid_home_server <- function(input, output, session) {
  # Mostrar los datos importados en una tabla
  datos_initial <- session$userData$datos_repgrid
  datos1 <- reactiveVal(datos_initial)
  datos <- reactiveVal(session$userData$datos_to_table)

  output$tabla_datos_repgrid <- DT::renderDataTable({
    DT::datatable(datos(), 
                  class = 'my-custom-table', 
                  options = list(autoWidth = TRUE, columnDefs = list(list(width = '30px', targets = "_all"))), editable = TRUE)
  })

  output$prueba <- renderPlot({
    bertin(datos1(), color=c("white", "#005440"))
  })

  # Observar cambios en la tabla editable y actualizar los datos de la sesión
  observeEvent(input$tabla_datos_repgrid_cell_edit, {
    # Obtener la información de la celda editada
    info <- input$tabla_datos_repgrid_cell_edit
    row <- info$row
    col <- info$col
    value <- info$value

    # Actualizar el valor en el objeto data.frame
    datos_temp <- datos()
    datos_temp[row, col] <- value
    datos(datos_temp)

  })

  observeEvent(input$editar, {
    # Ocultar el botón "Editar" y mostrar el botón "Guardar"
    shinyjs::hide("editar")
    shinyjs::show("guardar")
    # Cambiar a modo de edición
    shinyjs::hide("prueba_container")
    shinyjs::show("tabla_datos_repgrid_container")
  })

  observeEvent(input$guardar, {
    # Ocultar el botón "Guardar" y mostrar el botón "Editar"
    shinyjs::hide("guardar")
    shinyjs::show("editar")
    # Cambiar a modo de visualización
    shinyjs::hide("tabla_datos_repgrid_container")
    shinyjs::show("prueba_container")
    
    # Convertir el data.frame a repgrid
    #datos_df <- datos()
    #constructs <- datos_df %>% dplyr::select(-1)
    #elements <- datos_df[[1]]
    #datos1_temp <- OpenRepGrid::constructRepgrid(elements, constructs)
    #datos1(datos1_temp)
  })
}
