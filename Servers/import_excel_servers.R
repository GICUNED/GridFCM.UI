import_excel_server <- function(input, output, session) {
  id_paciente <- session$userData$id_paciente
  message(id_paciente)


  observeEvent(input$importar_datos, {
      message(req(input$archivo_repgrid))
      # Importar datos de RepGrid y WimpGrid utilizando las funciones importwimp() y OpenRepGrid::importExcel() si los archivos están presentes
      # llamada al metodo de codificar para luego meter en la bd y demás
      excel_repgrid_codificar <- read.xlsx(input$archivo_repgrid$datapath, colNames=FALSE)
      # quitar el archivo del fileinput
      ruta_destino <- "/srv/shiny-server/ficheros/excel_rep.xlsx"
      # transformo el excel a tabla de bd y encima devuelvo la fecha para sacar en el título de la rejilla
      fecha <- codificar_excel_BD(excel_repgrid_codificar, 'repgrid_xlsx', id_paciente)
      # transformo la tabla de la bd a excel para usarla en la aplicación
      id <- decodificar_BD_excel('repgrid_xlsx', ruta_destino, id_paciente)
      
      # meto la fecha en la session para sacarla en el título
      session$userData$fecha_repgrid <- fecha

      datos_repgrid <- if (!is.null(input$archivo_repgrid)) {
        OpenRepGrid::importExcel(ruta_destino)
      }
      
      excel_repgrid <- if (!is.null(input$archivo_repgrid)) {
        read.xlsx(ruta_destino)
      }
      # convertir los numeros tipo string a tipo numerico
      columnas_a_convertir <- 2:(ncol(excel_repgrid) - 1)
      # Utiliza lapply para aplicar la conversión a las columnas seleccionadas
      excel_repgrid[, columnas_a_convertir] <- lapply(excel_repgrid[, columnas_a_convertir], as.numeric)
      
      session$userData$datos_to_table <- excel_repgrid
      num_columnas <- if (!is.null(input$archivo_repgrid)) {
        ncol(session$userData$datos_to_table)
      } else {
        0
      }
      print(paste("num col", num_columnas))
      session$userData$num_col_repgrid <- num_columnas

      num_rows <- if (!is.null(input$archivo_repgrid)) {
        nrow(session$userData$datos_to_table)
      } else {
        0
      }
      print(paste("num row", num_rows))
      session$userData$num_row_repgrid <- num_rows

      #datos_wimpgrid <- if (!is.null(input$archivo_wimpgrid)) {
      #  importwimp(input$archivo_wimpgrid$datapath)
      #}
      #session$userData$datos_to_table_w<-if (!is.null(input$archivo_wimpgrid)) { read.xlsx(input$archivo_wimpgrid$datapath)}  

      session$userData$datos_repgrid <- datos_repgrid
      #session$userData$datos_wimpgrid <- datos_wimpgrid


      if (!is.null(datos_repgrid)) {
        # Solo archivo RepGrid cargado, navegar a RepGrid Home
        repgrid_home_server(input,output,session)
        runjs("window.location.href = '/#!/repgrid';")
      } 
      
  })
  

  observeEvent(input$importar_datos_w, {
    #llamada al metodo de codificar para luego meter en la bd y demas
    excel_wimp_codificar <- read.xlsx(input$archivo_wimpgrid$datapath, colNames=FALSE)
    ruta_destino <- "/srv/shiny-server/ficheros/excel_wimp.xlsx"
    fecha <- codificar_excel_BD(excel_wimp_codificar, 'wimpgrid_xlsx', id_paciente)
    id <- decodificar_BD_excel('wimpgrid_xlsx', ruta_destino, id_paciente)

    session$userData$fecha_wimpgrid <- fecha
    session$userData$id_wimpgrid <- id

    # Importar datos de RepGrid y WimpGrid utilizando las funciones importwimp() y OpenRepGrid::importExcel() si los archivos están presentes
    #datos_repgrid <- if (!is.null(input$archivo_repgrid)) {
    #  OpenRepGrid::importExcel(ruta_destino)
    #}
    #session$userData$datos_to_table<- if (!is.null(input$archivo_repgrid)) {read.xlsx(ruta_destino)}

    datos_wimpgrid <- if (!is.null(input$archivo_wimpgrid)) {
      importwimp(ruta_destino)
    }
    excel_wimp<-if (!is.null(input$archivo_wimpgrid)) { 
      read.xlsx(ruta_destino)
    }
    # convertir los numeros tipo string a tipo numerico
    columnas_a_convertir <- 2:(ncol(excel_wimp) - 1)
    # Utiliza lapply para aplicar la conversión a las columnas seleccionadas
    excel_wimp[, columnas_a_convertir] <- lapply(excel_wimp[, columnas_a_convertir], as.numeric)

    session$userData$datos_to_table_w <- excel_wimp
    num_columnas <- if (!is.null(input$archivo_wimpgrid)) {
      ncol(session$userData$datos_to_table_w)
    } else {
      0
    }
    print(paste("num col", num_columnas))
    session$userData$num_col_wimpgrid <- num_columnas

    num_rows <- if (!is.null(input$archivo_wimpgrid)) {
      nrow(session$userData$datos_to_table_w)
    } else {
      0
    }
    print(paste("num row", num_rows))
    session$userData$num_row_wimpgrid <- num_rows
    # Almacenar los objetos importados en el entorno de la sesión para su uso posterior
    #session$userData$datos_repgrid <- datos_repgrid
    session$userData$datos_wimpgrid <- datos_wimpgrid

    if (!is.null(datos_wimpgrid)) {
      # Solo archivo WimpGrid cargado, navegar a WimpGrid Home
      wimpgrid_analysis_server(input,output,session)
      runjs("window.location.href = '/#!/wimpgrid';")
      
    }   
  })


  rv <- reactiveValues(data = NULL)
  
    observe({
      req(input$archivo_repgrid)
      
      rv$data <- read.xlsx(input$archivo_repgrid$datapath)
    })
    
    observeEvent(input$reset, {
      rv$data <- NULL
      reset('archivo_repgrid')
    })


  wv <- reactiveValues(data = NULL)
  
    observe({
      req(input$archivo_wimpgrid)
      
      wv$data <- read.xlsx(input$archivo_wimpgrid$datapath)
    })
    
    observeEvent(input$reset, {
      wv$data <- NULL
      reset('archivo_wimpgrid')
    })
  

 

  ### NEW ######################################################################################
  # Download handler function
  output$download_link_repgrid <- downloadHandler(
    # Specify the filename and content type
    filename = function() {
      "RepGrid_Template.xlsx"
    },
    content = function(file) {
      file.copy("UI/plantillas/RepGrid_Template.xlsx", file)
    }
  )

  

  output$download_link_wimpgrid <- downloadHandler(
    # Specify the filename and content type
    filename = function() {
      "WimpGrid_Template.xlsx"
    },
    content = function(file) {
      file.copy("UI/plantillas/WimpGrid_Template.xlsx", file)
    }
  )
}