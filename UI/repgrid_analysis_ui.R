repgrid_analysis_ui <- fluidPage( class="header-tab rg-diff",
    shiny.i18n::usei18n(i18n),

  fluidRow( class = ("flex-container-titles mt-2"),

    h2(i18n$t("Análisis RepGrid"), class = "pagetitlecustom mt-2"),
    #icon("circle-question", id = "tooltip-rg-analysis", class="tooltip-icon mb-4 ml-2"),
    #div(id="context-rg-analysis", class="tooltip-container", icon("circle-xmark", id = "exit-rg-analysis-tooltip", class="exit-tooltip fa-solid"), p(i18n$t("Esta página te permite..."),  class = "desccustom-tooltip")),
  ),

  # Mostrar el gráfico seleccionado usando conditionalPanel

  shinyjs::hidden(fluidRow(id = "repgrid_warning",class="mb-4 mt-4 gap-2 justify-content-center error-help",
        column(12, class = "row flex-column justify-content-center",
          icon("triangle-exclamation", "fa-2x"),
          p(i18n$t("Para hacer el análisis es necesario importar o seleccionar un archivo o formulario"),  class = "mt-2 mb-2"),
        ),

    column(12, class="d-flex flex-wrap justify-content-center",
      actionButton("patients_page_r",class="m-1", i18n$t("Ver pacientes"), icon = icon("universal-access"))
    ),
      )),
      
shinyjs::hidden(div(id = "rg-analysis-content",

        fluidRow(class = "input-graphic-container",
          conditionalPanel(class = "graphics-rg col-sm-9 graphic-container bg-white rounded-lg", condition = "input.graph_selector == 'Análisis Bidimensional'  ||  input.graph_selector =='Two-Dimensional Analysis' || input.graph_selector == 'Three-Dimensional Analysis' || input.graph_selector == 'Análisis Tridimensional'",
          
        conditionalPanel(condition = "input.graph_selector == 'Análisis Bidimensional'  ||  input.graph_selector =='Two-Dimensional Analysis'",
            fluidRow(class = "flex-container-resp pb-3 p-2 border-divider",
            div(id="open-controls-rg-2d", class="open-controls-btn", p(i18n$t("Controles")), icon(class="mr-2", "bars-progress")),
              div(class = "flex-container-sm align-left-title",
                icon("arrow-up-right-dots"),
                h4(i18n$t("Análisis Bidimensional"), class = "pagetitle2custom")
              ),
              downloadButton("btn_download_2d", i18n$t("Descargar Gráfico")),
              actionButton("enter_fs_6", label=NULL, status="primary", icon = icon("maximize"), onclick = "openFullscreen(document.getElementById('rg-analysis-content'));"),
              actionButton("exit_fs_6", i18n$t("Salir"), class="hidden", status="danger", icon = icon("minimize"), onclick = "exitFullscreen();"),
              
              actionButton("mb_enter_fs_6", label=NULL, status="primary", icon = icon("maximize"), onclick = "toggleFullscreenSimulation($('#rg-analysis-content'));"),
              actionButton("mb_exit_fs_6", i18n$t("Salir"), class="hidden", status="danger", icon = icon("minimize"), onclick = "toggleFullscreenSimulation($('#rg-analysis-content'));")

            ),
          plotOutput("biplot2d_plot"),
        ),
        
        conditionalPanel(condition = "input.graph_selector == 'Three-Dimensional Analysis' || input.graph_selector == 'Análisis Tridimensional'",
  
          fluidRow(class = "flex-container-resp p-2 border-divider",
            div(id="open-controls-rg-3d", class="open-controls-btn", p(i18n$t("Controles")), icon(class="mr-2", "bars-progress")),

            div(class = "flex-container-sm align-left-title",
              icon("cube"),
              h4(i18n$t("Análisis Tridimensional"), class = "pagetitle2custom"),
            ),
            div(class = "flex-container-sm graphics-hint",
              icon("circle-info"),
              p(i18n$t("Haz click y arrastra para Interactuar."),  class = "desccustom-hint"),
            ),
            actionButton("enter_fs_7", label=NULL, status="primary", icon = icon("maximize"), onclick = "openFullscreen(document.getElementById('rg-analysis-content'));"),
            actionButton("exit_fs_7", i18n$t("Salir"), class="hidden", status="danger", icon = icon("minimize"), onclick = "exitFullscreen();"),
            
            actionButton("mb_enter_fs_7", label=NULL, status="primary", icon = icon("maximize"), onclick = "toggleFullscreenSimulation($('#rg-analysis-content'));"),
            actionButton("mb_exit_fs_7", i18n$t("Salir"), class="hidden", status="danger", icon = icon("minimize"), onclick = "toggleFullscreenSimulation($('#rg-analysis-content'));")

          ),
          rglwidgetOutput("biplot3d_plot"),
          
        ),
    ),
          column(3, id="controls-panel-rg", class = "input-field-container rounded-lg",
              div(class = "flex-container-sm p-2 pb-3 border-divider",
                div(class = "flex-container-sm align-left-title",
                      icon("bars-progress"),
                      h4(i18n$t("Controles"), class = "pagetitle2custom"),
                ),
                icon("square-minus", id="exit-controls-rg", class="close-controls-btn tooltip-icon ml-2"),
                ),

    column(12, class = ("input-container"),
           # Agregar un selectInput para elegir el gráfico a mostrar
        selectInput("graph_selector",
                  i18n$t("Seleccione un análisis:"),
                  choices = c("Análisis Bidimensional",
                              "Análisis Tridimensional",
                              "Análisis por Conglomerados",
                              "Índices Cognitivos",
                              "Dilemas"
                  ),
                  selectize = FALSE
        ),
    ),
    ),
 
        ),

  conditionalPanel(class = "graphic-container bg-white rounded-lg mt-3", condition = "input.graph_selector == 'Cluster Analysis' || input.graph_selector == 'Análisis por Conglomerados'",
    
      
      fluidRow(class = "flex-container-sm p-2 pb-3 border-divider",

        div(id="open-controls-rg-cong", class="open-controls-btn", p(i18n$t("Controles")), icon(class="mr-2", "bars-progress")),
        
        div(class = "flex-container-sm align-left-title",
          icon("network-wired"),
          h4(i18n$t("Análisis por Conglomerados"), class = "pagetitle2custom")
        ),
        #actionButton("enter_fs_8", i18n$t("Expandir"), status="primary", icon = icon("maximize"), onclick = "openFullscreen(document.getElementById('rg-analysis-content'));"),
        #actionButton("exit_fs_8", i18n$t("Salir"), class="hidden", status="danger", icon = icon("minimize"), onclick = "exitFullscreen();"),
             
      ),

      fluidRow( class="flex-container-graph",        # Primer gráfico de cluster
        column(6,class ="mb-4 pl-4 pr-4",
          fluidRow(class = "flex-container-subtitle",
            h4(i18n$t("Constructos"), class = "pagesubtitlecustom"),
            downloadButton("btn_download_cluster1", i18n$t("Descargar Gráfico")),
          ),

          shinycssloaders::withSpinner(plotOutput("cluster_plot_1"), type = 4, color = "#022a0c", size = 0.6)
        ),
        # Segundo gráfico de cluster
        column(
          6, class ="mb-4 pl-4 pr-4 border-divider-l",
          fluidRow(class = "flex-container-subtitle",
            h4(i18n$t("Elementos"), class = "pagesubtitlecustom"),
            downloadButton("btn_download_cluster2", i18n$t("Descargar Gráfico")),
          ),
          shinycssloaders::withSpinner(plotOutput("cluster_plot_2"), type = 4, color = "#022a0c", size = 0.6)
          ),
      ),
  ),

  conditionalPanel(class = "custom-margins-lg mt-3 graphic-container bg-white rounded-lg", condition = "input.graph_selector == 'Índices Cognitivos' || input.graph_selector=='Cognitive Indices'",
      
      fluidRow(class = "flex-container-sm p-2 pb-3 border-divider",

      div(id="open-controls-rg-in", class="open-controls-btn", p(i18n$t("Controles")), icon(class="mr-2", "bars-progress")),

      div(class = "flex-container-sm align-left-title",
        icon("brain"),
        h4(i18n$t("Índices"), class = "pagetitle2custom mt-2 mb-2"),
      ),

        #actionButton("enter_fs_9", i18n$t("Expandir"), status="primary", icon = icon("maximize"), onclick = "openFullscreen(document.getElementById('rg-analysis-content'));"),
        #actionButton("exit_fs_9", i18n$t("Salir"), class="hidden", status="danger", icon = icon("minimize"), onclick = "exitFullscreen();"),
            
      ),
      fluidRow(class = "table-container mt-4",
        h4(i18n$t("Índices y Valores Matemáticos"), class = "pagesubtitlecustom mb-4"),
        shinycssloaders::withSpinner(htmlOutput("gridindices_table"), type = 4, color = "#022a0c", size = 0.6)
      ),
      fluidRow(
        column(6, h4(i18n$t("Intensidad de Constructos"), class = "pagesubtitlecustom mt-4 mb-4"),
              fluidRow(class = "table-container", shinycssloaders::withSpinner(DTOutput("construct"), type = 4, color = "#022a0c", size = 0.6))
        ),
        column(6, h4(i18n$t("Intensidad de Elementos"), class = "pagesubtitlecustom mt-4 mb-4"),
              fluidRow(class = "table-container", shinycssloaders::withSpinner(DTOutput("elementss"), type = 4, color = "#022a0c", size = 0.6))
        )
      ),
      fluidRow(class = "flex-container",
        h4(i18n$t("Matriz de distancias de Constructos"), class = "pagesubtitlecustom mt-4 mb-4"),
        shinycssloaders::withSpinner(rHandsontableOutput("matrix_constructs"), type = 4, color = "#022a0c", size = 0.6)
      ),
      fluidRow(class = "flex-container",
        h4(i18n$t("Matriz de distancias de Elementos"), class = "pagesubtitlecustom mt-4 mb-4"),
        shinycssloaders::withSpinner(rHandsontableOutput("matrix_elements"), type = 4, color = "#022a0c", size = 0.6))
  ),


  conditionalPanel(class="graphic-container bg-white rounded-lg mt-3", condition = "input.graph_selector == 'Dilemas' || input.graph_selector == 'Dilemmas'",
    fluidRow(class = "flex-container-sm p-2 pb-3 border-divider",

    div(id="open-controls-rg-dil", class="open-controls-btn", p(i18n$t("Controles")), icon(class="mr-2", "bars-progress")),


    div(class = "flex-container-sm align-left-title",
      icon("calculator"),
      h4(i18n$t("Índices y Valores Matemáticos"), class = "pagetitle2custom mt-2 mb-2")
    ),
      #actionButton("enter_fs_10", i18n$t("Expandir"), status="primary", icon = icon("maximize"), onclick = "openFullscreen(document.getElementById('rg-analysis-content'));"),
      #actionButton("exit_fs_10", i18n$t("Salir"), class="hidden", status="danger", icon = icon("minimize"), onclick = "exitFullscreen();"),
           
    ),
    fluidRow(
      column(6, h4(i18n$t("Constructos Congruentes/Discordantes"), class = "pagesubtitlecustom mt-4 mb-4"), shinycssloaders::withSpinner(htmlOutput("constructs"), type = 4, color = "#022a0c", size = 0.6)),
      column(6, h4(i18n$t("Dilemas"), class = "pagesubtitlecustom mb-4"), shinycssloaders::withSpinner(htmlOutput("dilemmasss"), type = 4, color = "#022a0c", size = 0.6))
    )
  )
  ))
)
