repgrid_home_ui <- fluidPage(
  shinyjs::useShinyjs(),
  
  fluidRow( class = ("flex-container-xl border-divider"),
    h2("RepGrid Home", class = "pagetitlecustom  mt-4"),
    p("Esta página te permite visualizar y manipular los datos importados de RepGrid y acceder a diferentes tipos de análisis.",  class = "desccustom mb-2"),
  ),
  # Mostrar los datos importados en una tabla
  #tableOutput("tabla_datos_repgrid"),
  fluidRow( class="mb-4 button-container",
    h3("Data Table", class = "mr-auto mb-0"),
    actionButton("guardar", "Guardar", style = "display: none;", status = 'success', icon = icon("save")),
    actionButton("reiniciar", "Reiniciar", style = "display: none;", status = 'danger', icon = icon("arrow-rotate-left")),
    actionButton("editar", "Editar", icon = icon("edit")),
  ),
    
  shinyjs::hidden(
    div(id = "tabla_datos_repgrid_container",
      # Mostrar los datos de tabla_datos_repgrid
      rHandsontableOutput("tabla_datos_repgrid")
    )
  ),

  div(class=("row"), id = "prueba_container",
    # Mostrar los datos de prueba
    plotOutput("bert")
  ),

  # Agregar enlaces o botones para acceder a diferentes análisis
  #actionButton("analisis1", "Análisis 1"),
  #actionButton("analisis2", "Análisis 2"),
  #actionButton("analisis3", "Análisis 3")
)
