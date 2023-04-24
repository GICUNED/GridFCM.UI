repgrid_home_ui <- fluidPage(
  h1("RepGrid Home"),
  p("Esta página te permite visualizar y manipular los datos importados de RepGrid y acceder a diferentes tipos de análisis."),

  # Mostrar los datos importados en una tabla
  #tableOutput("tabla_datos_repgrid"),
  DT::dataTableOutput("tabla_datos_repgrid"),
  # Agregar enlaces o botones para acceder a diferentes análisis
  actionButton("analisis1", "Análisis 1"),
  actionButton("analisis2", "Análisis 2"),
  actionButton("analisis3", "Análisis 3")
)
