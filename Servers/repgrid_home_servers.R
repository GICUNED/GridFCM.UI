repgrid_home_server <- function(input, output, session) {
  # Mostrar los datos importados en una tabla
  #session$userData$datos_repgrid <- if (!is.null("Servers/Repgrid_data.xlsx")) {
      #OpenRepGrid::importExcel("Servers/Repgrid_data.xlsx")
    #}
  #session$userData$datos_to_table<- read.xlsx("Servers/Repgrid_data.xlsx")
  print("Repgrid")
  print(session$userData$datos_to_repgrid)
  if (is.null(session$userData$datos_repgrid) || is.null(session$userData$datos_to_table)) {
    datos_control <- 0
    datos_control_table <- 0
  }else{
    datos_control <- session$userData$datos_repgrid
    datos_control_table <- session$userData$datos_to_table
  }

  datos_initial <- reactiveVal(datos_control)
  datos_show <- reactiveVal(datos_control)
  datos_change <- reactiveVal(datos_control_table)
  #datos_change <- session$userData$datos_to_table
  datos_table_final <- datos_control_table
  
  #output$tabla_datos_repgrid <- DT::renderDataTable({
  #  DT::datatable(datos_change, 
  #                class = 'my-custom-table', 
  #                options = list(autoWidth = TRUE, columnDefs = list(list(width = '30px', targets = "_all"))), editable = TRUE)
  #})

  output$tabla_datos_repgrid <- renderRHandsontable({
  if (!is.null(session$userData$datos_repgrid)) {
  print("datos_change:")
  print(datos_change)
  rhandsontable(datos_change()) %>%
    hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
  hot_col(c(1,7), readOnly = TRUE)
  }
})

observeEvent(input$tabla_datos_repgrid, {
  if (!is.null(session$userData$datos_repgrid)) {
    datos_change(hot_to_r(input$tabla_datos_repgrid))
    #datos_change <- datos_change
}})

  output$prueba <- renderPlot({
    if (!is.null(session$userData$datos_repgrid)) {
    bertin(datos_show() , color=c("white", "#005440"))
    }
  })

  # Observar cambios en la tabla editable y actualizar los datos de la sesión
  #observeEvent(input$tabla_datos_repgrid_cell_edit, {
  #  info <- input$tabla_datos_repgrid_cell_edit
  #  row <- info$row 
  #  col <- info$col
  #  value <- info$value
  
  #print(paste("Fila:", row, "Columna:", col, "Valor:", value))
  
  #datos_change$data[row, col] <- value  
  #})

  observeEvent(input$editar, {
    if (!is.null(session$userData$datos_repgrid)) {
    # Ocultar el botón "Editar" y mostrar el botón "Guardar"
    shinyjs::hide("editar")
    shinyjs::show("guardar")
    shinyjs::show("reiniciar")
    # Cambiar a modo de edición
    shinyjs::hide("prueba_container")
    shinyjs::show("tabla_datos_repgrid_container")
    }
  })

  observeEvent(input$reiniciar, {
    if (!is.null(session$userData$datos_repgrid)) {
    datos_change(datos_table_final)
    #session$userData$datos_repgrid <- datos_change()
    #session$userData$datos_to_table<- datos_table_final

    datos_table_final <- datos_change()
    print("datos_table_final: ")
    my_dataframe <-datos_table_final
    print(my_dataframe[1:22,2:14])
    element_names <- colnames(my_dataframe)[2:14]

    # Extract the left and right poles from the first column
    left_poles <- my_dataframe[, 1]
    right_poles <- my_dataframe[, 15]

    # Extract the scores from the data frame
    scores <- as.vector(as.matrix(my_dataframe[1:22,2:14]))
    print("scores: ")
    print(scores)
    # Create the args list
    args <- list(
      name = element_names,
      l.name = left_poles,
      r.name = right_poles,
      scores = scores
    )

    # Create a repgrid object
    my_repgrid <- makeRepgrid(args)
     my_repgrid <- setScale(my_repgrid, 1,7)
    print(my_repgrid)


    datos_show(my_repgrid)
    session$userData$datos_repgrid <- datos_show()
    session$userData$datos_to_table<- datos_table_final 

  }})

  observeEvent(input$guardar, {
    if (!is.null(session$userData$datos_repgrid)) {
    datos_table_final <- datos_change()
    print("datos_table_final: ")
    my_dataframe <-datos_table_final
    print(my_dataframe[1:22,2:14])
    element_names <- colnames(my_dataframe)[2:14]

    # Extract the left and right poles from the first column
    left_poles <- my_dataframe[, 1]
    right_poles <- my_dataframe[, 15]

    # Extract the scores from the data frame
    scores <- as.vector(as.matrix(my_dataframe[1:22,2:14]))
    print("scores: ")
    print(scores)
    # Create the args list
    args <- list(
      name = element_names,
      l.name = left_poles,
      r.name = right_poles,
      scores = scores
    )

    # Create a repgrid object
    my_repgrid <- makeRepgrid(args)
     my_repgrid <- setScale(my_repgrid, 1,7)
    print(my_repgrid)


    datos_show(my_repgrid)
    session$userData$datos_repgrid <- datos_show()
    session$userData$datos_to_table<- datos_table_final             
    # Ocultar el botón "Guardar" y mostrar el botón "Editar"
    shinyjs::hide("guardar")
    shinyjs::hide("reiniciar")
    shinyjs::show("editar")
    # Cambiar a modo de visualización
    shinyjs::hide("tabla_datos_repgrid_container")
    shinyjs::show("prueba_container")
    


    }
    repgrid_analisis_server(input,output,session)
  })
}

