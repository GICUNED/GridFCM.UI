import_excel_server <- function(input, output, session) {
  id_paciente <- session$userData$id_paciente
  message(id_paciente)

  observeEvent(input$importar_datos, {
      
      # Importar datos de RepGrid y WimpGrid utilizando las funciones importwimp() y OpenRepGrid::importExcel() si los archivos están presentes
      #llamada al metodo de codificar para luego meter en la bd y demas
      excel_repgrid_codificar <- read.xlsx(input$archivo_repgrid$datapath, colNames=FALSE)
      ruta_destino <- "/srv/shiny-server/ficheros/excel_rep.xlsx"
      codificar_excel_BD(excel_repgrid_codificar, 'repgrid_xlsx', id_paciente)
      decodificar_BD_excel('repgrid_xlsx', ruta_destino, id_paciente)
      

      datos_repgrid <- if (!is.null(input$archivo_repgrid)) {
        OpenRepGrid::importExcel(ruta_destino)
      }
      
      excel_repgrid <- if (!is.null(input$archivo_repgrid)) {read.xlsx(ruta_destino)}
      

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

      datos_wimpgrid <- if (!is.null(input$archivo_wimpgrid)) {
        importwimp(input$archivo_wimpgrid$datapath)
      }
      session$userData$datos_to_table_w<-if (!is.null(input$archivo_wimpgrid)) { read.xlsx(input$archivo_wimpgrid$datapath)}  

      session$userData$datos_repgrid <- datos_repgrid
      session$userData$datos_wimpgrid <- datos_wimpgrid


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
      codificar_excel_BD(excel_wimp_codificar, 'wimpgrid_xlsx', id_paciente)
      decodificar_BD_excel('wimpgrid_xlsx', ruta_destino, id_paciente)

      # Importar datos de RepGrid y WimpGrid utilizando las funciones importwimp() y OpenRepGrid::importExcel() si los archivos están presentes
      datos_repgrid <- if (!is.null(input$archivo_repgrid)) {
        OpenRepGrid::importExcel(ruta_destino)
      }
      session$userData$datos_to_table<- if (!is.null(input$archivo_repgrid)) {read.xlsx(ruta_destino)}

      datos_wimpgrid <- if (!is.null(input$archivo_wimpgrid)) {
        importwimp(input$archivo_wimpgrid$datapath)
      }
      session$userData$datos_to_table_w<-if (!is.null(input$archivo_wimpgrid)) { read.xlsx(input$archivo_wimpgrid$datapath)}
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
      
      session$userData$datos_repgrid <- datos_repgrid
      #session$userData$datos_repgrid_df <- read.csv(input$archivo_repgrid$datapath)



      session$userData$datos_wimpgrid <- datos_wimpgrid

      if (!is.null(datos_wimpgrid)) {
        # Solo archivo WimpGrid cargado, navegar a WimpGrid Home
        wimpgrid_analysis_server(input,output,session)
        runjs("window.location.href = '/#!/wimpgrid';")
        
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