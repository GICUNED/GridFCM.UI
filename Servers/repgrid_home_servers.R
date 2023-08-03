repgrid_home_server <- function(input, output, session) {
  # Mostrar los datos importados en una tabla
  #session$userData$datos_repgrid <- if (!is.null("Servers/Repgrid_data.xlsx")) {
      #OpenRepGrid::importExcel("Servers/Repgrid_data.xlsx")
    #}
  #session$userData$datos_to_table<- read.xlsx("Servers/Repgrid_data.xlsx")
  print("Repgrid")
  print(session$userData$datos_repgrid)
  if (is.null(session$userData$datos_repgrid) || is.null(session$userData$datos_to_table)) {
    shinyjs::show("repgrid_home_warn")
    repgrid_aux <- 0
    tabla_aux <- 0
  }else{
    shinyjs::hide("repgrid_home_warn")
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
  #indicess <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
  indicess <- seq(1, session$userData$num_col_repgrid - 1)


  rhandsontable(tabla_manipulable()) %>%
    hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
      hot_col(col = indicess, format = "1")

  }
})

## NEW ####################################################################

# To validate that the values of the cells of the table are between 1 and 7
validateValue <- function(changes, tabla) {

  new_v = changes[[1]][[4]]
  tabla_r <- hot_to_r(tabla)
  nombres_columnas <- colnames(tabla_r)

  min_val = nombres_columnas[1]
  max_val = nombres_columnas[length(nombres_columnas)]

  if(!is.na(new_v) && is.numeric(new_v) && (new_v > max_val || new_v < min_val)) {
    mensaje <- paste("El valor debe estar entre el rango", min_val, "-", max_val, ".")
    showModal(modalDialog(
      title = "Error",
      mensaje,
      easyClose = TRUE
    ))
    return(FALSE)
  }
  return(TRUE)
}

observeEvent(input$tabla_datos_repgrid, {

  changes <- input$tabla_datos_repgrid$changes$changes

  if (!is.null(changes)) {
    val <- validateValue(changes, input$tabla_datos_repgrid)
    if (!val) {
      xi = changes[[1]][[1]]
      yi = changes[[1]][[2]]
      old_v = changes[[1]][[3]]
      
      tabla_original <- hot_to_r(input$tabla_datos_repgrid)
      tabla_original[xi+1, yi+1] <- old_v
      print(old_v)
      tabla_manipulable(tabla_original)

    } else if (!is.null(session$userData$datos_repgrid)) {
      tabla_manipulable(hot_to_r(input$tabla_datos_repgrid))
    }
  }
})

## /NEW ###################################################################

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
    print("reiniciar")
    if (!is.null(session$userData$datos_repgrid)) {
        tabla_manipulable(tabla_final)

        tabla_final <- tabla_manipulable()
        print("tabla_final: ")
        my_dataframe <-tabla_final

        # Create a temporary file
        temp_file <- tempfile(fileext = ".xlsx")

        # Write the dataframe to the temporary file
        OpenRepGrid::saveAsExcel(session$userData$datos_repgrid, temp_file)
        print(paste("Temporary file saved at: ", temp_file))

        # Check if the file exists and is not empty
        if (file.exists(temp_file) && file.size(temp_file) > 0) {
            # Read the data from the temporary file
            df_read <- read.xlsx(temp_file)
            # Print the data
            print(df_read)

            # Check if df_read is not NULL or empty
            if (!is.null(df_read) && nrow(df_read) > 0) {
                # Create a repgrid object
                my_repgrid <- df_read

                print(my_repgrid)

                repgrid_a_mostrar(session$userData$datos_repgrid)
                #session$userData$datos_repgrid <- repgrid_a_mostrar()
                session$userData$datos_to_table<- my_repgrid 
            } else {
                print("Error: df_read is NULL or empty.")
            }
        } else {
            print("Error: The temporary file does not exist or is empty.")
        }
    }
})




  observeEvent(input$guardar, {
    if (!is.null(session$userData$datos_repgrid)) {
        tabla_final <- tabla_manipulable()
        print("tabla_final: ")
        my_dataframe <-tabla_final

        # Create a temporary file
        temp_file <- tempfile(fileext = ".xlsx")

        # Write the dataframe to the temporary file
        write.xlsx(my_dataframe, temp_file)
        print(paste("Temporary file saved at: ", temp_file))

        # Check if the file exists and is not empty
        if (file.exists(temp_file) && file.size(temp_file) > 0) {
            # Read the data from the temporary file
            df_read <- OpenRepGrid::importExcel(temp_file)

            # Print the data
            print(df_read)

            # Check if df_read is not NULL or empty
            if (!is.null(df_read) && nrow(df_read) > 0) {
                # Create a repgrid object
                my_repgrid <- df_read

                print(my_repgrid)

                repgrid_a_mostrar(my_repgrid)
                session$userData$datos_repgrid <- repgrid_a_mostrar()
                session$userData$datos_to_table<- tabla_final

                # Hide the "Save" button and show the "Edit" button
                shinyjs::hide("guardar")
                shinyjs::hide("reiniciar")
                shinyjs::show("editar")

                # Switch to viewing mode
                shinyjs::hide("tabla_datos_repgrid_container")
                shinyjs::show("prueba_container")
            } else {
                print("Error: df_read is NULL or empty.")
            }
        } else {
            print("Error: The temporary file does not exist or is empty.")
        }
    }
    repgrid_analisis_server(input,output,session)
})

  observeEvent(input$tabs_rep, {
      print(paste("Tab seleccionado: ", input$tabs_rep))
    
    if (input$tabs_rep == "Data") {
      print("Has seleccionado la pestaña Data")
    } else if (input$tabs_rep == "Results") {
      print("Has seleccionado la pestaña Results")
      print("showing the results:")
      repgrid_analisis_server(input,output,session)
    }
      
    })
}

