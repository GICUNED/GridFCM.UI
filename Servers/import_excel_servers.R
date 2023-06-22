import_excel_server <- function(input, output, session) {
 observeEvent(input$importar_datos, {
    #req(input$archivo_repgrid, input$archivo_wimpgrid)
    print("h")
    # Importar datos de RepGrid y WimpGrid utilizando las funciones importwimp() y OpenRepGrid::importExcel() si los archivos están presentes
    datos_repgrid <- if (!is.null(input$archivo_repgrid)) {
      OpenRepGrid::importExcel(input$archivo_repgrid$datapath)
    }
    session$userData$datos_to_table<- if (!is.null(input$archivo_repgrid)) {read.xlsx(input$archivo_repgrid$datapath)}

    print(datos_repgrid)
    datos_wimpgrid <- if (!is.null(input$archivo_wimpgrid)) {
      importwimp(input$archivo_wimpgrid$datapath)
    }
    session$userData$datos_to_table_w<-if (!is.null(input$archivo_wimpgrid)) { read.xlsx(input$archivo_wimpgrid$datapath)}

    # Almacenar los objetos importados en el entorno de la sesión para su uso posterior
    session$userData$datos_repgrid <- datos_repgrid
    #session$userData$datos_repgrid_df <- read.csv(input$archivo_repgrid$datapath)

    session$userData$datos_wimpgrid <- datos_wimpgrid

    # Navegar a la página correspondiente en función de los archivos cargados
    if (!is.null(datos_repgrid) && !is.null(datos_wimpgrid)) {
      # Ambos archivos cargados, navegar a FullGrid Home
      #
    }  
    if (!is.null(datos_repgrid)) {
      # Solo archivo RepGrid cargado, navegar a RepGrid Home
      print("ok")
      #print(session$userData$datos_repgrid)
      repgrid_home_server(input,output,session)
      runjs("window.location.href = '/#!/repgrid';")
    } 
    if (!is.null(datos_wimpgrid)) {
      # Solo archivo WimpGrid cargado, navegar a WimpGrid Home
      #
      print("ok")
      #print(session$userData$datos_repgrid)
      #wimpgrid_analysis_server(input,output,session)
      #runjs("window.location.href = '/#!/wimpgrid';")
    }}
 )

    observeEvent(input$importar_datos_w, {
    #req(input$archivo_repgrid, input$archivo_wimpgrid)
    print("h")
    # Importar datos de RepGrid y WimpGrid utilizando las funciones importwimp() y OpenRepGrid::importExcel() si los archivos están presentes
    datos_repgrid <- if (!is.null(input$archivo_repgrid)) {
      OpenRepGrid::importExcel(input$archivo_repgrid$datapath)
    }
    session$userData$datos_to_table<- if (!is.null(input$archivo_repgrid)) {read.xlsx(input$archivo_repgrid$datapath)}

    print(datos_repgrid)
    datos_wimpgrid <- if (!is.null(input$archivo_wimpgrid)) {
      importwimp(input$archivo_wimpgrid$datapath)
    }
    session$userData$datos_to_table_w<-if (!is.null(input$archivo_wimpgrid)) { read.xlsx(input$archivo_wimpgrid$datapath)}

    # Almacenar los objetos importados en el entorno de la sesión para su uso posterior
    session$userData$datos_repgrid <- datos_repgrid
    #session$userData$datos_repgrid_df <- read.csv(input$archivo_repgrid$datapath)

    session$userData$datos_wimpgrid <- datos_wimpgrid

    # Navegar a la página correspondiente en función de los archivos cargados
    if (!is.null(datos_repgrid) && !is.null(datos_wimpgrid)) {
      # Ambos archivos cargados, navegar a FullGrid Home
      #
    } 
    if (!is.null(datos_repgrid)) {
      # Solo archivo RepGrid cargado, navegar a RepGrid Home
      print("ok")
      #print(session$userData$datos_repgrid)
      #repgrid_home_server(input,output,session)
      #runjs("window.location.href = '/#!/repgrid';")
    } 
    if (!is.null(datos_wimpgrid)) {
      # Solo archivo WimpGrid cargado, navegar a WimpGrid Home
      #
      print("ok")
      #print(session$userData$datos_repgrid)
      wimpgrid_analysis_server(input,output,session)
      runjs("window.location.href = '/#!/wimpgrid';")
    }


    
  })



}
