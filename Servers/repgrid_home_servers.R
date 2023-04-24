library(OpenRepGrid)

repgrid_home_server <- function(input, output, session) {
  # Mostrar los datos importados en una tabla
  # output$tabla_datos_repgrid <- renderTable({#session$userData$datos_repgrid() # a <- OpenRepGrid::importExcel("Servers/Repgrid_data.xlsx")a})
  datos <- OpenRepGrid::importExcel("Servers/Repgrid_data.xlsx")
  #datos <- datos$data
  datos <- NULL


  output$tabla_datos_repgrid <- DT::renderDataTable({
    DT::datatable(datos)
  })


  # Agregar observadores para los botones de análisis
  observeEvent(input$analisis1, {
    # Código para realizar el análisis 1
    print("analisis1: ")
    print(session$userData$datos_repgrid)
  })

  observeEvent(input$analisis2, {
    # Código para realizar el análisis 2
  })

  observeEvent(input$analisis3, {
    # Código para realizar el análisis 3
  })
}
