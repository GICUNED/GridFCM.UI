# UI de Wimpgrid.analysis
wimpgrid_analysis_ui <- fluidPage(
  h1("Análisis de Wimpgrid"),

  tabsetPanel(
    tabPanel("Visualización", id = "tab_visualizacion",
      # Mostrar los resultados de selfdigraph()
      # Agregar inputs para manipular el aspecto visual del digrafo
      plotOutput("selfdigraph"),
      # Mostrar los resultados de idealdigraph()
      # Agregar inputs para manipular el aspecto visual del digrafo
      checkboxInput("mostrar_relaciones_inversas", "Mostrar relaciones inversas", value = FALSE),
      
      # Mostrar los resultados de wimpindices()
      # Mostrar tablas con los índices matemáticos
      
    ),
    tabPanel("Laboratorio", id = "tab_laboratorio",
      # Mostrar los resultados de simdigraph()
      # Agregar inputs para manipular el aspecto visual del digrafo
      
      # Mostrar los resultados de pcsd() y pcsdindices()
      
      # Agregar un slider para seleccionar las iteraciones matemáticas del digrafo
      
    )
  )
)
