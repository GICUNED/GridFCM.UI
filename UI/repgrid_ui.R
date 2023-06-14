# Unificar las interfaces de usuario
repgrid_ui <- fluidPage(
  shiny.i18n::usei18n(i18n),
  #h1("RepGrid - Análisis y Manipulación de Datos"),
  
  tabsetPanel(
    tabPanel("Data", repgrid_home_ui, icon = icon("table")),
    tabPanel("Results", repgrid_analysis_ui, icon = icon("square-poll-vertical"))
  )
)