repgrid_home_ui <- fluidPage(
  shinyjs::useShinyjs(),
  h1("RepGrid Home"),
  
  p("Esta página te permite visualizar y manipular los datos importados de RepGrid y acceder a diferentes tipos de análisis."),

  # Mostrar los datos importados en una tabla
  #tableOutput("tabla_datos_repgrid"),
  actionButton("editar", "Editar"),
  actionButton("guardar", "Guardar", style = "display: none;"),
  
  shinyjs::hidden(
    div(id = "tabla_datos_repgrid_container",
      # Mostrar los datos de tabla_datos_repgrid
      DT::dataTableOutput("tabla_datos_repgrid")
    )
  ),

  div(id = "prueba_container",
    # Mostrar los datos de prueba
    plotOutput("prueba")
  ),

  # Agregar enlaces o botones para acceder a diferentes análisis
  #actionButton("analisis1", "Análisis 1"),
  #actionButton("analisis2", "Análisis 2"),
  #actionButton("analisis3", "Análisis 3")
)
