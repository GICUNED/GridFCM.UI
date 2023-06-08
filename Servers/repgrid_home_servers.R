repgrid_home_server <- function(input, output, session) {
  # Mostrar los datos importados en una tabla
  #session$userData$datos_repgrid <- if (!is.null("Servers/Repgrid_data.xlsx")) {
      #OpenRepGrid::importExcel("Servers/Repgrid_data.xlsx")
    #}
  #session$userData$datos_to_table<- read.xlsx("Servers/Repgrid_data.xlsx")
  print("Repgrid")
  print(session$userData$datos_repgrid)
  if (is.null(session$userData$datos_repgrid) || is.null(session$userData$datos_to_table)) {
    repgrid_aux <- 0
    tabla_aux <- 0
  }else{
    repgrid_aux <- session$userData$datos_repgrid
    tabla_aux <- session$userData$datos_to_table
  }

  repgrid_inicial <- reactiveVal(repgrid_aux)
  repgrid_a_mostrar <- reactiveVal(repgrid_aux)

  tabla_manipulable <- reactiveVal(tabla_aux)
  #tabla_manipulable <- session$userData$datos_to_table
  tabla_final <- tabla_aux
  
  #output$tabla_datos_repgrid <- DT::renderDataTable({
  #  DT::datatable(tabla_manipulable, 
  #                class = 'my-custom-table', 
  #                options = list(autoWidth = TRUE, columnDefs = list(list(width = '30px', targets = "_all"))), editable = TRUE)
  #})

  output$tabla_datos_repgrid <- renderRHandsontable({
  if (!is.null(session$userData$datos_repgrid)) {
  print("tabla_manipulable:")
  print(tabla_manipulable)
  indicess <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14)

  rhandsontable(tabla_manipulable()) %>%
    hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
      hot_col(col = indicess, format = "1")

  }
})

observeEvent(input$tabla_datos_repgrid, {
  if (!is.null(session$userData$datos_repgrid)) {
    tabla_manipulable(hot_to_r(input$tabla_datos_repgrid))
    #tabla_manipulable <- tabla_manipulable
}})

output$bert <- renderPlot({
    if (!is.null(session$userData$datos_repgrid)) {
    bertin(repgrid_a_mostrar() , color=c("white", "#005440"))
    }
  })

  # Observar cambios en la tabla editable y actualizar los datos de la sesión
  #observeEvent(input$tabla_datos_repgrid_cell_edit, {
  #  info <- input$tabla_datos_repgrid_cell_edit
  #  row <- info$row 
  #  col <- info$col
  #  value <- info$value
  
  #print(paste("Fila:", row, "Columna:", col, "Valor:", value))
  
  #tabla_manipulable$data[row, col] <- value  
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
    tabla_manipulable(tabla_final)
    #session$userData$datos_repgrid <- tabla_manipulable()
    #session$userData$datos_to_table<- tabla_final

    tabla_final <- tabla_manipulable()
    print("tabla_final: ")
    my_dataframe <-tabla_final
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


    # Create a temporary file
    temp_file <- tempfile(fileext = ".xlsx")


    # Write the dataframe to the temporary file
    write.xlsx(my_dataframe, temp_file)

    print(paste("Temporary file saved at: ", temp_file))

    # Read the data from the temporary file
    df_read <- OpenRepGrid::importExcel(temp_file)

    # Print the data
    print(df_read)


   
    # Create a repgrid object
    #my_repgrid <- makeRepgrid(args)
    #my_repgrid <- setScale(my_repgrid, minValue,maxValue)
    my_repgrid <- df_read

    # Create a repgrid object
    #my_repgrid <- makeRepgrid(args)
    #my_repgrid <- setScale(my_repgrid, 1,7)
    print(my_repgrid)


    repgrid_a_mostrar(my_repgrid)
    session$userData$datos_repgrid <- repgrid_a_mostrar()
    session$userData$datos_to_table<- tabla_final 

  }})

  observeEvent(input$guardar, {
    if (!is.null(session$userData$datos_repgrid)) {
    tabla_final <- tabla_manipulable()
    print("tabla_final: ")
    my_dataframe <-tabla_final
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

 
	  minValue <-min(unlist(scores), na.rm=TRUE) 
	
	  maxValue <-max(unlist(scores), na.rm=TRUE)  
    
    # Create a temporary file
    temp_file <- tempfile(fileext = ".xlsx")


    # Write the dataframe to the temporary file
    write.xlsx(my_dataframe, temp_file)

    print(paste("Temporary file saved at: ", temp_file))

    # Read the data from the temporary file
    df_read <- OpenRepGrid::importExcel(temp_file)

    # Print the data
    print(df_read)


   
    # Create a repgrid object
    #my_repgrid <- makeRepgrid(args)
    #my_repgrid <- setScale(my_repgrid, minValue,maxValue)
    my_repgrid <- df_read
    print(my_repgrid)
   

    repgrid_a_mostrar(my_repgrid)
    session$userData$datos_repgrid <- repgrid_a_mostrar()
    session$userData$datos_to_table<- tabla_final           
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

