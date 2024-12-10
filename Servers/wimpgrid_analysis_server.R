wimpgrid_analysis_server <- function(input, output, session) {

  rol <- session$userData$rol
  if(!is.null(rol)){
    if(rol == "usuario_gratis"){
      shinyjs::disable("guardarComo_w")
    }
    if(rol == "usuario_demo"){
      shinyjs::disable("guardarComo_w")
      shinyjs::disable("guardarBD_w")
    }
  }

observeEvent(input$graph_selector_visualizacion, {

  seleccion <- input$graph_selector_visualizacion

  if(seleccion == 'wimpindices' || seleccion == 'índices de Wimp'){
    runjs("document.exitFullscreen();")
     runjs("
     
    if ($('#wg-vis-content').hasClass('fullscreen-style') || $('#wg-lab-content').hasClass('fullscreen-style')) {
    $('#wg-vis-content').removeClass('fullscreen-style');
    $('#wg-lab-content').removeClass('fullscreen-style');

    $('#mb_exit_fs_1').addClass('hidden');
    $('#mb_enter_fs_1').removeClass('hidden');

    $('#mb_exit_fs_3').addClass('hidden');
    $('#mb_enter_fs_3').removeClass('hidden');

    $('#mb_exit_fs_4').addClass('hidden');
    $('#mb_enter_fs_4').removeClass('hidden');

    $('#mb_exit_fs_5').addClass('hidden');
    $('#mb_enter_fs_5').removeClass('hidden');
    }")
  }
})

shinyjs::hide("context-wg-home")
  onevent("click", "tooltip-wg-home", shinyjs::show("context-wg-home"))
  onevent("click", "exit-wg-tooltip", shinyjs::hide("context-wg-home"))

shinyjs::hide("context-wg-2-home")
  onevent("click", "tooltip-wg-2-home", shinyjs::show("context-wg-2-home"))
  onevent("click", "exit-wg-2-tooltip", shinyjs::hide("context-wg-2-home"))

shinyjs::hide("context-wg-3-home")
  onevent("click", "tooltip-wg-3-home", shinyjs::show("context-wg-3-home"))
  onevent("click", "exit-wg-3-tooltip", shinyjs::hide("context-wg-3-home"))



        
#Ver y Ocultar panel de control izquierdo
runjs("

//Visualizacion ---------------------------------------------------

$('#exit-controls-vis').on('click', function (){

  $('.graphics-vis').addClass('mw-100');
  $('.graphics-vis').addClass('flex-bs-100');

  $('#controls-panel-vis').removeClass('anim-fade-in');
  $('#controls-panel-vis').addClass('anim-fade-out');

  $('#open-controls-vis').removeClass('anim-fade-out');
  $('#open-controls-vis').addClass('anim-fade-in');

  $('#open-controls-vis-in').removeClass('anim-fade-out');
  $('#open-controls-vis-in').addClass('anim-fade-in');

});

//Autodigrafo e ideal ---------------------------------------------------

$('#open-controls-vis').on('click', function (){

  $('.graphics-vis').removeClass('mw-100');
  $('.graphics-vis').removeClass('flex-bs-100');

  $('#controls-panel-vis').removeClass('anim-fade-out');
  $('#controls-panel-vis').addClass('anim-fade-in');

  $('#open-controls-vis').addClass('anim-fade-out');
  $('#open-controls-vis').removeClass('anim-fade-in');

});

//Indices ---------------------------------------------------

$('#open-controls-vis-in').on('click', function (){

  $('.graphics-vis').removeClass('mw-100');
  $('.graphics-vis').removeClass('flex-bs-100');

  $('#controls-panel-vis').removeClass('anim-fade-out');
  $('#controls-panel-vis').addClass('anim-fade-in');

  $('#open-controls-vis-in').addClass('anim-fade-out');
  $('#open-controls-vis-in').removeClass('anim-fade-in');

});

//Laboratorio ---------------------------------------------------

$('#exit-controls-lab').on('click', function (){

  $('#graphics-lab').addClass('mw-100');
  $('#graphics-lab').addClass('flex-bs-100');

  $('#controls-panel-lab').removeClass('anim-fade-in');
  $('#controls-panel-lab').addClass('anim-fade-out');

  $('#open-controls-lab').removeClass('anim-fade-out');
  $('#open-controls-lab').addClass('anim-fade-in');
  
  $('#open-controls-lab-pcsd').removeClass('anim-fade-out');
  $('#open-controls-lab-pcsd').addClass('anim-fade-in');

  $('#open-controls-lab-in').removeClass('anim-fade-out');
  $('#open-controls-lab-in').addClass('anim-fade-in');
});

//Simdigrafo ---------------------------------------------------

$('#open-controls-lab').on('click', function (){

  $('#graphics-lab').removeClass('mw-100');
  $('#graphics-lab').removeClass('flex-bs-100');

  $('#controls-panel-lab').removeClass('anim-fade-out');
  $('#controls-panel-lab').addClass('anim-fade-in');

  $('#open-controls-lab').addClass('anim-fade-out');
  $('#open-controls-lab').removeClass('anim-fade-in');

});

//pcsd ---------------------------------------------------

$('#open-controls-lab-pcsd').on('click', function (){

  $('#graphics-lab').removeClass('mw-100');
  $('#graphics-lab').removeClass('flex-bs-100');

  $('#controls-panel-lab').removeClass('anim-fade-out');
  $('#controls-panel-lab').addClass('anim-fade-in');

  $('#open-controls-lab-pcsd').addClass('anim-fade-out');
  $('#open-controls-lab-pcsd').removeClass('anim-fade-in');

});

//pcsd indices ---------------------------------------------------

$('#open-controls-lab-in').on('click', function (){

  $('#graphics-lab').removeClass('mw-100');
  $('#graphics-lab').removeClass('flex-bs-100');

  $('#controls-panel-lab').removeClass('anim-fade-out');
  $('#controls-panel-lab').addClass('anim-fade-in');

  $('#open-controls-lab-in').addClass('anim-fade-out');
  $('#open-controls-lab-in').removeClass('anim-fade-in');

});

")
#Control panel graphics

shinyjs::hide("open-controls-vis")
shinyjs::hide("open-controls-vis-in")
shinyjs::hide("open-controls-lab")
shinyjs::hide("open-controls-lab-pcsd")
shinyjs::hide("open-controls-lab-in")

#controles de pestaña visualizacion ----------------------------------

  onevent("click", "exit-controls-vis", {
  
    shinyjs::show("open-controls-vis") 
    shinyjs::show("open-controls-vis-in")

    shinyjs::hide("controls-panel-vis")
    
  }, add = TRUE)

  #autodigrafio e ideal

  onevent("click", "open-controls-vis", {
  
    shinyjs::hide("open-controls-vis")
    shinyjs::hide("open-controls-vis-in")

    shinyjs::show("controls-panel-vis")
    
  }, add = TRUE)

#indices

shinyjs::hide("open-controls-vis-in")

  onevent("click", "open-controls-vis-in", {
  
    shinyjs::hide("open-controls-vis-in")
    shinyjs::hide("open-controls-vis")

    shinyjs::show("controls-panel-vis")
    
  }, add = TRUE)


#controles de pestaña laboratorio --------------------------------------

onevent("click", "exit-controls-lab", {
  
    shinyjs::show("open-controls-lab-pcsd")
    shinyjs::show("open-controls-lab-in")
    shinyjs::show("open-controls-lab")

    delay(100, shinyjs::hide("controls-panel-lab"))
    
  }, add = TRUE)

  #graph

  onevent("click", "open-controls-lab", {
  
    shinyjs::hide("open-controls-lab")
    shinyjs::hide("open-controls-lab-in")
    shinyjs::hide("open-controls-lab-pcsd")

    shinyjs::show("controls-panel-lab")
    
  }, add = TRUE)

#pcsd

  onevent("click", "open-controls-lab-pcsd", {
  
    shinyjs::hide("open-controls-lab")
    shinyjs::hide("open-controls-lab-in")
    shinyjs::hide("open-controls-lab-pcsd")

    shinyjs::show("controls-panel-lab")
    
  }, add = TRUE)

#pcsd indices

  onevent("click", "open-controls-lab-in", {
  
    shinyjs::hide("open-controls-lab")
    shinyjs::hide("open-controls-lab-in")
    shinyjs::hide("open-controls-lab-pcsd")

    shinyjs::show("controls-panel-lab")
    
  }, add = TRUE)





# Lógica para la pestaña "Datos"

 
  observeEvent(input$importar_page_d, {

    # Navega a la página de creación de un nuevo análisis de rejilla

    # route_link("nombre_de_la_pagina_de_creacion")

    runjs("window.location.href = '/#!/import';")
  })

  observeEvent(input$patients_page_d, {
    # Navega a la página de creación de un nuevo análisis de rejilla
    runjs("window.location.href = '/#!/patient';")
  })

  # Lógica para la pestaña "Visualización"

  observeEvent(input$importar_page_v, {

    # Navega a la página de creación de un nuevo análisis de rejilla

    # route_link("nombre_de_la_pagina_de_creacion")

    runjs("window.location.href = '/#!/import';")

  })
  
  observeEvent(input$patients_page_v, {
    # Navega a la página de creación de un nuevo análisis de rejilla
    runjs("window.location.href = '/#!/patient';")
  })

  # Lógica para la pestaña "Laboratorio"

  observeEvent(input$importar_page_l, {

    # Navega a la página de creación de un nuevo análisis de rejilla

    # route_link("nombre_de_la_pagina_de_creacion")

    runjs("window.location.href = '/#!/import';")

  })

  observeEvent(input$patients_page_l, {
    # Navega a la página de creación de un nuevo análisis de rejilla
    runjs("window.location.href = '/#!/patient';")
  })

  observeEvent(input$exit_fs, {
    # Navega a la página de creación de un nuevo análisis de rejilla
        shinyjs::hide("exit_fs")
  })

   observeEvent(input$enter_fs, {
    # Navega a la página de creación de un nuevo análisis de rejilla
        shinyjs::show("exit_fs")
  })

  print("Wimpgrid")

  print(session$userData$datos_wimpgrid)

  if (is.null(session$userData$datos_wimpgrid)) {

    show("id_warn")

    show("vis_warn")

    show("lab_warn")

    repgrid_aux <- 0

    tabla_aux <- 0

    hide("wg-data-content")
    hide("wg-vis-content")
    hide("wg-lab-content")

  }else{

    hide("id_warn")

    hide("vis_warn")

    hide("lab_warn")

    repgrid_aux <- session$userData$datos_wimpgrid

    tabla_aux <- session$userData$datos_to_table_w

    show("wg-data-content")
    show("wg-vis-content")
    show("wg-lab-content")
  }

  # cargo los datos de weight matrix para que no se actualicen al tocar yo-actual
  if (!is.null(session$userData$datos_wimpgrid)) {
    message("entro en matrix_data")
    matrix_data <- session$userData$datos_wimpgrid[["scores"]][["weights"]]


  }


  dataaa_w <-  reactiveVal(session$userData$datos_wimpgrid)

  permitirEjecucionYoActual <<- FALSE


  tabla_manipulable_w <- reactiveVal(tabla_aux)

  #tabla_manipulable_w <- session$userData$datos_to_table

  tabla_final <- tabla_aux

  repgrid_inicial <- reactiveVal(repgrid_aux)

  wimpgrid_a_mostrar <- reactiveVal(repgrid_aux)
  nombrePaciente <- reactiveVal()

  output$titulo_wimpgrid <- renderText({
    con <- establishDBConnection()
    nombre <- DBI::dbGetQuery(con, sprintf("SELECT nombre from paciente WHERE id = %d", session$userData$id_paciente))
    lang <- i18n$get_translation_language()
    nombrePaciente(nombre)
    DBI::dbDisconnect(con)
    fecha <- session$userData$fecha_wimpgrid
     if (lang  == "es") {
      paste("<b>", i18n$t("Simulación de"), nombre, "</b><br><p class='desccustom-date'>📅", fecha, "</p>") 
    } else {
      paste("<b>", sprintf("%s%s", nombre, i18n$t("Simulación de")), "</b><br><p class='desccustom-date'>📅", fecha, "</p>")
    }
  })

  output$tabla_datos_wimpgrid <- renderRHandsontable({
    if (!is.null(session$userData$datos_wimpgrid)) {
      indicess <- seq(1, session$userData$num_col_wimpgrid - 1)
      tabla <- tabla_manipulable_w()
      nombres_columnas <- colnames(tabla)
      min_val <- nombres_columnas[1]
      max_val <- nombres_columnas[length(nombres_columnas)]
      nombres <- nombres_columnas[4:length(nombres_columnas)-2]
      nombres <- strsplit(nombres, "Yo.-.Totalmente.")
      segundos_elementos <- sapply(nombres, function(x) x[2])
      lista_formateada <- lapply(segundos_elementos, function(elemento) {
        elemento <- gsub("\\.", " ", elemento)
        paste("Yo totalmente", elemento, sep = "\n ")
      })
      res <- c(min_val, lista_formateada, "Yo Ideal", max_val)

      hot_table <- rhandsontable(tabla_manipulable_w(), colHeaders=res, rowHeaders=NULL) %>%
          hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
          hot_col(col = indicess, colWidths=120) %>%
          hot_context_menu(allowRowEdit=FALSE, allowColEdit=FALSE)
          
      hot_table

    }

  })

  

  ## NEW ######################################################
  cambios_reactive <- reactiveVal(numeric(0))
  

  validateValue <- function(changes, tabla) {

  

    new_v = changes[[1]][[4]]

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

  

  observeEvent(input$tabla_datos_wimpgrid, {
    changes <- input$tabla_datos_wimpgrid$changes$changes
    cambios <- cambios_reactive()
    
    if(!is.null(changes)) {
      shinyjs::hide("volver_w")
      shinyjs::show("guardar_w")
      val <- validateValue(changes, input$tabla_datos_wimpgrid)
      cambios_actualizados <- c(cambios, changes)
      cambios_reactive(cambios_actualizados)

      if(!val) {
        xi <- changes[[1]][[1]]
        yi <- changes[[1]][[2]]
        old_v <- changes[[1]][[3]]
        # vuelvo a poner el ultimo valor y luego elimino su instancia de la variable reactiva
        cambios_reactive(head(cambios_reactive(), -1))
        tabla_original <- hot_to_r(input$tabla_datos_wimpgrid)
        tabla_original[xi+1, yi+1] <- old_v
        tabla_manipulable_w(tabla_original)

        nombres_columnas <- colnames(tabla_manipulable_w())
        min_val <- nombres_columnas[1]
        max_val <- nombres_columnas[length(nombres_columnas)]
        nombres <- nombres_columnas[4:length(nombres_columnas)-2]
        nombres <- strsplit(nombres, "Yo.-.Totalmente.")
        segundos_elementos <- sapply(nombres, function(x) x[2])
        lista_formateada <- lapply(segundos_elementos, function(elemento) {
          elemento <- gsub("\\.", " ", elemento)
          paste("Yo totalmente", elemento, sep = "\n ")
        })
        res <- c(min_val, lista_formateada, "Yo Ideal", max_val)
        output$tabla_datos_wimpgrid <- renderRHandsontable({
          rhandsontable(tabla_original, colHeaders=res, rowHeaders=NULL) %>%
            hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
            hot_col(col = seq(1, session$userData$num_col_wimpgrid - 1), colWidths=120) %>%
            hot_context_menu(allowRowEdit=FALSE, allowColEdit=FALSE)
        })
      } else if (!is.null(session$userData$datos_wimpgrid)) {
        tabla_manipulable_w(hot_to_r(input$tabla_datos_wimpgrid))
      }

    }

  })
  

  output$bert_w <- renderPlot({
    if (!is.null(session$userData$datos_wimpgrid)) {
      bertin(wimpgrid_a_mostrar()$openrepgrid , xlim = c(.2,
    .8), ylim = c(.03, .6), margins = c(0, 1, 1), color=c("white", "#dfb639"), cex.elements = .9,
        cex.constructs = 1, cex.text = 1, lheight = .7, cc=session$userData$num_col_wimpgrid-2, col.mark.fill="#DBA901")
      
    }

  })


  observeEvent(input$editar_w, {
      if (!is.null(session$userData$datos_wimpgrid)) {
      # Ocultar el botón "Editar" y mostrar el botón "Guardar"
      shinyjs::hide("botones_izquierda_w")
      shinyjs::hide("editar_w")
      shinyjs::hide("guardarBD_w")
      shinyjs::show("volver_w")
      shinyjs::show("reiniciar_w")
      shinyjs::hide("guardarComo_w")
      shinyjs::hide("exportar_w")
      # Cambiar a modo de edición
      shinyjs::hide("prueba_container_w")
      shinyjs::show("tabla_datos_wimpgrid_container")
      }
    })

    observeEvent(input$volver_w,{
        shinyjs::hide("volver_w")
        shinyjs::show("editar_w")
        shinyjs::hide("guardar_w")
        shinyjs::show("guardarBD_w")
        shinyjs::hide("reiniciar_w")
        shinyjs::show("guardarComo_w")
        shinyjs::show("exportar_w")
        shinyjs::show("botones_izquierda_w")
        # Cambiar a modo de tabla
        shinyjs::show("prueba_container_w")
        shinyjs::hide("tabla_datos_wimpgrid_container")
    })


  observeEvent(input$reiniciar_w, {

      if (!is.null(session$userData$datos_wimpgrid)) {

        tabla_manipulable_w(tabla_final)

        #session$userData$datos_wimpgrid <- tabla_manipulable()

        #session$userData$datos_to_table<- tabla_final
        shinyjs::show("volver_w")
        shinyjs::hide("guardar_w") # para que no explote
        tabla_final <- tabla_manipulable_w()
        print("tabla_final: ")
        my_dataframe <-tabla_final
        # Create a temporary file
        temp_file <- tempfile(fileext = ".xlsx")
        on.exit(unlink(temp_file))
        # Write the dataframe to the temporary file
        OpenRepGrid::saveAsExcel(session$userData$datos_wimpgrid$openrepgrid, temp_file)

        print(paste("Temporary file saved at: ", temp_file))
        if (file.exists(temp_file) && file.size(temp_file) > 0) {
          # Read the data from the temporary file
          df_read <- read.xlsx(temp_file)
          # Print the data
          print(df_read)
          if (!is.null(df_read) && nrow(df_read) > 0) {
            my_wimpgrid <- df_read
            wimpgrid_a_mostrar(my_wimpgrid)
            session$userData$datos_wimpgrid <- wimpgrid_a_mostrar()
            session$userData$datos_to_table_w<- my_wimpgrid
          }
        }
        file.remove(temp_file)
  }})

  

  observeEvent(input$guardar_w, {
      if (!is.null(session$userData$datos_wimpgrid)) {

        tabla_final <- tabla_manipulable_w()

        print("tabla_final: ")

        my_dataframe <-tabla_final
        # Create a temporary file
        temp_file <- tempfile(fileext = ".xlsx")
        on.exit(unlink(temp_file))
        # Write the dataframe to the temporary file

        write.xlsx(my_dataframe, temp_file)

        print(paste("Temporary file saved at: ", temp_file))

        df_read <- importwimp(temp_file)
        my_wimpgrid <- df_read
        print(my_wimpgrid)
        wimpgrid_a_mostrar(my_wimpgrid)
        session$userData$datos_wimpgrid <- wimpgrid_a_mostrar()
        session$userData$datos_to_table_w<- tabla_final

        # Ocultar el botón "Guardar" y mostrar el botón "Editar"
        shinyjs::hide("reiniciar_w")
        shinyjs::show("editar_w")
        shinyjs::hide("guardar_w")
        shinyjs::hide("volver_w")
        shinyjs::show("guardarBD_w")
        shinyjs::show("guardarComo_w")
        shinyjs::show("exportar_w")
        shinyjs::show("botones_izquierda_w")
        # Cambiar a modo de visualización

        shinyjs::hide("tabla_datos_wimpgrid_container")

        shinyjs::show("prueba_container_w")
        file.remove(temp_file)
        dataaa_w(df_read)

      }

  })

  temporal <- NULL  # Define temporal en un alcance superior
  output$exportar_w <- downloadHandler(
    filename = function() {
      fecha <- gsub(" ", "_", session$userData$fecha_wimpgrid)
      nombre_temporal <- paste("Wimpgrid_", nombrePaciente(), "_", fecha, ".xlsx", sep="", collapse="")
      temporal <- file.path(tempdir(), nombre_temporal)
      tabla_final <- tabla_manipulable_w()
      my_dataframe <- tabla_final
      # Write the dataframe to the temporary file
      write.xlsx(my_dataframe, temporal)
      return(nombre_temporal)
    },
    content = function(file) {
      fecha <- gsub(" ", "_", session$userData$fecha_wimpgrid)
      nombre_temporal <- paste("Wimpgrid_", nombrePaciente(), "_", fecha, ".xlsx", sep="", collapse="")
      temporal <- file.path(tempdir(), nombre_temporal)
      file.copy(temporal, file)
      file.remove(temporal)  # Elimina el archivo temporal después de descargarlo
    }
  )


    shinyjs::onclick("guardarComo_w", {
      if (!is.null(session$userData$datos_wimpgrid)) {
        con <- establishDBConnection()
        comentarios <- DBI::dbGetQuery(con, sprintf("SELECT comentarios FROM wimpgrid_params where fk_wimpgrid=%d", session$userData$id_wimpgrid))
        DBI::dbDisconnect(con)
        showModal(modalDialog(
            title = i18n$t("Anotaciones"),
            sprintf("¿Desea añadir algún comentario para la simulación de %s antes de guardarla?", nombrePaciente()),
            textAreaInput("anotacionesGuardarComoSimulacion", i18n$t("Anotaciones:"), value=as.character(comentarios$comentarios)),
            footer = tagList(
              modalButton("Cancelar"),
              actionButton("confirmarGuardadoComoSimulacion", i18n$t("Guardar simulación"), status ="success", icon = icon("check"))
            )
        ))
      }
    })

    shinyjs::onclick("confirmarGuardadoComoSimulacion", {
      if (!is.null(session$userData$datos_wimpgrid)) {
          removeModal()
          tabla_final <- tabla_manipulable_w()
          my_dataframe <-tabla_final
          anotaciones <- input$anotacionesGuardarComoSimulacion
          # Create a temporary file
          temp_file <- tempfile(fileext = ".xlsx")
          on.exit(unlink(temp_file))
          # Write the dataframe to the temporary file
          write.xlsx(my_dataframe, temp_file)
          excel <- read.xlsx(temp_file, colNames=FALSE)
          # Check if the file exists and is not empty
          if (file.exists(temp_file) && file.size(temp_file) > 0) {
            file.remove(temp_file)
            #creo la wimpgrid nueva
            fecha <- codificar_excel_BD(excel, "wimpgrid_xlsx", session$userData$id_paciente)
            con <- establishDBConnection()
            # consigo el id de la nueva wimpgrid
            id <- DBI::dbGetQuery(con, sprintf("SELECT distinct(id) from wimpgrid_xlsx where fecha_registro='%s' and fk_paciente=%d", fecha, session$userData$id_paciente))
            id <- as.integer(id)
            
            # le actualizo tambien los controles 
            if(!is.null(id)){
              actualizar_controles_bd(id)
              query_wp <- sprintf("UPDATE wimpgrid_params SET comentarios='%s' WHERE fk_wimpgrid=%d", anotaciones, id)
              DBI::dbExecute(con, query_wp)
              showNotification(
                  ui = sprintf("Nueva simulación de %s guardada con éxito. Diríjase a la página de pacientes para visualizarla.", nombrePaciente()),
                  type = "message",
                  duration = 8
              ) 
            }
            DBI::dbDisconnect(con)
          }
      }
    })



  #scn <- scenariomatrix(dataaa_w(),c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))

  #VARIABLES OF THE FORM

  

  selfdigraph_layout <- reactiveVal("circle")

  selfdigraph_vertex_size <- reactiveVal(1)

  selfdigraph_edge_width <- reactiveVal(1)

  selfdigraph_color <- reactiveVal("red/green")

  

  idealdigraph_inc <- reactiveVal(FALSE)

  idealdigraph_layout <- reactiveVal("circle")



  idealdigraph_color <- reactiveVal("red/green")

  

  observeEvent(input$tab_visualizacion, {

  

  })

  

  # Observer event para el input layout de selfdigraph

  observeEvent(input$selfdigraph_layout, {

    selfdigraph_layout(input$selfdigraph_layout)

  })

  

  # Observer event para el input vertex.size de selfdigraph

  observeEvent(input$selfdigraph_vertex_size, {

    selfdigraph_vertex_size(input$selfdigraph_vertex_size)

  })

  

  # Observer event para el input edge.width de selfdigraph

  observeEvent(input$selfdigraph_edge_width, {

    selfdigraph_edge_width(input$selfdigraph_edge_width)

  })

  

  # Observer event para el input color de selfdigraph

  observeEvent(input$selfdigraph_color, {

    selfdigraph_color(input$selfdigraph_color)

  })

  

  # Observer event para el input inc de idealdigraph

  observeEvent(input$idealdigraph_inc, {

    idealdigraph_inc(input$idealdigraph_inc)

  })

  

  # Observer event para el input layout de idealdigraph

  observeEvent(input$idealdigraph_layout, {

    idealdigraph_layout(input$idealdigraph_layout)

  })
  

  # Observer event para el input color de idealdigraph

  observeEvent(input$idealdigraph_color, {

    idealdigraph_color(input$idealdigraph_color)

  })

  

  # Lógica para mostrar los resultados de selfdigraph()

  observeEvent(input$graph_selector_visualizacion, {

    graph <- input$graph_selector_visualizacion

  })

 

# Definir la lógica del servidor para la aplicación

 

 

  generate_graph <- function(){
    # Verificar que input$graph_selector_visualizacion no es NULL
    req(input$graph_selector_visualizacion)
    # Asignar el input a una variable

    graph <- input$graph_selector_visualizacion
    graph2 <- NULL

    # Dependiendo de la selección del usuario, dibuja el gráfico correspondiente

    if (graph == "autodigrafo" || graph=="selfdigraph") {
      if(i18n$get_translation_language()=="es") {
        #graph2 <- selfdigraph(dataaa_w(), layout = translate_word("en",selfdigraph_layout()), vertex.size = selfdigraph_vertex_size(),edge.width = selfdigraph_edge_width(), color = translate_word("en",selfdigraph_color())) 
        graph2 <- digraph(dataaa_w(), layout = translate_word("en",selfdigraph_layout()), color = translate_word("en",selfdigraph_color()))

      }
      else {
        print("en")
        #graph2 <- selfdigraph(dataaa_w(), layout = selfdigraph_layout(), vertex.size = selfdigraph_vertex_size(),edge.width = selfdigraph_edge_width(), color = selfdigraph_color())
        graph2 <- digraph(dataaa_w(), layout = selfdigraph_layout(), color = selfdigraph_color())
      
      }

    } else if (graph == i18n$t("digrafo del ideal")) {

      if(i18n$get_translation_language()=="es")

      {
        graph2 <- idealdigraph.vis(wimp = dataaa_w(), inc = idealdigraph_inc(), layout = translate_word("en",idealdigraph_layout()), color = translate_word("en",idealdigraph_color()))

      } else {
        #graph2 <- idealdigraph(dataaa_w(), inc = idealdigraph_inc(), layout = idealdigraph_layout(), vertex.size = idealdigraph_vertex_size(), edge.width = idealdigraph_edge_width(),color = idealdigraph_color())
        graph2 <- idealdigraph.vis(wimp = dataaa_w(), inc = idealdigraph_inc(), layout = idealdigraph_layout(), color = idealdigraph_color())

      }

    } else if (graph == i18n$t("índices de Wimp")) {

      print("wimpindices")

      # Get column names

      column_names <- names(wimpindices(dataaa_w()))
      # Print column names

      cat("Columns:", paste(column_names, collapse = ", "))

      print(wimpindices(dataaa_w())[["distance"]])

          #wimpindices(dataaa_w())

    }

  

    print(graph2)

  

    return(graph2)

  }

  

  

  output$graph_output_visualizacion <- renderUI({

    generate_graph()

  })

  

  output$btn_download_visualizacion <- downloadHandler(

    filename = function() {

      gsub(" ", "", paste("grafico_visualizacion_",input$graph_selector_visualizacion,".html"))

    },

    content = function(file) {

  

      print("Botón de descarga presionado")

      graph <- input$graph_selector_visualizacion 

      if(graph == i18n$t("autodigrafo")) {

        if(i18n$get_translation_language()=="es") {

          saveWidget(widget = digraph(dataaa_w(), layout = translate_word("en",selfdigraph_layout()), color = translate_word("en",selfdigraph_color())), file = file, selfcontained = TRUE)

        } else {

          saveWidget(widget = digraph(dataaa_w(), layout = selfdigraph_layout(), color = selfdigraph_color()), file = file, selfcontained = TRUE)

        }

      } else if(graph == i18n$t("digrafo del ideal")) {

        if(i18n$get_translation_language()=="es") {

          saveWidget(widget = idealdigraph.vis(wimp = dataaa_w(), inc = idealdigraph_inc(), layout = translate_word("en",idealdigraph_layout()), color = translate_word("en",idealdigraph_color())), file = file, selfcontained = TRUE)

        } else {

          saveWidget(widget = idealdigraph.vis(wimp = dataaa_w(), inc = idealdigraph_inc(), layout = idealdigraph_layout(), color = idealdigraph_color()), file = file, selfcontained = TRUE)

        }

      }  

    

      #grDevices::dev.off()

      #file.copy("Rplot001.png", file)  # Copiar el archivo temporal a la ubicación deseada

      #file.remove("Rplot001.png")  # Eliminar el archivo temporal

      #ggsave(file, plot = graph, width = 1200, height = 800, units = "px", dpi = 100)

    }

  )

  max_v <- session$userData$num_col_wimpgrid - 3

  max_v <- max(1, max_v)

  v <- rep(0, max_v)

  df_actual <- reactiveVal(as.data.frame(t(v)))
  
  df_V <- reactiveVal(as.data.frame(t(v)))

  output$boton_download_laboratory <- downloadHandler(
    filename = function() {

      gsub(" ", "", paste("grafico_laboratorio_", input$graph_selector_visualizacion,".html"))

    },

    content = function(file) {

      graph <- input$graph_selector_laboratorio
      sim_stop_it <- simdigraph_stop_iter()

      if(graph == i18n$t("simdigrafo")) {

        if(i18n$get_translation_language()=="es") {
          scn <- scenariomatrix(dataaa_w(),act.vector= df_V(),infer = simdigraph_infer(),

                                thr = simdigraph_thr(), max.iter = simdigraph_max_iter(), e = simdigraph_e(),

                                stop.iter = sim_stop_it)

          widget_sim <- simdigraph.vis(scn,niter=simdigraph_niter(), layout = translate_word("en",simdigraph_layout()), color = translate_word("en",simdigraph_color()))
          saveWidget(widget = widget_sim, file = file, selfcontained = TRUE)
        } else {
          scn <- scenariomatrix(dataaa_w(),act.vector= df_V(),infer = simdigraph_infer(),

                                thr = simdigraph_thr(), max.iter = simdigraph_max_iter(), e = simdigraph_e(),

                                stop.iter = sim_stop_it)

          widget_sim_en <- simdigraph.vis(scn,niter=simdigraph_niter(), layout = simdigraph_layout(), color = simdigraph_color())
          saveWidget(widget = widget_sim_en, file = file, selfcontained = TRUE)
        }
      }
    }
  )

  

  output$dens <- renderText({
      INTe <- round(wimpindices(dataaa_w())[["density"]], 3)

      knitr::kable(INTe, col.names = "density",format = "html") %>%

      kable_styling("striped", full_width = F) %>%

      row_spec(0, bold = T) %>%

      column_spec(1, bold = T)

  })

  output$distance <- renderRHandsontable({
      # no me deja ponerlo sin decimalesS
      INTe <- wimpindices(dataaa_w())[["distance"]]
      INTe <- formatC(round(INTe, 0), format = "d", digits=0)

      #DT::datatable(INTe)
      izq <- session$userData$constructos_izq
      der <- session$userData$constructos_der
      res <- paste(izq, der, sep="/<br>")
      #colnames(INTe) <- res
      #rownames(INTe) <- res
      #data_frame <- data.frame(row_names = res, INTe)

      rhandsontable(INTe, colHeaders=res, rowHeaders=res) %>%
            hot_table(highlightCol = TRUE, highlightRow = TRUE, readOnly = TRUE) %>%
            hot_context_menu(allowRowEdit = FALSE, allowColEdit = FALSE) %>%
            hot_cols(colWidths = 130)
        
  })

  

  # Creamos las tablas dinámicas para cada subconjunto

  output$table_degree <- DT::renderDataTable({

      centrality <- wimpindices(dataaa_w())[["centrality"]]

  

      DT::datatable(centrality$degree)

    })

  

  output$table_closeness <- DT::renderDataTable({

      centrality <- wimpindices(dataaa_w())[["centrality"]]

  
      closeness <- data.frame(Closeness = round(centrality$closeness, 3))

      DT::datatable(closeness)

    })

  

  output$table_betweenness <- DT::renderDataTable({

      centrality <- wimpindices(dataaa_w())[["centrality"]]

      bt <- data.frame(Betweenness = round(centrality$betweenness, 3))

      DT::datatable(bt)

    })

  output$inconsistences <- DT::renderDataTable({

  

      INTe <- wimpindices(dataaa_w())[["inconsistences"]]

      DT::datatable(INTe)

  })

  

  # Variables reactivas para almacenar los cambios de los inputs de simdigraph
  # meter todos los valores de la simulación desde la bd o no
  
  # Nº de la iteración
  simdigraph_niter <- reactiveVal(0)
  simdigraph_max_niter <- reactiveVal()
  # Diseño
  simdigraph_layout <- reactiveVal("circle")

  #Sobra
  simdigraph_vertex_size <- reactiveVal(1)
  #Sobra
  simdigraph_edge_width <- reactiveVal(1)
  # Paleta de colores
  simdigraph_color <- reactiveVal("red/green")

  simdigraph_wimp <- reactiveVal()

  # Función de propagación
  simdigraph_infer <- reactiveVal("self dynamics")
  # Función umbral
  simdigraph_thr <- reactiveVal("saturation")
  # Nº de iteraciones máximas
  simdigraph_max_iter <- reactiveVal(30)

  # Valor diferencial
  simdigraph_e <- reactiveVal(0.0001)
  # Nº de la iteración sin cambios
  simdigraph_stop_iter <- reactiveVal(3)

  

  # Variables reactivas para almacenar los cambios de los inputs de pcsdindices

  act_vector <- reactiveVal()

  infer <- reactiveVal("self dynamics")

  thr <- reactiveVal("saturation")

  max_iter <- reactiveVal(30)

  e <- reactiveVal(0.0001)

  stop_iter <- reactiveVal(3)

  # Variables reactivas para almacenar los cambios de los inputs de pscd

  pscd_iter <- reactiveVal(0)

  pscd_wimp <- reactiveVal()

  pscd_act_vector <- reactiveVal(0)

  pscd_infer <- reactiveVal("self dynamics")

  pscd_thr <- reactiveVal("saturation")
  # Nº de iteraciones máximas
  pscd_max_iter <- reactiveVal(30)
  # Valor diferencial
  pscd_e <- reactiveVal(0.0001)
  # Nº de iteraciones sin cambios
  pscd_stop_iter <- reactiveVal(3)


  observe({
    max_niter <- simdigraph_max_niter()
    updateNumericInput(session, "simdigraph_niter", min=0, max=max_niter)
  })

  # Lógica para la pestaña "Laboratorio"

  observeEvent(input$tab_laboratorio, {

    

  })

  # Observer event para el input niter de simdigraph

  observeEvent(input$simdigraph_niter, {

    simdigraph_niter(input$simdigraph_niter)

  })

  

  # Observer event para el input layout de simdigraph

  observeEvent(input$simdigraph_layout, {

    simdigraph_layout(input$simdigraph_layout)

  })

  

  # Observer event para el input vertex.size de simdigraph

  observeEvent(input$simdigraph_vertex_size, {

    simdigraph_vertex_size(input$simdigraph_vertex_size)

  })

  

  # Observer event para el input edge.width de simdigraph

  observeEvent(input$simdigraph_edge_width, {

    simdigraph_edge_width(input$simdigraph_edge_width)

  })

  

  # Observer event para el input color de simdigraph

  observeEvent(input$simdigraph_color, {

    simdigraph_color(input$simdigraph_color)

  })

  

  # Observer event para el input wimp de simdigraph

  observeEvent(input$simdigraph_wimp, {

    simdigraph_wimp(input$simdigraph_wimp)

  })


  # Observer event para el input infer de simdigraph

  observeEvent(input$simdigraph_infer, {

    simdigraph_infer(input$simdigraph_infer)

  })

  

  # Observer event para el input thr de simdigraph

  observeEvent(input$simdigraph_thr, {

    simdigraph_thr(input$simdigraph_thr)

  })

  

  # Observer event para el input max.iter de simdigraph

  observeEvent(input$simdigraph_max_iter, {

    simdigraph_max_iter(input$simdigraph_max_iter)
  })

  

  # Observer event para el input e de simdigraph

  observeEvent(input$simdigraph_e, {

    simdigraph_e(input$simdigraph_e)

  })

  

  # Observer event para el input stop.iter de simdigraph

  observeEvent(input$simdigraph_stop_iter, {

    simdigraph_stop_iter(input$simdigraph_stop_iter)

  })



  output$simdigraph_act_vector <- renderRHandsontable({
    vv <- df_V()
    if(!is.null(session$userData$constructos_izq) && !is.null(session$userData$constructos_der)){
      izq <- session$userData$constructos_izq
      der <- session$userData$constructos_der
      res <- paste(izq, der, sep="/\n")
      colnames(vv) <- res
    }
    rhandsontable(vv, rowHeaders = NULL) %>% 
            hot_table(stretchH="all")


  })

  list_to_string <- function(lista) {
    cadena_numeros <- as.character(lista)
    string <- ""
    for (i in 1:length(cadena_numeros)) {
      if (i > 1) {
        string <- paste(string, ",", sep = "")
      }
      string <- paste(string, cadena_numeros[i], sep = "")
    }
    return(string)
  }


  observeEvent(input$simdigraph_act_vector, {
      vv <- (hot_to_r(input$simdigraph_act_vector))
      if(!any(is.na(vv))){
        if(ncol(vv) == max_v){
          df_V(vv)
          df_Vpcsd(vv)
          df_Vind(vv)
        }
      }
      else{
        showModal(modalDialog(
          title = "Error",
          i18n$t("No se pueden tener campos vacíos en el vector. Vuelva a rellenarlo")
        ))
      }
  })

  

  # Observer event para el input act.vector de pcsdindices

  #v <- rep(0, 22)

  df_Vind <- reactiveVal(as.data.frame(t(v)))

  

  output$pcsdindices_act_vector <- renderRHandsontable({

    vv <- df_Vind()
    col_highlight = c(0, 1)
    row_highlight = c(3)
    if(!is.null(session$userData$constructos_izq) && !is.null(session$userData$constructos_der)){
      izq <- session$userData$constructos_izq
      der <- session$userData$constructos_der
      res <- paste(izq, der, sep="/\n")
      colnames(vv) <- res
    }
    rhandsontable(vv ,rowHeaders = NULL, col_highlight = col_highlight, row_highlight = row_highlight) %>% 
            hot_table(stretchH="all")
  })

  

  observeEvent(input$pcsdindices_act_vector, {
      vv <- (hot_to_r(input$pcsdindices_act_vector))
      if(!any(is.na(vv))){
        if(ncol(vv) == max_v){
          df_Vind(vv)
          df_V(vv)
          df_Vpcsd(vv)
        }
      }
      else{
        showModal(modalDialog(
          title = "Error",
          i18n$t("No se pueden tener campos vacíos en el vector. Vuelva a rellenarlo")
        ))
      }

  })

  # Observer event para el input infer de pcsdindices

  observeEvent(input$pcsdindices_infer, {

    infer(input$pcsdindices_infer)

  })

  

  # Observer event para el input thr de pcsdindices

  observeEvent(input$pcsdindices_thr, {

    thr(input$pcsdindices_thr)

  })

  

  # Observer event para el input max.iter de pcsdindices

  observeEvent(input$pcsdindices_max_iter, {

    max_iter(input$pcsdindices_max_iter)

  })

  

  # Observer event para el input e de pcsdindices

  observeEvent(input$pcsdindices_e, {

    e(input$pcsdindices_e)

  })

  

  # Observer event para el input stop.iter de pcsdindices

  observeEvent(input$pcsdindices_stop_iter, {

    stop_iter(input$pcsdindices_stop_iter)

  })

  

  

  # Observer event para el input iter de pscd

  observeEvent(input$pcsd_iter, {

    pscd_iter(input$pcsd_iter)

  })

  

  # Observer event para el input wimp de pscd

  observeEvent(input$pscd_wimp, {

    pscd_wimp(input$pscd_wimp)

  })

  

  # Observer event para el input act.vector de pscd

  #v <- rep(0, 22)

  df_Vpcsd <- reactiveVal(as.data.frame(t(v)))

  

  output$pcsd_act_vector <- renderRHandsontable({

    vv <- df_Vpcsd()
    if(!is.null(session$userData$constructos_izq) && !is.null(session$userData$constructos_der)){
      izq <- session$userData$constructos_izq
      der <- session$userData$constructos_der
      res <- paste(izq, der, sep="/\n")
      colnames(vv) <- res
    }
    rhandsontable(vv, rowHeaders = NULL) %>% 
            hot_table(stretchH="all")

  })

  

  observeEvent(input$pcsd_act_vector, {
      vv <- (hot_to_r(input$pcsd_act_vector))
      if(!any(is.na(vv))){
        if(ncol(vv) == max_v){
          df_Vpcsd(vv)
          df_Vind(vv)
          df_V(vv)
        }
      }
      else{
        showModal(modalDialog(
          title = "Error",
          i18n$t("No se pueden tener campos vacíos en el vector. Vuelva a rellenarlo")
        ))
      }
  })

  # Observer event para el input infer de pscd

  observeEvent(input$pcsd_infer, {

    pscd_infer(input$pcsd_infer)
    message("modifico pscdinferrrr")

  })

  

  # Observer event para el input thr de pscd

  observeEvent(input$pcsd_thr, {

    pscd_thr(input$pcsd_thr)

  })

  

  # Observer event para el input max.iter de pscd

  observeEvent(input$pcsd_max_iter, {

    pscd_max_iter(input$pcsd_max_iter)

  })

  

  # Observer event para el input e de pscd

  observeEvent(input$pcsd_e, {

    pscd_e(input$pcsd_e)

  })

  

  # Observer event para el input stop.iter de pscd

  observeEvent(input$pcsd_stop_iter, {

    pscd_stop_iter(input$pcsd_stop_iter)

  })
  

  # Lógica para mostrar los resultados de simdigraph()

  observeEvent(input$graph_selector_laboratorio, {

    graph <- input$graph_selector_laboratorio

  })

  #df_actual <- reactiveVal(as.data.frame(t(v)))

  actualizarVector <- function(string){
    df <- as.data.frame(t(v))
    lista <- strsplit(string, ",")[[1]]
    i <- 1
    
    while(i <= length(lista)){
      df[1, i] <- as.numeric(lista[i])
      i <- i+1
    }
    return(df)
  } 
  # ver de donde saco el id_wx
  actualizar_controles_local <- function(id_wx){
    # compruebo si existe wimpgrid params para un wimpgrid xlsx
    con <- establishDBConnection()
    query <- sprintf("select * from wimpgrid_params where fk_wimpgrid = %d", id_wx)
    controles <- DBI::dbGetQuery(con, query)
    DBI::dbDisconnect(con)
    
    if(nrow(controles)>0){
      message("entro para modificar controles locales")
      # simdigraph
      updateSelectInput(session, "simdigraph_thr", selected=controles$sim_umbral)
      updateSelectInput(session, "simdigraph_layout", selected=controles$sim_design)
      updateSelectInput(session, "simdigraph_color", selected=controles$sim_color)
      updateNumericInput(session, "simdigraph_niter", value=controles$sim_n_iter)
      updateNumericInput(session, "simdigraph_max_iter", value=controles$sim_n_max_iter)
      updateNumericInput(session, "simdigraph_stop_iter", value=controles$sim_n_stop_iter)
      updateNumericInput(session, "simdigraph_e", value=controles$sim_valor_diferencial)
      df_V(actualizarVector(controles$sim_vector))

      # pcsd
      updateNumericInput(session, "pcsd_iter", value=controles$pcsd_n_iter)
      updateNumericInput(session, "pcsd_max_iter", value=controles$pcsd_n_max_iter)
      updateNumericInput(session, "pcsd_stop_iter", value=controles$pcsd_n_stop_iter)
      updateSelectInput(session, "pcsd_e", selected=controles$pcsd_valor_diferencial)
      df_Vpcsd(actualizarVector(controles$pcsd_vector))

      # pcsd índices
      updateSelectInput(session, "pcsdindices_infer", selected=controles$pcind_propagacion)
      updateSelectInput(session, "pcsdindices_thr", selected=controles$pcind_umbral)
      updateNumericInput(session, "pcsdindices_max_iter", value=controles$pcind_n_max_iter)
      updateNumericInput(session, "pcsdindices_e", value=controles$pcind_valor_diferencial)
      updateNumericInput(session, "pcsdindices_stop_iter", value=controles$pcind_n_stop_iter)
      df_Vind(actualizarVector(controles$pcind_vector))

      # vector 
      #if(!is.na(controles$vector_actual)){
        df_actual(actualizarVector(controles$vector_actual))
        wimp <- dataaa_w()
        df <- as.data.frame(t(v))
        lista <- strsplit(controles$vector_actual, ",")[[1]]
        wimp$self[[2]] <- as.double(unlist(lista))
        dataaa_w(wimp)
      #}
    }
  }

  if(!is.null(session$userData$id_wimpgrid)){
    message("actualizo controles locales")
    actualizar_controles_local(session$userData$id_wimpgrid)
  }

  actualizar_controles_bd <- function(id_wx){
    
    con <- establishDBConnection()
    # compruebo si existe wimpgrid params para un wimpgrid xlsx
    query <- sprintf("select id from wimpgrid_params where fk_wimpgrid = %d", id_wx)
    controles <- DBI::dbGetQuery(con, query)
    
    if(nrow(controles)==0){
      # insertar
      query_wp <- sprintf(
        "INSERT INTO wimpgrid_params (
            id, fk_wimpgrid, sim_design, sim_umbral, sim_n_iter, sim_n_max_iter, sim_n_stop_iter, sim_color, sim_valor_diferencial, sim_vector,
            pcsd_n_iter, pcsd_n_max_iter, pcsd_n_stop_iter, pcsd_valor_diferencial, pcsd_vector,
            pcind_propagacion, pcind_umbral, pcind_n_max_iter, pcind_n_stop_iter, pcind_valor_diferencial, pcind_vector,
            vector_actual
        ) VALUES (
            %d, %d, '%s', '%s', %d, %d, %d, '%s', %f, '%s',
            %d, %d, %d, %f, '%s',
            '%s', '%s', %d, %d, %f, '%s',
            '%s'
        )",  
        id_wx, id_wx, simdigraph_layout(), simdigraph_thr(), simdigraph_niter(), simdigraph_max_iter(), simdigraph_stop_iter(), simdigraph_color(), round(simdigraph_e(), 6), list_to_string(df_V()),
        pscd_iter(), pscd_max_iter(), pscd_stop_iter(), round(pscd_e(), 6), list_to_string(df_Vpcsd()),
        infer(), thr(), max_iter(), stop_iter(), round(e(), 6), list_to_string(df_Vind()),
        list_to_string(df_actual())
      )
    }
    else{
      # actualizar
      query_wp <- sprintf("
      UPDATE wimpgrid_params SET
            sim_design = '%s', sim_umbral = '%s', sim_n_iter = %d, sim_n_max_iter = %d, sim_n_stop_iter = %d, sim_color = '%s', sim_valor_diferencial = %f, sim_vector = '%s',
            pcsd_n_iter = %d, pcsd_n_max_iter = %d, pcsd_n_stop_iter = %d, pcsd_valor_diferencial = %f, pcsd_vector = '%s',
            pcind_propagacion = '%s', pcind_umbral = '%s', pcind_n_max_iter = %d, pcind_n_stop_iter = %d, pcind_valor_diferencial = %f, pcind_vector = '%s',
            vector_actual= '%s'
        WHERE fk_wimpgrid = %d;",
        simdigraph_layout(), simdigraph_thr(), simdigraph_niter(), simdigraph_max_iter(), simdigraph_stop_iter(), simdigraph_color(), round(simdigraph_e(), 6), list_to_string(df_V()),
        pscd_iter(), pscd_max_iter(), pscd_stop_iter(), round(pscd_e(), 6), list_to_string(df_Vpcsd()),
        infer(), thr(), max_iter(), stop_iter(), round(e(), 6), list_to_string(df_Vind()),
        list_to_string(df_actual()),
        id_wx)

    }
    DBI::dbExecute(con, query_wp)
    DBI::dbDisconnect(con)
  }

  shinyjs::onclick("guardarBD_w", {
    if (!is.null(session$userData$datos_wimpgrid)) {
      con <- establishDBConnection()
      comentarios <- DBI::dbGetQuery(con, sprintf("SELECT comentarios FROM wimpgrid_params where fk_wimpgrid=%d", session$userData$id_wimpgrid))
      DBI::dbDisconnect(con)
      showModal(modalDialog(
          title = i18n$t("Anotaciones"),
          sprintf("¿Desea añadir algún comentario para la simulación de %s antes de guardarla?", nombrePaciente()),
          textAreaInput("anotacionesSimulacion", i18n$t("Anotaciones:"), value=as.character(comentarios$comentarios)),
          footer = tagList(
            modalButton("Cancelar"),
            actionButton("confirmarGuardadoSimulacion", "Guardar simulación", status ="success", icon = icon("check"))
          )
      ))
    }
  })

  shinyjs::onclick("confirmarGuardadoSimulacion", {
      removeModal()
      fecha <- session$userData$fecha_wimpgrid
      id_paciente <- session$userData$id_paciente
      anotaciones <- input$anotacionesSimulacion
      con <- establishDBConnection()
      #gestionar los cambios y guardarlos directamente en la bd
      cambios <- cambios_reactive()
      for(changes in cambios){
        x <- as.numeric(changes[1]) + 2 # ajustamos las coordenadas para la bd
        y <- as.numeric(changes[2]) + 1 # ajustamos ...
        old_v <- as.character(changes[3]) #ajustamos los numeros a texto como esta en la bd
        new_v <- as.character(changes[4])
        query <- sprintf("UPDATE wimpgrid_xlsx SET valor='%s' WHERE fila=%d and columna=%d and fk_paciente=%d and fecha_registro='%s'", 
                    new_v, x, y, id_paciente, fecha)
        
        DBI::dbExecute(con, query)
      }
      #query2 <- sprintf("SELECT distinct(id) from wimpgrid_xlsx where fecha_registro = '%s'", fecha)
      #id_wx <- as.integer(DBI::dbGetQuery(con, query2))
      actualizar_controles_bd(session$userData$id_wimpgrid)
      query_wp <- sprintf("UPDATE wimpgrid_params SET comentarios='%s' WHERE fk_wimpgrid=%d", anotaciones, session$userData$id_wimpgrid)
      DBI::dbExecute(con, query_wp)
      showNotification(
          ui = i18n$t("Los datos se han guardado correctamente en la base de datos."),
          type = "message",
          duration = 3
      )
      DBI::dbDisconnect(con)
  })
 

output$graph_output_laboratorio <- renderUI({


    # Verificar que input$graph_selector_visualizacion no es NULL

    req(input$graph_selector_laboratorio)

    # Asignar el input a una variable

    graph <- input$graph_selector_laboratorio

    # Dependiendo de la selección del usuario, dibuja el gráfico correspondiente

    print("grapfh selected in laboratory")

    print(graph)

    if (graph == i18n$t("simdigrafo")) {

      shinyjs::show("lab_showw")

      shinyjs::hide("pscd_showw")

      sim_stop_it <- simdigraph_stop_iter()

    

      if(i18n$get_translation_language()=="es"){

        print(paste("simdig:",i18n$get_translation_language()))

        print(translate_word("en", simdigraph_infer()))
        scn <- scenariomatrix(dataaa_w(),act.vector= df_V(),infer = simdigraph_infer(),

                              thr = simdigraph_thr(), max.iter = simdigraph_max_iter(), e = simdigraph_e(),

                              stop.iter = sim_stop_it)
        
        max_niter <- (as.numeric(nrow(scn$values)) - 1)
        simdigraph_max_niter(max_niter)

        simdigraph.vis(scn,niter=simdigraph_niter(), layout = translate_word("en",simdigraph_layout()), color = translate_word("en",simdigraph_color()))
        
        
      }
      else{
        thr = simdigraph_thr()

        scn <- scenariomatrix(dataaa_w(),act.vector= df_V(),infer = simdigraph_infer(),

                              thr = simdigraph_thr(), max.iter = simdigraph_max_iter(), e = simdigraph_e(),

                              stop.iter = sim_stop_it)

        simdigraph.vis(scn,niter=simdigraph_niter(), layout = simdigraph_layout(), color = simdigraph_color())
        
      }
      
    } else if (graph == "pcsd") {

      shinyjs::hide("lab_showw")

      shinyjs::show("pscd_showw")
      

      pscd_stop_it <- pscd_stop_iter()

      
      scn <- scenariomatrix(dataaa_w(),act.vector= df_Vpcsd(),infer = pscd_infer(),

                              thr = pscd_thr(), max.iter = pscd_max_iter(), e = pscd_e(),

                              stop.iter = pscd_stop_it)
      print("")
      #pscdit <- pscd_iter()

      #pcsd(scn, vline =pscdit)

    } else if (graph == "pcsdindices") {
      message("entro en pcsdindices..")
      message(infer())
      if(i18n$get_translation_language()=="es") {

        scn <- scenariomatrix(dataaa_w(),act.vector= df_Vind(),infer = infer(),

                              thr = thr(), max.iter = max_iter(), e = e(),

                              stop.iter = stop_iter())
      } else {

        scn <- scenariomatrix(dataaa_w(),act.vector= df_Vind(),infer = infer(),

                              thr = thr(), max.iter = max_iter(), e = e(),

                              stop.iter = stop_iter())

      }

      shinyjs::hide("lab_showw")
      shinyjs::hide("pscd_showw")
      #print(pcsdindices(scn))

    }
})

 

output$convergence <- renderText({

    if(i18n$get_translation_language()=="es") {

    scn <- scenariomatrix(dataaa_w(),act.vector= df_Vind(),infer = infer(),

                           thr = thr(), max.iter = max_iter(), e = e(),

                           stop.iter = stop_iter())

  } else {

    scn <- scenariomatrix(dataaa_w(),act.vector= df_Vind(),infer = infer(),

                           thr = thr(), max.iter = max_iter(), e = e(),

                           stop.iter = stop_iter())

  }

    pscind <- pcsdindices(scn)

    knitr::kable(pscind$convergence, col.names = "convergence",format = "html") %>%

    kable_styling("striped", full_width = F) %>%

    row_spec(0, bold = T) %>%

    column_spec(1, bold = T)

})


 

output$summary <- DT::renderDataTable({

  if(i18n$get_translation_language()=="es") {

    scn <- scenariomatrix(dataaa_w(),act.vector= df_Vind(),infer = infer(),

                           thr = thr(), max.iter = max_iter(), e = e(),

                           stop.iter = stop_iter())

  } else {

    scn <- scenariomatrix(dataaa_w(),act.vector= df_Vind(),infer = infer(),

                           thr = thr(), max.iter = max_iter(), e = e(),

                           stop.iter = stop_iter())

  }

  pscind <- pcsdindices(scn)

 

  summary <- data.frame(Sum = round(pscind$summary, 3))
  DT::datatable(summary)

})

 

output$auc <- DT::renderDataTable({

    if(i18n$get_translation_language()=="es") {

    scn <- scenariomatrix(dataaa_w(),act.vector= df_Vind(),infer = infer(),

                           thr = thr(), max.iter = max_iter(), e = e(),

                           stop.iter = stop_iter())

  } else {

    scn <- scenariomatrix(dataaa_w(),act.vector= df_Vind(),infer = infer(),

                           thr = thr(), max.iter = max_iter(), e = e(),

                           stop.iter = stop_iter())

  }

  pscind <- pcsdindices(scn)
  auc <- data.frame(Auc = round(pscind$auc, 3))
  DT::datatable(auc)

})

 

output$stability <- DT::renderDataTable({

    if(i18n$get_translation_language()=="es") {

    scn <- scenariomatrix(dataaa_w(),act.vector= df_Vind(),infer = infer(),

                           thr = thr(), max.iter = max_iter(), e = e(),

                           stop.iter = stop_iter())

  } else {

    scn <- scenariomatrix(dataaa_w(),act.vector= df_Vind(),infer = infer(),

                           thr = thr(), max.iter = max_iter(), e = e(),

                           stop.iter = stop_iter())

  }

  pscind <- pcsdindices(scn)

  stability <- data.frame(Stab = round(pscind$stability, 3))
  DT::datatable(stability)


})

 

output$pscd_show <- renderPlotly({

  req(input$graph_selector_laboratorio)

 

  # Asignar el input a una variable

  graph <- input$graph_selector_laboratorio

    if (graph == "pcsd") {

 

      shinyjs::hide("lab_showw")

      shinyjs::show("pscd_showw")

    pscd_stop_it <- pscd_stop_iter()

    scn <- scenariomatrix(dataaa_w(),act.vector= df_Vpcsd(),infer = pscd_infer(),

                            thr = pscd_thr(), max.iter = pscd_max_iter(), e = pscd_e(),

                            stop.iter = pscd_stop_it)

    pscdit <- pscd_iter()

    pcsd(scn, vline =pscdit)

 

    } else {

      shinyjs::show("lab_showw")

      shinyjs::hide("pscd_showw")

    }

  })

  observeEvent(input$matriz_pesos_w, {
    if (!is.null(session$userData$datos_wimpgrid)) {
      # Ocultar el botón "Editar" y mostrar el botón "Guardar"
      shinyjs::hide("editar_w")
      shinyjs::hide("guardarBD_w")
      #shinyjs::show("volver_inicio_w")

      runjs("$('#matriz_pesos_w').addClass('tab-active');
      $('#volver_inicio_w').removeClass('tab-active');
      $('#vector_yo_actual_w').removeClass('tab-active');")
      
      shinyjs::hide("guardarComo_w")
      shinyjs::hide("exportar_w")
      # Cambiar a modo de edición
      shinyjs::hide("prueba_container_w")
      shinyjs::hide("vector_yo_actual")
      shinyjs::show("matriz_pesos")
    }
  })

  onclick("vector_yo_actual_w", {
    if (!is.null(session$userData$datos_wimpgrid)) {
      shinyjs::hide("editar_w")

      runjs("$('#vector_yo_actual_w').addClass('tab-active');
      $('#matriz_pesos_w').removeClass('tab-active');
      $('#volver_inicio_w').removeClass('tab-active');")
      
      shinyjs::show("guardarComo_w")
      shinyjs::hide("exportar_w")
      shinyjs::hide("prueba_container_w")
      shinyjs::hide("matriz_pesos")
      shinyjs::show("vector_yo_actual")
      shinyjs::show("guardarBD_w")
      permitirEjecucionYoActual <<- TRUE

      output$vector_editable_yo_actual <- renderRHandsontable({
        lista_actual <- list()

        if(!is.null(session$userData$datos_wimpgrid)){
          tabla <- tabla_manipulable_w()
          nombres_columnas <- colnames(tabla)
          min_val <- as.integer(nombres_columnas[1])
          max_val <- as.integer(nombres_columnas[length(nombres_columnas)])
          columnas <- length(nombres_columnas) -3
          nombres_filas <- rownames(tabla)
          filas <- length(nombres_filas)
          for(i in 1:filas){
            for(j in 1:columnas+1){
              if(i+1 == j){
                lista_actual[i] <- as.numeric(tabla[i, j])
              }
            }
          }
          if(!is.null(session$userData$constructos_izq) && !is.null(session$userData$constructos_der)){
            # primera vez que se carga, hacerlo desde la rejilla
            df <- df_actual()
            izq <- session$userData$constructos_izq
            der <- session$userData$constructos_der
            res <- paste(izq, der, sep="/\n")
            colnames(df) <- res
            lista_estandarizada <- c()
            message("df en output$vector_editable_yo_actual: ", df)
            if(all(df[1, ] == 0)){
              for(i in seq_along(lista_actual)){
                lista_estandarizada <- c(lista_estandarizada, as.numeric(lista_actual[i]))
              }
              lista_estandarizada <- reescalar(lista_estandarizada, min_val, max_val)
              for(i in 1:length(lista_actual)){
                df[1, i] <- lista_estandarizada[i]
              }
              
            }
          }
        }
        rhandsontable(df, rowHeaders = NULL) %>% 
          hot_table(stretchH="all")
      })
    }
  })
 
  observeEvent(input$volver_inicio_w,{
    #shinyjs::hide("volver_inicio_w")

    runjs("$('#volver_inicio_w').addClass('tab-active');
      $('#matriz_pesos_w').removeClass('tab-active');
      $('#vector_yo_actual_w').removeClass('tab-active');")

    shinyjs::show("editar_w")
    shinyjs::show("guardarBD_w")
    shinyjs::show("guardarComo_w")
    shinyjs::show("exportar_w")
    shinyjs::show("botones_izquierda_w")
    # Cambiar a modo de tabla
    shinyjs::show("prueba_container_w")
    shinyjs::hide("vector_yo_actual")
    shinyjs::hide("matriz_pesos")
  })

  output$weight_matrix_graph <- renderPlotly({
    # matrix data se asigna justo al cargar los datos de importwimp para que no afecte las actualizaciones según yo-actual.
    # Crear una matriz de etiquetas con los valores de los constructos
    constructos_der <- session$userData$constructos_der
    constructos_izq <- session$userData$constructos_izq
    constructos <- paste(constructos_izq, "-", constructos_der)
    labels_matrix <- sprintf("%.2f", matrix_data)

  
    # Definir una paleta de colores personalizada centrada en el 0

    #wg_palette <- c(min_color, mid_color, max_color)
    wg_palette <- colorspace::diverging_hcl(10, h = c(10, 65), c = 100, l = c(30, 95), power = 2)
    m <- list(
      l = 50,
      r = 50,
      b = 50,
      t = 100,
      pad = 4
    )
    
    plotly::plot_ly(
      
      x = 1:ncol(matrix_data),
      y = 1:nrow(matrix_data),
      z = matrix_data,
      
      text = labels_matrix,  # Utilizar los valores de la matriz como texto
      type = "heatmap",
      colors = colorRamp(wg_palette),
      zmid = 0,  # Establecer el punto medio en 0
      height = 900,
      hovertemplate = "Causa: %{y}<br>Consecuencia: %{x}<br>Peso: %{z}"
    ) %>%
      layout(
        autosize = T,
        margin = m,
        xaxis = list(
          titlefont = list(size=20),
          title = list(text = i18n$t("Consecuencia"), standoff = 30, size=35),
          tickvals = 1:ncol(matrix_data), 
          ticktext = constructos,
          tickangle = -45
          ),
        yaxis = list(
          titlefont = list(size=20),
          title = list(text = i18n$t("Causa"), standoff = 30, size=35), # Ajusta el valor de standoff para separar más el título
          tickvals = 1:nrow(matrix_data),
          ticktext = constructos,
          tickangle = -45
        ),
        title = i18n$t("<b>Matriz de pesos estilo Heatmap</b>"),
        titlefont = list(size=20)
      )
  })

  reescalar <- function(vector, min_valor, max_valor) {
      resultado <- (vector - (max_valor + min_valor) / 2) / ((max_valor - min_valor) / 2)
      redondeado <- lapply(resultado, function(x) round(x, 2))
      
      return(redondeado)
  }

  output$vector_editable_yo_actual <- renderRHandsontable({
    lista_actual <- list()

    if(!is.null(session$userData$datos_wimpgrid)){
      tabla <- tabla_manipulable_w()
      nombres_columnas <- colnames(tabla)
      min_val <- as.integer(nombres_columnas[1])
      max_val <- as.integer(nombres_columnas[length(nombres_columnas)])
      columnas <- length(nombres_columnas) -3
      nombres_filas <- rownames(tabla)
      filas <- length(nombres_filas)
      for(i in 1:filas){
        for(j in 1:columnas+1){
          if(i+1 == j){
            lista_actual[i] <- as.numeric(tabla[i, j])
          }
        }
      }
      if(!is.null(session$userData$constructos_izq) && !is.null(session$userData$constructos_der)){
        # primera vez que se carga, hacerlo desde la rejilla
        df <- df_actual()
        izq <- session$userData$constructos_izq
        der <- session$userData$constructos_der
        res <- paste(izq, der, sep="/\n")
        colnames(df) <- res
        lista_estandarizada <- c()
        message("df en output$vector_editable_yo_actual: ", df)
        if(all(df[1, ] == 0)){
          for(i in seq_along(lista_actual)){
            lista_estandarizada <- c(lista_estandarizada, as.numeric(lista_actual[i]))
          }
          lista_estandarizada <- reescalar(lista_estandarizada, min_val, max_val)
          for(i in 1:length(lista_actual)){
            df[1, i] <- lista_estandarizada[i]
          }
          
        }
      }
    }
    rhandsontable(df, rowHeaders = NULL) %>% 
      hot_table(stretchH="all")
  })

  observeEvent(input$vector_editable_yo_actual, {
    vv <- isolate(hot_to_r(input$vector_editable_yo_actual))
      if(permitirEjecucionYoActual){
        message("entro en observeevent input vector_editable", vv)
        if(!any(is.na(vv))){
          if(ncol(vv) == max_v){
            df_actual(vv)
            wimp <- dataaa_w()
            wimp$self[[2]] <- as.double(unlist(vv))
            dataaa_w(wimp)
          }
        }
        else{
          showModal(modalDialog(
            title = "Error",
            i18n$t("No se pueden tener campos vacíos en el vector. Vuelva a rellenarlo")
          ))
        }
      }
  }, ignoreInit = TRUE)





}