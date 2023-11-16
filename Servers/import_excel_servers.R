import_excel_server <- function(input, output, session) {
  rol <- session$userData$rol
  con <- establishDBConnection()
  query <- sprintf("SELECT COUNT(DISTINCT id) as num FROM wimpgrid_xlsx where fk_paciente = %d", session$userData$id_paciente) # de momento
  num_wimp <- DBI::dbGetQuery(con, query)
  query2 <- sprintf("SELECT COUNT(DISTINCT id) as num FROM repgrid_xlsx where fk_paciente = %d", session$userData$id_paciente) # de momento
  num_rep <- DBI::dbGetQuery(con, query2)
  DBI::dbDisconnect(con)
  if(!is.null(rol) && rol == "usuario_gratis"){
    if(num_rep$num >= 1){
      shinyjs::disable("importar_datos")
    }
    if(num_wimp$num >= 1){
      shinyjs::disable("importar_datos_w")
    }
    if((num_rep$num + num_wimp$num) >= 2){
      shinyjs::disable("importar_formulario")
    }
  }
  
  observe(
    if(is.null(input$archivo_repgrid$datapath)){
      shinyjs::disable("importar_datos")
    }
    else{
      shinyjs::enable("importar_datos")
    }
  )

  observeEvent(input$importar_datos, {
    id_paciente <- session$userData$id_paciente
    if(!is.null(input$archivo_repgrid$datapath)){
      if(file.exists(input$archivo_repgrid$datapath)){
        tryCatch({
        # Importar datos de RepGrid y WimpGrid utilizando las funciones importwimp() y OpenRepGrid::importExcel() si los archivos están presentes
        # llamada al metodo de codificar para luego meter en la bd y demás
        excel_repgrid_codificar <- read.xlsx(input$archivo_repgrid$datapath, colNames=FALSE)
        # quitar el archivo del fileinput
        ruta_destino_rep <- tempfile(fileext = ".xlsx")
        #ruta_destino_rep <- tempfile(fileext = ".xlsx")
        # transformo el excel a tabla de bd y encima devuelvo la fecha para sacar en el título de la rejilla
        fecha <- codificar_excel_BD(excel_repgrid_codificar, 'repgrid_xlsx', id_paciente)
        # transformo la tabla de la bd a excel para usarla en la aplicación
        id <- decodificar_BD_excel('repgrid_xlsx', ruta_destino_rep, id_paciente)
        # meto la fecha en la session para sacarla en el título
        session$userData$id_repgrid <- id
        session$userData$fecha_repgrid <- fecha

        #constructos
        constructos_izq <- excel_repgrid_codificar[2:nrow(excel_repgrid_codificar), 1]
        constructos_der <- excel_repgrid_codificar[2:nrow(excel_repgrid_codificar), ncol(excel_repgrid_codificar)]
        session$userData$constructos_izq_rep <- constructos_izq
        session$userData$constructos_der_rep <- constructos_der


        datos_repgrid <- if (!is.null(input$archivo_repgrid)) {
          OpenRepGrid::importExcel(ruta_destino_rep)
        }
        excel_repgrid <- if (!is.null(input$archivo_repgrid)) {
          read.xlsx(ruta_destino_rep)
        }

        # aqui voy a comprobar si estoy importando el excel exportado con los numeros como strings
        columnas_a_convertir <- 2:(ncol(excel_repgrid) - 1)
        # Utiliza lapply para aplicar la conversión a las columnas seleccionadas
        excel_repgrid[, columnas_a_convertir] <- lapply(excel_repgrid[, columnas_a_convertir], as.numeric)

        session$userData$datos_to_table <- excel_repgrid
        num_columnas <- if (!is.null(input$archivo_repgrid)) {
          ncol(session$userData$datos_to_table)
        } else {
          0
        }
        #message(paste("num col", num_columnas))
        session$userData$num_col_repgrid <- num_columnas

        num_rows <- if (!is.null(input$archivo_repgrid)) {
          nrow(session$userData$datos_to_table)
        } else {
          0
        }
        #message(paste("num row", num_rows))
        session$userData$num_row_repgrid <- num_rows
        session$userData$datos_repgrid <- datos_repgrid
        system(paste0("rm ",input$archivo_repgrid$datapath))
        file.remove(ruta_destino_rep)
        if (!is.null(datos_repgrid)) {
          # si se ha importado bien y es usuario demo lo borro de la bd
          if(rol == "usuario_demo"){
            con <- establishDBConnection()
            DBI::dbExecute(con, sprintf("DELETE FROM repgrid_xlsx where fk_paciente = %d", id_paciente))
            DBI::dbDisconnect(con)
          }
          # Solo archivo RepGrid cargado, navegar a RepGrid Home
          repgrid_home_server(input,output,session)
          runjs("window.location.href = '/#!/repgrid';")

          shinyjs::hide("import-page")
          shinyjs::hide("form-page")
          shinyjs::hide("excel-page")
        }
        },
        error = function(e) {
          showModal(modalDialog(
                title = i18n$t("Ha habido un problema al procesar la rejilla. Revise el formato de la plantilla."),
                footer = tagList(
                    modalButton("OK"),
                )
            ))
        }
        # warning = function(w) {
        #   message(paste("warning:", w))
        # }, 
        # finally = {
        #   message("cleaning")
        # }
        )
      }
    }

  })


  observe(
    if(is.null(input$archivo_wimpgrid$datapath)){
      shinyjs::disable("importar_datos_w")
    }
    else{
      shinyjs::enable("importar_datos_w")
    }
  )

  observeEvent(input$importar_datos_w, {
    id_paciente <- session$userData$id_paciente
    if(!is.null(input$archivo_wimpgrid$datapath)){
      if(file.exists(input$archivo_wimpgrid$datapath)){
        tryCatch({
          #llamada al metodo de codificar para luego meter en la bd y demas
          excel_wimp_codificar <- read.xlsx(input$archivo_wimpgrid$datapath, colNames=FALSE)
          ruta_destino_wimp <- tempfile(fileext = ".xlsx")
          fecha <- codificar_excel_BD(excel_wimp_codificar, 'wimpgrid_xlsx', id_paciente)
          id <- decodificar_BD_excel('wimpgrid_xlsx', ruta_destino_wimp, id_paciente)

          #constructos
          constructos_izq <- excel_wimp_codificar[2:nrow(excel_wimp_codificar), 1]
          constructos_der <- excel_wimp_codificar[2:nrow(excel_wimp_codificar), ncol(excel_wimp_codificar)]
          session$userData$constructos_izq <- constructos_izq
          session$userData$constructos_der <- constructos_der

          session$userData$fecha_wimpgrid <- fecha
          session$userData$id_wimpgrid <- id
          datos_wimpgrid <- if (!is.null(input$archivo_wimpgrid)) {
            importwimp(ruta_destino_wimp)
          }
          excel_wimp<-if (!is.null(input$archivo_wimpgrid)) { 
            read.xlsx(ruta_destino_wimp)
          }
          
          columnas_a_convertir <- 2:(ncol(excel_wimp) - 1)
          # Utiliza lapply para aplicar la conversión a las columnas seleccionadas
          excel_wimp[, columnas_a_convertir] <- lapply(excel_wimp[, columnas_a_convertir], as.numeric)

          session$userData$datos_to_table_w <- excel_wimp
          num_columnas <- if (!is.null(input$archivo_wimpgrid)) {
            ncol(session$userData$datos_to_table_w)
          } else {
            0
          }
          #message(paste("num col", num_columnas))
          session$userData$num_col_wimpgrid <- num_columnas

          num_rows <- if (!is.null(input$archivo_wimpgrid)) {
            nrow(session$userData$datos_to_table_w)
          } else {
            0
          }
          #message(num_rows)
          session$userData$num_row_wimpgrid <- num_rows
          # Almacenar los objetos importados en el entorno de la sesión para su uso posterior
          #session$userData$datos_repgrid <- datos_repgrid
          session$userData$datos_wimpgrid <- datos_wimpgrid
          
          system(paste0("rm ",input$archivo_wimpgrid$datapath))
          file.remove(ruta_destino_wimp)
          if (!is.null(datos_wimpgrid)) {
            if(rol == "usuario_demo"){
              con <- establishDBConnection()
              DBI::dbExecute(con, sprintf("DELETE FROM wimpgrid_xlsx where fk_paciente = %d", id_paciente))
              DBI::dbDisconnect(con)
            }
            # Solo archivo WimpGrid cargado, navegar a WimpGrid Home
            wimpgrid_analysis_server(input,output,session)
            runjs("window.location.href = '/#!/wimpgrid';")
            shinyjs::hide("import-page")
            shinyjs::hide("form-page")
            shinyjs::hide("excel-page")
            
          }
        },
        error = function(e) {
          showModal(modalDialog(
                title = i18n$t("Ha habido un problema al procesar la rejilla. Revise el formato de la plantilla."),
                footer = tagList(
                    modalButton("OK"),
                )
            ))
        }
        # warning = function(w) {
        #   message(paste("warning:", w))
        # }, 
        # finally = {
        #   message("cleaning")
        # }
        )
      }
    }
  })


  ### NEW ######################################################################################
  # Download handler function
  output$download_link_repgrid <- downloadHandler(
    # Specify the filename and content type
    filename = function() {
      "RepGrid_Template.xlsx"
    },
    content = function(file) {
      file.copy("/srv/shiny-server/UI/plantillas/RepGrid_Template.xlsx", file)
    }
  )

  output$download_link_wimpgrid <- downloadHandler(
    # Specify the filename and content type
    filename = function() {
      "WimpGrid_Template.xlsx"
    },
    content = function(file) {
      file.copy("/srv/shiny-server/UI/plantillas/WimpGrid_Template.xlsx", file)
    }
  )
}