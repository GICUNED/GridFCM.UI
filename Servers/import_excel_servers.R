import_excel_server <- function(input, output, session) {
 observeEvent(input$importar_datos, {
    req(input$archivo_repgrid, input$archivo_wimpgrid)

    # Importar datos de RepGrid y WimpGrid utilizando las funciones importwimp() y OpenRepGrid::importExcel()
    datos_repgrid <- OpenRepGrid::importExcel(input$archivo_repgrid$datapath)
    datos_wimpgrid <- importwimp(input$archivo_wimpgrid$datapath)

    # Almacenar los objetos importados en el entorno de la sesión para su uso posterior
    session$userData$datos_repgrid <- datos_repgrid
    session$userData$datos_wimpgrid <- datos_wimpgrid

    
  })

}