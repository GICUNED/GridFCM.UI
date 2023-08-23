
#source("global.R") 
wimpgrid_analysis_ui <- fluidPage( class="header-tab wg-diff",
  #shiny.i18n::usei18n(i18n),
  shiny.i18n::usei18n(i18n),
  chooseSliderSkin("Flat"),


  tabsetPanel(
    
  tabPanel(i18n$t("Datos"), id = "tab_data_w", icon = icon("table"),

          fluidRow( class = ("flex-container-titles"),
            h2(i18n$t("Inicio de WimpGrid"), class = "wg pagetitlecustom  mt-4"),
            icon("circle-question", id = "tooltip-wg-home", class="tooltip-icon mb-4 ml-2"),
            div(id="context-wg-home", class="tooltip-container", icon("circle-xmark", id = "exit-wg-tooltip", class="fa-solid exit-tooltip"), p(i18n$t("Esta página te permite visualizar y manipular los datos importados de Wimpgrid y acceder a diferentes tipos de análisis."),  class = "desccustom-tooltip")),
          ),

  shinyjs::hidden(fluidRow(id="id_warn",class="mb-4 mt-4 gap-2 justify-content-center error-help hidden",
        column(12, class = "row flex-column justify-content-center",
          icon("triangle-exclamation", "fa-2x"),
          p(i18n$t("Para hacer el análisis es necesario importar un archivo o formulario"),  class = "mt-2 mb-2"),
        ),

        column(12, class="d-flex justify-content-center", actionButton("importar_page_d", i18n$t("Importar archivos"), status = 'warning', icon = icon("file-lines"))),
      )),

  # Mostrar los datos importados en una tabla
  shinyjs::hidden(div(class = "custom-margins-lg", id="wg-data-content",
    fluidRow( class="mb-2 button-container",
      h3(i18n$t("Tabla de Datos"), class = "mr-auto mb-0"),
      actionButton("volver_w", i18n$t("Cancelar"), style = "display: none;", status = 'success', icon = icon("circle-xmark")),
      actionButton("guardar_w", i18n$t("Guardar"), style = "display: none;", status = 'success', icon = icon("save")),
      actionButton("reiniciar_w", i18n$t("Reiniciar"), style = "display: none;", status = 'danger', icon = icon("arrow-rotate-left")),
      actionButton("editar_w", i18n$t("Editar"), icon = icon("edit")),
      ),
      shinyjs::hidden(
      div(id = "tabla_datos_wimpgrid_container",
        # Mostrar los datos de tabla_datos
        rHandsontableOutput("tabla_datos_wimpgrid")
        )
      ),
      div(class=("row"), id = "prueba_container_w",
      # Mostrar los datos de prueba
      plotOutput("bert_w")
      )
    )),
  ),

  tabPanel(i18n$t("Visualización"), id = "tab_visualizacion", icon = icon("square-poll-vertical"),

      fluidRow( class = ("flex-container-titles"),
            h2(i18n$t("Análisis WimpGrid"), class = "wg pagetitlecustom  mt-4"),
            icon("circle-question", id = "tooltip-wg-2-home", class="tooltip-icon mb-4 ml-2"),
            div(id="context-wg-2-home", class="tooltip-container", icon("circle-xmark", id = "exit-wg-2-tooltip", class="fa-solid exit-tooltip"), p(i18n$t("Esta página te permite..."),  class = "desccustom-tooltip")),
          ),

      shinyjs::hidden(fluidRow(id="vis_warn",class="mb-4 mt-4 gap-2 justify-content-center error-help hidden",
        column(12, class = "row flex-column justify-content-center",
          icon("triangle-exclamation", "fa-2x"),
          p(i18n$t("Para hacer el análisis es necesario importar un archivo o formulario"),  class = "mt-2 mb-2"),
        ),

        column(12, class="d-flex justify-content-center", actionButton("importar_page_v", "Importar archivos", status = 'warning', icon = icon("file-lines"))),
      )),

      shinyjs::hidden(div(id="wg-vis-content",
      div(id="open-controls-container-vis", div(id="open-controls-vis", class="open-controls-btn", p(i18n$t("Controles")), icon(class="mr-2", "bars-progress"))),
        fluidRow(class = "input-graphic-container",
            conditionalPanel(class = "graphics-vis col-sm-9 graphic-container bg-white rounded-lg gap-2", condition = "input.graph_selector_visualizacion == 'idealdigraph' || input.graph_selector_visualizacion == 'digrafo del ideal' || input.graph_selector_visualizacion == 'selfdigraph' || input.graph_selector_visualizacion == 'autodigrafo'",
              fluidRow(class = "flex-container-resp p-2 pb-3 border-divider",
                div(class = "flex-container-sm align-left-title",
                  icon("globe"),
                  h4(i18n$t("Resultado gráfico"), class = "pagetitle2custom"),
                ),
                downloadButton(class = "btn-download", "btn_download_visualizacion", i18n$t("Descargar Gráfico"))
              ),
              uiOutput("graph_output_visualizacion")
            ),
            column(3, id="controls-panel-vis", class = "input-field-container rounded-lg",
              div(class = "flex-container-sm p-2 pb-3 border-divider",
                div(class = "flex-container-sm align-left-title",
                      icon("bars-progress"),
                      h4(i18n$t("Controles"), class = "pagetitle2custom"),
                ),
                icon("window-minimize", id="exit-controls-vis", class="close-controls-btn tooltip-icon ml-2 fa-solid"),
                ),

            column(12, class = ("wg input-container"),
                # Agregar un selectInput para elegir el gráfico a mostrar
                selectInput("graph_selector_visualizacion",
                            i18n$t("Seleccione un análisis:"),
                            choices = c("autodigrafo","digrafo del ideal","índices de Wimp")),
            ),  

            conditionalPanel(class = ("flex-container-resp"),   condition = "input.graph_selector_visualizacion == 'selfdigraph' || input.graph_selector_visualizacion == 'autodigrafo'",


                              selectInput("selfdigraph_layout", i18n$t("Diseño:"),
                                          choices = c("circulo", "rtcirculo","arbol", "graphopt", "mds", "cuadricula"),
                                          selected = i18n$t("circulo")),

                                selectInput("selfdigraph_color", i18n$t("Paleta de colores:"),
                                          choices = c("rojo/verde", "escala de grises"),
                                          selected = i18n$t("rojo/verde")),
            ),

            conditionalPanel(class = ("flex-container-resp detail"), condition = "input.graph_selector_visualizacion == 'idealdigraph' || input.graph_selector_visualizacion == 'digrafo del ideal'",

                              checkboxInput("idealdigraph_inc", i18n$t("Ocultar relaciones directas"), value = FALSE),

                              selectInput("idealdigraph_layout", i18n$t("Diseño:"),
                                          choices = c("circulo", "rtcirculo","arbol", "graphopt", "mds", "cuadricula"),
                                          selected = i18n$t("circulo")),

                                selectInput("idealdigraph_color", i18n$t("Paleta de colores:"),
                                          choices = c("rojo/verde", "escala de grises"),
                                          selected = i18n$t("rojo/verde")),

                              numericInput("idealdigraph_vertex_size", i18n$t("Tamaño de los vértices:"), value = 1),

                              numericInput("idealdigraph_edge_width", i18n$t("Ancho de las aristas:"), value = 1)


            ),

          ),
        ),

        conditionalPanel(class="graphic-container bg-white rounded-lg",condition = "input.graph_selector_visualizacion == 'wimpindices' || input.graph_selector_visualizacion == 'índices de Wimp' ",
            

                          fluidRow(class = "table-container pb-0 flex-row kpi",
                          h3(i18n$t("Desglose Índices"), class = "mr-auto mb-0"),
                          htmlOutput("dens")
                          ),
                            
                            rHandsontableOutput("distance"),

                            fluidRow(class = "subheader-tab flex-container-sm mt-4  mb-4",
                              icon("arrows-to-circle"),
                              h4(i18n$t("Centralidad"), class = "pagetitle2custom"),
                                
                            tabsetPanel(
                                tabPanel("Degree", DT::dataTableOutput("table_degree"), icon = icon("gauge-simple-high")),
                                tabPanel("Closeness", DT::dataTableOutput("table_closeness"), icon = icon("person-walking-dashed-line-arrow-right")),
                                tabPanel("Betweenness", DT::dataTableOutput("table_betweenness"), icon = icon("people-arrows"))
                            )),

                            fluidRow(class = "subheader-tab flex-container-sm mt-4 mb-4",
                              icon("arrows-to-circle"),
                              h4(i18n$t("Inconsistencias"), class = "pagetitle2custom"),
                              DT::dataTableOutput(("inconsistences")))
        ),

      ))
  ),

  tabPanel(i18n$t("Laboratorio"), id = "tab_laboratorio", icon = icon("flask-vial"),

      fluidRow( class = ("flex-container-titles"),
            h2(i18n$t("Análisis WimpGrid"), class = "wg pagetitlecustom  mt-4"),
            icon("circle-question", id = "tooltip-wg-3-home", class="tooltip-icon mb-4 ml-2"),
            div(id="context-wg-3-home", class="tooltip-container", icon("circle-xmark", id = "exit-wg-3-tooltip", class="fa-solid exit-tooltip"), p(i18n$t("Esta página te permite..."),  class = "desccustom-tooltip")),
          ),

      shinyjs::hidden(fluidRow(id="lab_warn",class="mb-4 mt-4 gap-2 justify-content-center error-help hidden",
        column(12, class = "row flex-column justify-content-center",
          icon("triangle-exclamation", "fa-2x"),
          p(i18n$t("Para hacer el análisis es necesario importar un archivo o formulario"),  class = "mt-2 mb-2"),
        ),

        column(12, class="d-flex justify-content-center", actionButton("importar_page_l", "Importar archivos", status = 'warning', icon = icon("file-lines"))),
      )),

      shinyjs::hidden(div(id="wg-lab-content",
      div(id="open-controls-container-lab", div(id="open-controls-lab", class="open-controls-btn", p(i18n$t("Controles")), icon(class="mr-2", "bars-progress"))),
        fluidRow(class = "input-graphic-container",
            column(9, id="graphics-lab", class = "graphic-container bg-white rounded-lg gap-2",
                fluidRow(class = "flex-container-resp mb-2",
                    conditionalPanel(class = "graphic-subcontainer", condition = "input.graph_selector_laboratorio == 'simdigraph' || input.graph_selector_laboratorio == 'simdigrafo'",
                      fluidRow(class = "flex-container-resp p-2 pb-3 border-divider",
                        div(class = "flex-container-sm align-left-title",
                          icon("globe"),
                          h4(i18n$t("Resultado gráfico"), class = "pagetitle2custom"),
                         ),
                          downloadButton(class = "btn-download", "boton_download_laboratory", i18n$t("Descargar Gráfico"))
                        ),
                    rHandsontableOutput("simdigraph_act_vector"),
                    ),

                    conditionalPanel(class = "graphic-subcontainer", condition = "input.graph_selector_laboratorio == 'pcsd'",
                      div(class = "flex-container-sm align-left-title p-2 pb-3 border-divider",
                        icon("line-chart"),
                        h4(i18n$t("Resultado gráfico"), class = "pagetitle2custom"),
                      ),
                      rHandsontableOutput("pcsd_act_vector"),
                    ),

                    conditionalPanel(class = "graphic-subcontainer",  condition = "input.graph_selector_laboratorio == 'pcsdindices'",
                      div(class = "flex-container-sm align-left-title p-2 pb-3 border-divider",
                        icon("table"),
                        h4(i18n$t("Resultados"), class = "pagetitle2custom"),
                      ),
                      rHandsontableOutput("pcsdindices_act_vector"),
                    
      
                    fluidRow(class = "subheader-tab flex-container-sm",
                      tabsetPanel(
                          tabPanel(i18n$t("Resumen"), DT::dataTableOutput("summary"), icon = icon("book")),
                          tabPanel(i18n$t("Auc"), DT::dataTableOutput("auc"), icon = icon("cube")),
                          tabPanel(i18n$t("Estabilidad"), DT::dataTableOutput("stability"), icon = icon("wave-square"))
                      )),

                      ),

                    ),
                    
              div(id = "pscd_showw",plotlyOutput("pscd_show")),
              div(id = "laboratory",uiOutput("graph_output_laboratorio"))
            ),
            column(3, id="controls-panel-lab", class = "input-field-container rounded-lg",
              div(class = "flex-container-sm p-2 pb-3 border-divider",
                div(class = "flex-container-sm align-left-title",
                      icon("bars-progress"),
                      h4(i18n$t("Controles"), class = "pagetitle2custom"),
                ),
                icon("window-minimize", id="exit-controls-lab", class="close-controls-btn tooltip-icon ml-2 fa-solid"),
                ),

              column(12, class = ("wg input-container "),
                  # Agregar un selectInput para elegir el gráfico a mostrar
                  selectInput("graph_selector_laboratorio",
                            i18n$t("Seleccione un gráfico:"),
                            choices = c("simdigrafo","pcsd", "pcsdindices")),
              ),
              
        
              conditionalPanel(class = "flex-container-resp detail", condition = "input.graph_selector_laboratorio == 'simdigraph' || input.graph_selector_laboratorio == 'simdigrafo'",
                  shinyjs::hidden(
                    div(id = "simdig_inp",fileInput("simdigraph_wimp", i18n$t("Input file:"), accept = c(".xlsx")))
                    ),

                    selectInput("simdigraph_infer", i18n$t("Función de propagación:"),
                                  choices = c("transformacion lineal", "otra opción"),
                                  selected = i18n$t("transformacion lineal")),

                    selectInput("simdigraph_thr", i18n$t("Función umbral:"),
                                  choices = c("lineal","otra opción"),
                                  selected = i18n$t("lineal")),

                    selectInput("simdigraph_layout", i18n$t("Diseño:"),
                                  choices = c("circulo", "rtcirculo","arbol", "graphopt", "mds", "cuadricula"),
                                  selected = i18n$t("circulo")),

                    selectInput("simdigraph_color", i18n$t("Paleta de colores:"),
                                  choices = c("rojo/verde", "escala de grises"),
                                  selected = i18n$t("rojo/verde")),

                    sliderInput("simdigraph_niter", i18n$t("Nº de la iteración:"), 0, 3, 0),

                    sliderInput("simdigraph_max_iter", i18n$t("Nº de iteraciones máximas:"), 3, 100, 30),

                    sliderInput("simdigraph_stop_iter", i18n$t("Nº de iteraciones sin cambios:"), 2, 10, 2),

                    #numericInput("simdigraph_act_vector", i18n$t("Change vector:"), value = 0, step = 0.01),

                    numericInput("simdigraph_e", i18n$t("Valor diferencial:"), value = 0.0001, step=0.0001),
                  
                ),

                conditionalPanel(class = ("flex-container-resp"),
                  condition = "input.graph_selector_laboratorio == 'pcsd'",

                      #fileInput("pcsd_wimp", i18n$t("Input file:"), accept = c(".xlsx")),

                      sliderInput("pcsd_iter", i18n$t("Nº de la iteración:"), 0, 3, 0),

                      sliderInput("pcsd_max_iter", i18n$t("Nº de iteraciones máximas:"), 3, 100, 30),

                      sliderInput("pcsd_stop_iter", i18n$t("Nº de iteraciones sin cambios:"), 2, 10, 2),

                      #numericInput("pcsd_act_vector", i18n$t("Change vector:"), value = 0, step = 0.01),

                      selectInput("pcsd_infer", i18n$t("Función de propagación:"),
                                  choices = c("transformacion lineal", "otra opción"),
                                  selected = i18n$t("transformacion lineal")),

                      selectInput("pcsd_thr", i18n$t("Función umbral:"),
                                  choices = c("lineal", "otra opción"),
                                  selected = i18n$t("lineal")),


                      numericInput("pcsd_e", i18n$t("Valor diferencial:"), value = 0.0001, step=0.0001),
                      
                    ),

                conditionalPanel(class = ("flex-container-resp detail"),
                  condition = "input.graph_selector_laboratorio == 'pcsdindices'",
                      #selectInput("pcsdindices_wimp", i18n$t("Input file:"),
                                  #choices = c(i18n$t("WimpGrid_data.xlsx"), i18n$t("data.csv"), i18n$t("datos.txt"))),
                      div(class="kpi",
                      htmlOutput("convergence"),),
                      selectInput("pcsdindices_infer", i18n$t("Función de propagación:"),
                                  choices = c("transformacion lineal", "transformación sigmoidea", "transformación binaria"),
                                  selected = i18n$t("transformacion lineal")),

                      selectInput("pcsdindices_thr", i18n$t("Función umbral:"),
                                  choices = c("lineal", "sigmoide", "binario"),
                                  selected = i18n$t("lineal")),

                      #numericInput("pcsdindices_act_vector", i18n$t("Changes to simulate:"),
                      #            value = 0, step = 0.01),
                      sliderInput("pcsdindices_max_iter", i18n$t("Nº de iteraciones máximas:"), 3, 100, 30),
                      numericInput("pcsdindices_e", i18n$t("Valor diferencial:"), value = 0.0001, step=0.0001),
                      sliderInput("pcsdindices_stop_iter", i18n$t("Nº de iteraciones sin cambios:"), 2, 10, 2)
                      
                    ),

            ),

            

        )
      ))
    )
  )
)

