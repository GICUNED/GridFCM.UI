repgrid_analysis_ui <- fluidPage( class="header-tab",
  
  fluidRow( class = ("flex-container-xl border-divider"),

    h2("Análisis de RepGrid", class = "pagetitlecustom mt-4 mb-4"),

    column(12, class = ("input-container"),
  # Agregar un selectInput para elegir el gráfico a mostrar
  selectInput("graph_selector",
              "Seleccione un gráfico:",
              choices = c("Análisis Bidimensional" = "biplot2d",
                          "Análisis Tridimensional" = "biplot3d",
                          "Análisis por Conglomerados" = "cluster",
                          "Índices Cognitivos" = "gridindices",
                          "Dilemas" = "dilem"
                          )), 
    ),
  ),

  # Mostrar el gráfico seleccionado usando conditionalPanel

  fluidRow(class="mb-4 mt-4 gap-2 justify-content-center error-help hidden",
        column(12, class = "row flex-column justify-content-center",
          icon("triangle-exclamation", "fa-2x"),
          p("Para hacer el análisis es necesario importar un archivo o formulario. ",  class = "mt-2 mb-2"),
        ),

        column(12, class="d-flex justify-content-center", actionButton("crear_nuevo", "Importar Archivos", status = 'warning', icon = icon("file-lines"))),
      ),
      
    conditionalPanel(condition = "input.graph_selector == 'biplot2d'",
      fluidRow(class = "flex-container-sm",
        icon("arrow-up-right-dots", class = "mt-4"),
        h4("Análisis Bidimensional", class = "pagetitle2custom mt-2 mb-2")
      ),

      

      fluidRow(class = "flex-container-sm",
        plotOutput("biplot2d_plot")
        )
      ),

    conditionalPanel(condition = "input.graph_selector == 'biplot3d'",
      fluidRow(class = "flex-container-sm",
        icon("cube", class = "mt-4"),
        h4("Análisis Tridimensional", class = "pagetitle2custom mt-2 mb-2"),
        p("Haz click y arrastra para Interactuar.",  class = "desccustom-hint mb-2")
    ),

      fluidRow(class = "flex-container-sm",
        rglwidgetOutput("biplot3d_plot")
      )
    ),

    conditionalPanel(condition = "input.graph_selector == 'cluster'",
      fluidRow(class = "flex-container-sm",
        icon("network-wired", class = "mt-4"),
        h4("Análisis por Conglomerados", class = "pagetitle2custom mt-2 mb-2")
    ),

                 fluidRow(
                   # Primer gráfico de cluster
                   column(
                     12,
                     h4("Constructs", class = "pagesubtitlecustom mb-4"),
                     plotOutput("cluster_plot_1")
                   )
                 ),
                 fluidRow(
                   # Segundo gráfico de cluster
                   column(
                     12,
                     h4("Elements", class = "pagesubtitlecustom mt-4 mb-4"),
                     plotOutput("cluster_plot_2")
                   )
                 )
                   ),
    conditionalPanel(condition = "input.graph_selector == 'gridindices'",
                    fluidRow(class = "flex-container-sm",
                      icon("brain", class = "mt-4"),
                      h4("Índices Cognitivos", class = "pagetitle2custom mt-2 mb-2")
                    ),
                   fluidRow(class = "table-container",
                      h4("Índices y Valores Matemáticos", class = "pagesubtitlecustom mt-4 mb-4"),
                      htmlOutput("gridindices_table")),
                   fluidRow(
                     column(6, h4("Intensidad de Constructos", class = "pagesubtitlecustom mt-4 mb-4"), 
                     fluidRow(class = "table-container", htmlOutput("construct"))),
                     column(6, h4("Intensidad de Elementos", class = "pagesubtitlecustom mt-4 mb-4"), 
                     fluidRow(class = "table-container", htmlOutput("elementss")))
                   )),
    conditionalPanel(condition = "input.graph_selector == 'dilem'",
                  fluidRow(class = "flex-container-sm",
                      icon("calculator", class = "mt-4"),
                      h4("Índices y Valores Matemáticos", class = "pagetitle2custom mt-2 mb-2")
                  ),
                   
                   fluidRow(
                     column(6, h4("Congruent/Discrepant Constructs", class = "pagesubtitlecustom mt-4 mb-4"), htmlOutput("constructs")),
                     column(6, h4("Dilemmas", class = "pagesubtitlecustom mt-4 mb-4"), htmlOutput("dilemmasss"))
                   ))
  

)