# Unificar las interfaces de usuario
repgrid_ui <- fluidPage( class="header-tab rg-diff",
  shiny.i18n::usei18n(i18n),
  #h1("RepGrid - Análisis y Manipulación de Datos"),
  
  tabsetPanel(
    id = "tabs_rep",
    tabPanel(i18n$t("Datos"), repgrid_home_ui, icon = icon("table")),
    tabPanel(i18n$t("Resultados"), repgrid_analysis_ui, icon = icon("square-poll-vertical"))
  )
)