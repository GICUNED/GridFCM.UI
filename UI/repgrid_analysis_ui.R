repgrid_analysis_ui <- fluidPage(
  h1("Análisis de RepGrid"),

  # Agregar un selectInput para elegir el gráfico a mostrar
  selectInput("graph_selector",
              "Seleccione un gráfico:",
              choices = c("Análisis Bidimensional" = "biplot2d",
                          "Análisis Tridimensional" = "biplot3d",
                          "Análisis por Conglomerados" = "cluster",
                          "Índices Cognitivos" = "gridindices",
                          "Dilemas" = "dilem")),

  # Mostrar el gráfico seleccionado usando conditionalPanel
  conditionalPanel(condition = "input.graph_selector == 'biplot2d'",
                   h3("Análisis Bidimensional"),
                   plotOutput("biplot2d_plot")),
  conditionalPanel(condition = "input.graph_selector == 'biplot3d'",
                   h3("Análisis Tridimensional"),
                   rglwidgetOutput("biplot3d_plot")),
  conditionalPanel(condition = "input.graph_selector == 'cluster'",
                   h3("Análisis por Conglomerados"),
                 fluidRow(
                   # Primer gráfico de cluster
                   column(
                     12,
                     h3("Constructs"),
                     plotOutput("cluster_plot_1")
                   )
                 ),
                 fluidRow(
                   # Segundo gráfico de cluster
                   column(
                     12,
                     h3("Elements"),
                     plotOutput("cluster_plot_2")
                   )
                 )
                   ),
  conditionalPanel(condition = "input.graph_selector == 'gridindices'",
                   h3("Índices y Valores Matemáticos"),
                   fluidRow(
                     htmlOutput("gridindices_table")),
                   fluidRow(
                     column(6, h4("Intensidad de Constructos"), htmlOutput("construct")),
                     column(6, h4("Intensidad de Elementos"), htmlOutput("elementss"))
                   )),
  conditionalPanel(condition = "input.graph_selector == 'dilem'",
                   h3("Índices y Valores Matemáticos"),
                   
                   fluidRow(
                     column(6, h4("Congruent/Discrepant Constructs"), htmlOutput("constructs")),
                     column(6, h4("Dilemmas"), htmlOutput("dilemmasss"))
                   ))

)
