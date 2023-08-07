repgrid_analysis_ui <- fluidPage( class="header-tab rg-diff",
    shiny.i18n::usei18n(i18n),

  fluidRow( class = ("flex-container-xl border-divider"),

    h2(i18n$t("Análisis RepGrid"), class = "pagetitlecustom mt-4 mb-4"),

    column(12, class = ("input-container"),
      # Agregar un selectInput para elegir el gráfico a mostrar
      selectInput("graph_selector",
                  i18n$t("Seleccione un análisis:"),
                  choices = c("Análisis Bidimensional",
                              "Análisis Tridimensional",
                              "Análisis por Conglomerados",
                              "Índices Cognitivos",
                              "Dilemas"
                  )) 
    ),
  ),

  # Mostrar el gráfico seleccionado usando conditionalPanel

  shinyjs::hidden(fluidRow(id = "repgrid_warning",class="mb-4 mt-4 gap-2 justify-content-center error-help hidden",
        column(12, class = "row flex-column justify-content-center",
          icon("triangle-exclamation", "fa-2x"),
          p(i18n$t("Para hacer el análisis es necesario importar un archivo o formulario"),  class = "mt-2 mb-2"),
        ),

        column(12, class="d-flex justify-content-center", actionButton("importar_page_r", "Importar archivos", status = 'warning', icon = icon("file-lines"))),
      )),
      
    conditionalPanel(condition = "input.graph_selector == 'Análisis Bidimensional'  ||  input.graph_selector =='Two-Dimensional Analysis' ",
      fluidRow(class = "flex-container-sm",
        icon("arrow-up-right-dots", class = "mt-4"),
        h4(i18n$t("Análisis Bidimensional"), class = "pagetitle2custom mt-2 mb-2")
      ),
      fluidRow(class = "flex-container-sm",
        plotOutput("biplot2d_plot")
      ),
      fluidRow(class = "flex-container-sm",
        downloadButton("btn_download_2d", i18n$t("Descargar Gráfico"))
      )
    ),

    conditionalPanel(condition = "input.graph_selector == 'Three-Dimensional Analysis' || input.graph_selector == 'Análisis Tridimensional'",
      fluidRow(class = "flex-container-sm",
        icon("cube", class = "mt-4"),
        h4(i18n$t("Análisis Tridimensional"), class = "pagetitle2custom mt-2 mb-2"),
        p(i18n$t("Haz click y arrastra para Interactuar."),  class = "desccustom-hint mb-2")
      ), fluidRow(class = "flex-container-sm",
      rglwidgetOutput("biplot3d_plot")
    )
  ),
  
  conditionalPanel(condition = "input.graph_selector == 'Cluster Analysis' || input.graph_selector == 'Análisis por Conglomerados'",
    fluidRow(class = "flex-container-sm",
      icon("network-wired", class = "mt-4"),
      h4(i18n$t("Análisis por Conglomerados"), class = "pagetitle2custom mt-2 mb-2")
    ),

    fluidRow(
      # Primer gráfico de cluster
      column(
        12,
        h4(i18n$t("Constructos"), class = "pagesubtitlecustom mb-4"),
        plotOutput("cluster_plot_1")
      )
    ),
    fluidRow(class = "flex-container-sm",
      downloadButton("btn_download_cluster1", i18n$t("Descargar Gráfico"))
    ),
    fluidRow(
      # Segundo gráfico de cluster
      column(
        12,
        h4(i18n$t("Elementos"), class = "pagesubtitlecustom mt-4 mb-4"),
        plotOutput("cluster_plot_2")
      )
    ),
    fluidRow(class = "flex-container-sm",
      downloadButton("btn_download_cluster2", i18n$t("Descargar Gráfico"))
    )
  ),

div(class = "custom-margins",
  conditionalPanel(condition = "input.graph_selector == 'Índices Cognitivos' || input.graph_selector=='Cognitive Indices'",
    fluidRow(class = "flex-container-sm",
      icon("brain", class = "mt-4"),
      h4(i18n$t("Índices"), class = "pagetitle2custom mt-2 mb-2")
    ),
    fluidRow(class = "table-container",
      h4(i18n$t("Índices y Valores Matemáticos"), class = "pagesubtitlecustom mt-4 mb-4"),
      htmlOutput("gridindices_table")
    ),
    fluidRow(
      column(6, h4(i18n$t("Intensidad de Constructos"), class = "pagesubtitlecustom mt-4 mb-4"),
             fluidRow(class = "table-container", DTOutput("construct"))
      ),
      column(6, h4(i18n$t("Intensidad de Elementos"), class = "pagesubtitlecustom mt-4 mb-4"),
             fluidRow(class = "table-container", DTOutput("elementss"))
      )
    ),
    fluidRow(class = "flex-container",
      h4(i18n$t("Matriz de distancias de Constructos"), class = "pagesubtitlecustom mt-4 mb-4"),
      rHandsontableOutput("matrix_constructs")
    ),
    fluidRow(class = "flex-container",
      h4(i18n$t("Matriz de distancias de Elementos"), class = "pagesubtitlecustom mt-4 mb-4"),
      rHandsontableOutput("matrix_elements"))
  ),
),

  conditionalPanel(condition = "input.graph_selector == 'Dilemas' || input.graph_selector == 'Dilemmas'",
    fluidRow(class = "flex-container-sm",
      icon("calculator", class = "mt-4"),
      h4(i18n$t("Índices y Valores Matemáticos"), class = "pagetitle2custom mt-2 mb-2")
    ),
    fluidRow(
      column(6, h4(i18n$t("Constructos Congruentes/Discordantes"), class = "pagesubtitlecustom mt-4 mb-4"), htmlOutput("constructs")),
      column(6, h4(i18n$t("Dilemas"), class = "pagesubtitlecustom mt-4 mb-4"), htmlOutput("dilemmasss"))
    )
  )
)
