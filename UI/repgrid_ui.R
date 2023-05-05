# Unificar las interfaces de usuario
repgrid_ui <- fluidPage(
  #h1("RepGrid - Análisis y Manipulación de Datos"),
  
  tabsetPanel(
    tabPanel("Data", repgrid_home_ui),
    tabPanel("Results", repgrid_analysis_ui)
  )
)