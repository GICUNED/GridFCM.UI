repgrid_home_server <- function(input, output, session) {
  rol <- session$userData$rol
  if(!is.null(rol)){
    if(rol == "usuario_gratis"){
      shinyjs::disable("guardarComo")
    }
    if(rol == "usuario_demo"){
      shinyjs::disable("guardarComo")
      shinyjs::disable("guardarBD")
    }
  }

  #hide and show tooltips
  shinyjs::hide("context-rg-home")

  onevent("click", "tooltip-rg-home", shinyjs::show("context-rg-home"))
  onevent("click", "exit-rg-tooltip", shinyjs::hide("context-rg-home"))

  shinyjs::hide("open-controls-rg-2d")
  shinyjs::hide("open-controls-rg-3d")
  shinyjs::hide("open-controls-rg-cong")
  shinyjs::hide("open-controls-rg-in")
  shinyjs::hide("open-controls-rg-dil")
  

  #controles de pestaña Results ----------------------------------

  onevent("click", "exit-controls-rg", {
  
    shinyjs::show("open-controls-rg-2d")
    shinyjs::show("open-controls-rg-3d")
    shinyjs::show("open-controls-rg-cong")
    shinyjs::show("open-controls-rg-in")
    shinyjs::show("open-controls-rg-dil")
    shinyjs::hide("controls-panel-rg")
    
  }, add = TRUE)

    #Biplot 2d
  
  onevent("click", "open-controls-rg-2d", {
  
    shinyjs::hide("open-controls-rg-2d")
    shinyjs::hide("open-controls-rg-3d")
    shinyjs::hide("open-controls-rg-cong")
    shinyjs::hide("open-controls-rg-in")
    shinyjs::hide("open-controls-rg-dil")
    shinyjs::show("controls-panel-rg")
    
  }, add = TRUE)

    #Biplot 3d


  onevent("click", "open-controls-rg-3d", {
  
    shinyjs::hide("open-controls-rg-2d")
    shinyjs::hide("open-controls-rg-3d")
    shinyjs::hide("open-controls-rg-cong")
    shinyjs::hide("open-controls-rg-in")
    shinyjs::hide("open-controls-rg-dil")
    shinyjs::show("controls-panel-rg")
    
  }, add = TRUE)

    #Analisis conglomerados


  onevent("click", "open-controls-rg-cong", {
  
    shinyjs::hide("open-controls-rg-2d")
    shinyjs::hide("open-controls-rg-3d")
    shinyjs::hide("open-controls-rg-cong")
    shinyjs::hide("open-controls-rg-in")
    shinyjs::hide("open-controls-rg-dil")
    shinyjs::show("controls-panel-rg")
    
  }, add = TRUE)

  #Indices cognitivos

  onevent("click", "open-controls-rg-in", {
  
    shinyjs::hide("open-controls-rg-2d")
    shinyjs::hide("open-controls-rg-3d")
    shinyjs::hide("open-controls-rg-cong")
    shinyjs::hide("open-controls-rg-in")
    shinyjs::hide("open-controls-rg-dil")
    shinyjs::show("controls-panel-rg")
    
  }, add = TRUE)

  #Dilemas

  onevent("click", "open-controls-rg-dil", {
  
    shinyjs::hide("open-controls-rg-2d")
    shinyjs::hide("open-controls-rg-3d")
    shinyjs::hide("open-controls-rg-cong")
    shinyjs::hide("open-controls-rg-in")
    shinyjs::hide("open-controls-rg-dil")
    shinyjs::show("controls-panel-rg")
    
  }, add = TRUE)

runjs("

//Results ---------------------------------------------------

$('#exit-controls-rg').on('click', function (){

  $('.graphics-rg').addClass('mw-100');
  $('.graphics-rg').addClass('flex-bs-100');

  $('#controls-panel-rg').removeClass('anim-fade-in');
  $('#controls-panel-rg').addClass('anim-fade-out');

  $('#open-controls-rg-2d').removeClass('anim-fade-out');
  $('#open-controls-rg-2d').addClass('anim-fade-in');

  $('#open-controls-rg-3d').removeClass('anim-fade-out');
  $('#open-controls-rg-3d').addClass('anim-fade-in');
  
  $('#open-controls-rg-cong').removeClass('anim-fade-out');
  $('#open-controls-rg-cong').addClass('anim-fade-in');

  $('#open-controls-rg-in').removeClass('anim-fade-out');
  $('#open-controls-rg-in').addClass('anim-fade-in');

  $('#open-controls-rg-dil').removeClass('anim-fade-out');
  $('#open-controls-rg-dil').addClass('anim-fade-in');

});

//2d plot ---------------------------------------------------

$('#open-controls-rg-2d').on('click', function (){

  $('.graphics-rg').removeClass('mw-100');
  $('.graphics-rg').removeClass('flex-bs-100');

  $('#controls-panel-rg').addClass('anim-fade-in');
  $('#controls-panel-rg').removeClass('anim-fade-out');

  $('#open-controls-rg-2d').addClass('anim-fade-out');
  $('#open-controls-rg-2d').removeClass('anim-fade-in');

});

//3d plot ---------------------------------------------------


$('#open-controls-rg-3d').on('click', function (){

  $('.graphics-rg').removeClass('mw-100');
  $('.graphics-rg').removeClass('flex-bs-100');

  $('#controls-panel-rg').addClass('anim-fade-in');
  $('#controls-panel-rg').removeClass('anim-fade-out');

  $('#open-controls-rg-3d').addClass('anim-fade-out');
  $('#open-controls-rg-3d').removeClass('anim-fade-in');

});

//Conglomerados ---------------------------------------------------


$('#open-controls-rg-cong').on('click', function (){

  $('.graphics-rg').removeClass('mw-100');
  $('.graphics-rg').removeClass('flex-bs-100');

  $('#controls-panel-rg').addClass('anim-fade-in');
  $('#controls-panel-rg').removeClass('anim-fade-out');

  $('#open-controls-rg-cong').addClass('anim-fade-out');
  $('#open-controls-rg-cong').removeClass('anim-fade-in');

});

//indices cognitivos ---------------------------------------------------


$('#open-controls-rg-in').on('click', function (){

  $('.graphics-rg').removeClass('mw-100');
  $('.graphics-rg').removeClass('flex-bs-100');

  $('#controls-panel-rg').addClass('anim-fade-in');
  $('#controls-panel-rg').removeClass('anim-fade-out');

  $('#open-controls-rg-in').addClass('anim-fade-out');
  $('#open-controls-rg-in').removeClass('anim-fade-in');

});

//Dilemas ---------------------------------------------------


$('#open-controls-rg-dil').on('click', function (){

  $('.graphics-rg').removeClass('mw-100');
  $('.graphics-rg').removeClass('flex-bs-100');

  $('#controls-panel-rg').addClass('anim-fade-in');
  $('#controls-panel-rg').removeClass('anim-fade-out');

  $('#open-controls-rg-dil').addClass('anim-fade-out');
  $('#open-controls-rg-dil').removeClass('anim-fade-in');

});")


  #print("Repgrid")
  #print("Esta a null datos repgrid?")
  #print(is.null(session$userData$datos_to_table))
  #print(is.null(session$userData$datos_repgrid))
  if (is.null(session$userData$datos_repgrid) || is.null(session$userData$datos_to_table)) {
    show("repgrid_home_warn")
    show("repgrid_warning")

    hide("rg-data-content")
    hide("rg-analysis-content")

    
    repgrid_aux <- 0
    tabla_aux <- 0
  }else{
    hide("repgrid_home_warn")
    hide("repgrid_warning")
    
    repgrid_aux <- session$userData$datos_repgrid
    tabla_aux <- session$userData$datos_to_table

    show("rg-data-content")
    show("rg-analysis-content")
    
  }  
  
  repgrid_inicial <- reactiveVal(repgrid_aux)
  repgrid_a_mostrar <- reactiveVal(repgrid_aux)
  tabla_manipulable <- reactiveVal(tabla_aux)
  cambios_reactive <- reactiveVal(numeric(0))
  nombrePaciente <- reactiveVal()

  #tabla_manipulable <- session$userData$datos_to_table
  tabla_final <- tabla_aux
  #output$tabla_datos_repgrid <- DT::renderDataTable({
  #  DT::datatable(tabla_manipulable, 
  #                class = 'my-custom-table', 
  #                options = list(autoWidth = TRUE, columnDefs = list(list(width = '30px', targets = "_all"))), editable = TRUE)
  #})

  #print("Muestro repgrid_inicial: ")
  #print(repgrid_inicial)


output$titulo_repgrid <- renderText({
  con <- establishDBConnection()
  nombre <- DBI::dbGetQuery(con, sprintf("SELECT nombre from paciente WHERE id = %d", session$userData$id_paciente))
  DBI::dbDisconnect(con)
  nombrePaciente(nombre)
  fecha <- session$userData$fecha_repgrid
  paste("<b>", i18n$t("Simulación de "), nombre, "</b><br><p class='desccustom-date'>📅", fecha, "</p>")
})

output$tabla_datos_repgrid <- renderRHandsontable({
  if (!is.null(session$userData$datos_repgrid)) {
    print("tabla_manipulable:")
    print(tabla_manipulable)
    #indicess <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
    indicess <- seq(1, session$userData$num_col_repgrid - 1)


    rhandsontable(tabla_manipulable(), rowHeaders = NULL, useTypes=TRUE) %>%
       
      hot_table(highlightCol = TRUE, highlightRow = TRUE, stretchH="all") %>%
      hot_cols(fixedColumnsLeft = 1) %>%
      hot_col(col = indicess)%>%
      hot_context_menu(allowRowEdit=FALSE, allowColEdit=FALSE)

  }
})

## NEW ####################################################################

# To validate that the values of the cells of the table are between 1 and 7
validateValue <- function(changes, tabla) {

  new_v <- changes[[1]][[4]]
  tabla_r <- hot_to_r(tabla)
  nombres_columnas <- colnames(tabla_r)

  min_val <- as.numeric(nombres_columnas[1])
  max_val <- as.numeric(nombres_columnas[length(nombres_columnas)])
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
  cambios <- cambios_reactive()
  cambios_actualizados <- c(cambios, changes)
  cambios_reactive(cambios_actualizados)
  if (!is.null(changes)) {
    shinyjs::hide("volver")
    shinyjs::show("guardar")
    val <- validateValue(changes, input$tabla_datos_repgrid)
    if (!val) {
      xi <- changes[[1]][[1]]
      yi <- changes[[1]][[2]]
      old_v <- changes[[1]][[3]]
      # vuelvo a poner el ultimo valor y luego elimino su instancia de la variable reactiva
      cambios_reactive(head(cambios_reactive(), -1))
      tabla_original <- hot_to_r(input$tabla_datos_repgrid) 
      tabla_original[xi+1, yi+1] <- old_v
      tabla_manipulable(tabla_original)

      output$tabla_datos_repgrid <- renderRHandsontable({
        rhandsontable(tabla_original, rowHeaders=NULL) %>%
          hot_table(highlightCol = TRUE, highlightRow = TRUE, stretchH="all") %>%
          hot_cols(fixedColumnsLeft = 1) %>%
          hot_col(col = seq(1, session$userData$num_col_repgrid - 1))%>%
          hot_context_menu(allowRowEdit=FALSE, allowColEdit=FALSE)
      })

    } else if (!is.null(session$userData$datos_repgrid)) {
      tabla_manipulable(hot_to_r(input$tabla_datos_repgrid))
    }
  }
})

## /NEW ###################################################################

output$bert <- renderPlot({
    if (!is.null(session$userData$datos_repgrid)) {
      bertin(repgrid_a_mostrar(), xlim = c(.2,
   .8), ylim = c(.03, .6), margins = c(0, 1, 1), color=c("white", "#005440"), cex.elements = .9,
      cex.constructs = 1, cex.text = 1, lheight = .7, cc=session$userData$num_col_repgrid-2, col.mark.fill="#0B614B")
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


 #observeEvent(input$guardarBD, { si lo dejamos así se ejecuta 3 veces y no es correcto
 # de esta manera con un onevent solo se hace una vez y es lo correcto
  shinyjs::onclick("guardarBD", {
    if (!is.null(session$userData$datos_repgrid)) {
      con <- establishDBConnection()
      comentarios <- DBI::dbGetQuery(con, sprintf("SELECT distinct(comentarios) FROM repgrid_xlsx where id=%d", session$userData$id_repgrid))
      DBI::dbDisconnect(con)
      coment <- comentarios$comentarios
      if(is.na(coment)){
        coment <- ""
      }
      showModal(modalDialog(
          title = i18n$t("Anotaciones"),
          sprintf("¿Desea añadir algún comentario para la simulación de %s antes de guardarla?", nombrePaciente()),
          textAreaInput("anotacionesSimulacion_rep", i18n$t("Anotaciones:"), coment),
          footer = tagList(
            modalButton("Cancelar"),
            actionButton("confirmarGuardadoSimulacion_rep", i18n$t("Guardar simulación"), status ="success", icon = icon("check"))
          )
      ))
    }
  })

  shinyjs::onclick("confirmarGuardadoSimulacion_rep", {
    removeModal()
    if (!is.null(session$userData$datos_repgrid)) {
          anotaciones <- input$anotacionesSimulacion_rep
          con <- establishDBConnection()
          #gestionar los cambios y guardarlos directamente en la bd
          cambios <- cambios_reactive()
          for(changes in cambios){
            x <- as.numeric(changes[1]) + 2 # ajustamos las coordenadas para la bd
            y <- as.numeric(changes[2]) + 1 # ajustamos ...
            old_v <- as.character(changes[3]) #ajustamos los numeros a texto como esta en la bd
            new_v <- as.character(changes[4])

            query <- sprintf("UPDATE repgrid_xlsx SET valor='%s' WHERE fila = %d and columna = %d and fk_paciente = %d and fecha_registro = '%s'", 
                        new_v, x, y, session$userData$id_paciente, session$userData$fecha_repgrid)
            DBI::dbExecute(con, query)
          }
          query_coment <- sprintf("UPDATE repgrid_xlsx SET comentarios='%s' WHERE id=%d", anotaciones, session$userData$id_repgrid)
          DBI::dbExecute(con, query_coment)
          showNotification(
              ui = i18n$t("Los datos se han guardado correctamente en la base de datos."),
              type = "message",
              duration = 3
            ) 
          DBI::dbDisconnect(con)
      }
  })


  observeEvent(input$editar, {
    if (!is.null(session$userData$datos_repgrid)) {
      # Ocultar el botón "Editar" y mostrar el botón "Guardar"
      shinyjs::hide("editar")
      shinyjs::show("volver")
      shinyjs::hide("guardarBD")
      shinyjs::show("reiniciar")
      shinyjs::hide("guardarComo")
      shinyjs::hide("exportar")
      # Cambiar a modo de edición
      shinyjs::hide("prueba_container")
      shinyjs::show("tabla_datos_repgrid_container")
    }
  })

  observeEvent(input$volver,{
      shinyjs::hide("volver")
      shinyjs::show("editar")
      shinyjs::hide("guardar")
      shinyjs::show("guardarBD")
      shinyjs::hide("reiniciar")
      shinyjs::show("guardarComo")
      shinyjs::show("exportar")
      # Cambiar a modo de tabla
      shinyjs::show("prueba_container")
      shinyjs::hide("tabla_datos_repgrid_container")
  })

  observeEvent(input$reiniciar, {
    print("reiniciar")
    if (!is.null(session$userData$datos_repgrid)) {

        shinyjs::show("volver")
        shinyjs::hide("guardar") # esto para que no explote
        tabla_manipulable(tabla_final)

        tabla_final <- tabla_manipulable()
        print("tabla_final: ")
        my_dataframe <-tabla_final

        # Create a temporary file
        temp_file_rep <- tempfile(fileext = ".xlsx")
        on.exit(unlink(temp_file_rep))

        # Write the dataframe to the temporary file
        OpenRepGrid::saveAsExcel(session$userData$datos_repgrid, temp_file_rep)
        print(paste("Temporary file saved at: ", temp_file_rep))

        # Check if the file exists and is not empty
        if (file.exists(temp_file_rep) && file.size(temp_file_rep) > 0) {
            # Read the data from the temporary file
            df_read <- read.xlsx(temp_file_rep)
            # Print the data
            print(df_read)

            # Check if df_read is not NULL or empty
            if (!is.null(df_read) && nrow(df_read) > 0) {
                # Create a repgrid object
                my_repgrid <- df_read

                print(my_repgrid)

                repgrid_a_mostrar(session$userData$datos_repgrid)
                session$userData$datos_repgrid <- repgrid_a_mostrar()
                session$userData$datos_to_table<- my_repgrid 
            } else {
                print("Error: df_read is NULL or empty.")
            }
        } else {
            print("Error: The temporary file does not exist or is empty.")
        }
        file.remove(temp_file_rep)
    }
})

  observeEvent(input$guardar, {
    if (!is.null(session$userData$datos_repgrid)) {
        tabla_final <- tabla_manipulable()
        my_dataframe <-tabla_final

        # Create a temporary file
        temp_file_rep <- tempfile(fileext = ".xlsx")
        on.exit(unlink(temp_file_rep))
        # Write the dataframe to the temporary file
        write.xlsx(my_dataframe, temp_file_rep)
        print(paste("Temporary file saved at: ", temp_file_rep))

        # Check if the file exists and is not empty
        if (file.exists(temp_file_rep) && file.size(temp_file_rep) > 0) {
          # Read the data from the temporary file
          df_read <- OpenRepGrid::importExcel(temp_file_rep)

          # Print the data
          print(df_read)

          # Check if df_read is not NULL or empty
          if (!is.null(df_read) && nrow(df_read) > 0) {
            # Create a repgrid object
            my_repgrid <- alignByIdeal(df_read, ncol(df_read))
            print(my_repgrid)

            repgrid_a_mostrar(my_repgrid)
            session$userData$datos_repgrid <- repgrid_a_mostrar()
            session$userData$datos_to_table<- tabla_final

            # Hide the "Save" button and show the "Edit" button
            shinyjs::hide("reiniciar")
            shinyjs::show("editar")
            shinyjs::hide("guardar")
            shinyjs::hide("volver")
            shinyjs::show("guardarBD")
            shinyjs::show("guardarComo")
            shinyjs::show("exportar")
            # Switch to viewing mode
            shinyjs::hide("tabla_datos_repgrid_container")
            shinyjs::show("prueba_container")
          } else {
              message("Error: df_read is NULL or empty.")
          }
        } else {
            message("Error: The temporary file does not exist or is empty.")
        }
        file.remove(temp_file_rep)
    }
    repgrid_analisis_server(input,output,session)
  })

  shinyjs::onclick("guardarComo", {
    if (!is.null(session$userData$datos_repgrid)) {
      con <- establishDBConnection()
      comentarios <- DBI::dbGetQuery(con, sprintf("SELECT distinct(comentarios) FROM repgrid_xlsx where id=%d", session$userData$id_repgrid))
      DBI::dbDisconnect(con)
      coment <- comentarios$comentarios
      if(is.na(coment)){
        coment <- ""
      }
      showModal(modalDialog(
          title = i18n$t("Anotaciones"),
          sprintf("¿Desea añadir algún comentario para la simulación de %s antes de guardarla?", nombrePaciente()),
          textAreaInput("anotacionesGuardarComoSimulacion_rep", i18n$t("Anotaciones:"), coment),
          footer = tagList(
            modalButton("Cancelar"),
            actionButton("confirmarGuardadoComoSimulacion_rep", i18n$t("Guardar simulación"), status ="success", icon = icon("check"))
          )
      ))
    }
  })

  shinyjs::onclick("confirmarGuardadoComoSimulacion_rep", {
    removeModal()
    if (!is.null(session$userData$datos_repgrid)) {
        tabla_final <- tabla_manipulable()
        my_dataframe <-tabla_final
        anotaciones <- input$anotacionesGuardarComoSimulacion_rep
        # Create a temporary file
        temp_file_rep <- tempfile(fileext = ".xlsx")
        on.exit(unlink(temp_file_rep))
        # Write the dataframe to the temporary file
        write.xlsx(my_dataframe, temp_file_rep)
        excel <- read.xlsx(temp_file_rep, colNames=FALSE)
        # Check if the file exists and is not empty
        if (file.exists(temp_file_rep) && file.size(temp_file_rep) > 0) {
          file.remove(temp_file_rep)
          # Check if df_read is not NULL or empty
          fecha <- codificar_excel_BD(excel, "repgrid_xlsx", session$userData$id_paciente)
          # consigo el id para actualizar los comentarios 
          con <- establishDBConnection()
          id <- DBI::dbGetQuery(con, sprintf("SELECT distinct(id) from repgrid_xlsx where fecha_registro='%s' and fk_paciente=%d", fecha, session$userData$id_paciente))
          id <- as.integer(id)
          
          # le actualizo tambien los controles 
          if(!is.null(id)){
            query_wp <- sprintf("UPDATE repgrid_xlsx SET comentarios='%s' WHERE id=%d", anotaciones, id)
            DBI::dbExecute(con, query_wp)
          }
          DBI::dbDisconnect(con)

          showNotification(
              ui = sprintf("Nueva simulación de %s guardada con éxito. Diríjase a la página de pacientes para visualizarla.", nombrePaciente()),
              type = "message",
              duration = 8
          ) 
        }
    }
  })


temporal <- NULL  # Defino temporal en un alcance superior
output$exportar <- downloadHandler(
  filename = function() {
    fecha <- gsub(" ", "_", session$userData$fecha_repgrid)
    nombre_temporal <- paste("Repgrid_", nombrePaciente(), "_", fecha, ".xlsx", sep="", collapse="")
    temporal <- file.path(tempdir(), nombre_temporal)
    tabla_final <- tabla_manipulable()
    my_dataframe <- tabla_final
    # Write the dataframe to the temporary file
    write.xlsx(my_dataframe, temporal)
    return(nombre_temporal)
  },
  content = function(file) {
    fecha <- gsub(" ", "_", session$userData$fecha_repgrid)
    nombre_temporal <- paste("Repgrid_", nombrePaciente(), "_", fecha, ".xlsx", sep="", collapse="")
    temporal <- file.path(tempdir(), nombre_temporal)
    file.copy(temporal, file)
    file.remove(temporal)  # Elimina el archivo temporal después de descargarlo
  }
)



  observeEvent(input$tabs_rep, {
    
    if (input$tabs_rep == "Data") {
      print("Has seleccionado la pestaña Data")
    } else if (input$tabs_rep == "Results") {
      print("Has seleccionado la pestaña Results")
      print("showing the results:")
      repgrid_analisis_server(input,output,session)
    }
      
    })

    observeEvent(input$importar_page, {
    # Navega a la página de creación de un nuevo análisis de rejilla
    runjs("window.location.href = '/#!/import';")
  })

  observeEvent(input$patients_page, {
    # Navega a la página de creación de un nuevo análisis de rejilla
    runjs("window.location.href = '/#!/patient';")
  })


  repgrid_analisis_server(input,output,session)
}

