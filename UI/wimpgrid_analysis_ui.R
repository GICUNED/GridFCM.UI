
#source("global.R")
wimpgrid_analysis_ui <- fluidPage( class="header-tab wg-diff",
  #shiny.i18n::usei18n(i18n),
  shiny.i18n::usei18n(i18n),

  tabsetPanel(
      tabPanel(i18n$t("Datos"), id = "tab_data_w", icon = icon("table"),
          fluidRow( class = ("flex-container-xl border-divider"),
                      h2(i18n$t("Inicio: WimpGrid"),class = "wg pagetitlecustom  mt-4"),
                      p(i18n$t("Esta página te permite visualizar y manipular los datos importados de Wimpgrid y acceder a diferentes tipos de análisis."),  class = "desccustom mb-2"),
                  ),

  shinyjs::hidden(fluidRow(id="id_warn",class="mb-4 mt-4 gap-2 justify-content-center error-help hidden",
        column(12, class = "row flex-column justify-content-center",
          icon("triangle-exclamation", "fa-2x"),
          p(i18n$t("Para hacer el análisis es necesario importar un archivo o formulario"),  class = "mt-2 mb-2"),
        ),

        column(12, class="d-flex justify-content-center", actionButton("crear_nuevo", i18n$t("Importar archivos"), status = 'warning', icon = icon("file-lines"))),
      )),

  # Mostrar los datos importados en una tabla
  #tableOutput("tabla_datos_repgrid"),
  fluidRow( class="mb-4 button-container",
    h3(i18n$t("Tabla de Datos"), class = "mr-auto mb-0"),
    actionButton("guardar_w", i18n$t("Guardar"), style = "display: none;", status = 'success', icon = icon("save")),
    actionButton("reiniciar_w", i18n$t("Reiniciar"), style = "display: none;", status = 'danger', icon = icon("arrow-rotate-left")),
    actionButton("editar_w", i18n$t("Editar"), icon = icon("edit")),
    ),
    shinyjs::hidden(
    div(id = "tabla_datos_wimpgrid_container",
      # Mostrar los datos de tabla_datos_repgrid
      rHandsontableOutput("tabla_datos_wimpgrid")
      )
    ),
    div(class=("row"), id = "prueba_container_w",
    # Mostrar los datos de prueba
    plotOutput("bert_w")
    ),),

  tabPanel(i18n$t("Visualización"), id = "tab_visualizacion", icon = icon("square-poll-vertical"),

  fluidRow(class = ("flex-container-xl border-divider"),
        h2(i18n$t("Análisis WimpGrid"), class = "wg pagetitlecustom  mt-4"),
        p(i18n$t("Esta página te permite..."),  class = "desccustom mb-4"),

        column(12, class = ("wg input-container"),
        # Agregar un selectInput para elegir el gráfico a mostrar
        selectInput("graph_selector_visualizacion",
                    i18n$t("Seleccione un análisis:"),
                    choices = c("autodigrafo","digrafo del ideal","índices de Wimp")),
        ),
      ),

      shinyjs::hidden(fluidRow(id="vis_warn",class="mb-4 mt-4 gap-2 justify-content-center error-help hidden",
        column(12, class = "row flex-column justify-content-center",
          icon("triangle-exclamation", "fa-2x"),
          p(i18n$t("Para hacer el análisis es necesario importar un archivo o formulario"),  class = "mt-2 mb-2"),
        ),

        column(12, class="d-flex justify-content-center", actionButton("crear_nuevo", "Importar archivos", status = 'warning', icon = icon("file-lines"))),
      )),

        conditionalPanel(class = ("flex-container-resp"),   condition = "input.graph_selector_visualizacion == 'selfdigraph' || input.graph_selector_visualizacion == 'autodigrafo'",


                         selectInput("selfdigraph_layout", i18n$t("Diseño:"),
                                     choices = c("circulo", "rtcirculo","arbol", "graphopt", "mds", "cuadricula"),
                                     selected = i18n$t("circulo")),

                          selectInput("selfdigraph_color", i18n$t("Paleta de colores:"),
                                     choices = c("rojo/verde", "escala de grises"),
                                     selected = i18n$t("rojo/verde")),

                         numericInput("selfdigraph_vertex_size", i18n$t("Tamaño de los vértices:"), value = 1),

                         numericInput("selfdigraph_edge_width", i18n$t("Ancho de las aristas:"), value = 1)


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
        conditionalPanel(condition = "input.graph_selector_visualizacion == 'wimpindices' || input.graph_selector_visualizacion == 'índices de Wimp' ",
        

                      fluidRow(class = "table-container pb-0 flex-row kpi",
                      h3(i18n$t("Desglose Índices"), class = "mr-auto mb-0"),
                      htmlOutput("dens")
                      ),
                        
                        rHandsontableOutput("distance"),

                        fluidRow(class = "subheader-tab flex-container-sm",
                          icon("arrows-to-circle", class = "mt-4"),
                          h4(i18n$t("Centralidad"), class = "pagetitle2custom mt-2 mb-2"),
                            
                        tabsetPanel(
                            tabPanel("Degree", DT::dataTableOutput("table_degree"), icon = icon("gauge-simple-high")),
                            tabPanel("Closeness", DT::dataTableOutput("table_closeness"), icon = icon("person-walking-dashed-line-arrow-right")),
                            tabPanel("Betweenness", DT::dataTableOutput("table_betweenness"), icon = icon("people-arrows"))
                        )),

                        fluidRow(DT::dataTableOutput(("inconsistences")))
                        ),

        fluidRow(class = "flex-container-sm",
          icon("globe", class = "mt-4"),
          h4(i18n$t("Resultado gráfico"), class = "pagetitle2custom mt-2 mb-4"),
          plotOutput("graph_output_visualizacion")
        ),
        fluidRow(class = "flex-container-sm",
          downloadButton("btn_download_visualizacion", i18n$t("Descargar Gráfico"))
        )


      ),
      tabPanel(i18n$t("Laboratorio"), id = "tab_laboratorio", icon = icon("flask-vial"),

      fluidRow( class = ("flex-container-xl border-divider"),
        h2(i18n$t("Análisis WimpGrid"), class = "wg pagetitlecustom  mt-4"),
        p(i18n$t("Esta página te permite..."),  class = "desccustom mb-4"),

        column(12, class = ("wg input-container "),
          # Agregar un selectInput para elegir el gráfico a mostrar
          selectInput("graph_selector_laboratorio",
                    i18n$t("Seleccione un gráfico:"),
                    choices = c("simdigrafo","pcsd", "pcsdindices")),
                ),

      ),

      shinyjs::hidden(fluidRow(id="lab_warn",class="mb-4 mt-4 gap-2 justify-content-center error-help hidden",
        column(12, class = "row flex-column justify-content-center",
          icon("triangle-exclamation", "fa-2x"),
          p(i18n$t("Para hacer el análisis es necesario importar un archivo o formulario"),  class = "mt-2 mb-2"),
        ),

        column(12, class="d-flex justify-content-center", actionButton("crear_nuevo", "Importar archivos", status = 'warning', icon = icon("file-lines"))),
      )),
      
        conditionalPanel(class = ("flex-container-resp detail"),
          condition = "input.graph_selector_laboratorio == 'simdigraph' || input.graph_selector_laboratorio == 'simdigrafo'",


            shinyjs::hidden(
              div(id = "simdig_inp",fileInput("simdigraph_wimp", i18n$t("Input file:"), accept = c(".xlsx")))),

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

            numericInput("simdigraph_vertex_size", i18n$t("Tamaño de los vértices:"), value = 1),

            numericInput("simdigraph_edge_width", i18n$t("Ancho de las aristas:"), value = 1),

            numericInput("simdigraph_niter", i18n$t("Número de la iteración:"), value = 0),

            numericInput("simdigraph_max_iter", i18n$t("Número de iteraciones máximas:"), value = 30),

            numericInput("simdigraph_stop_iter", i18n$t("Número de iteraciones sin cambios:"), value = 3),

            #numericInput("simdigraph_act_vector", i18n$t("Change vector:"), value = 0, step = 0.01),

              numericInput("simdigraph_e", i18n$t("Valor diferencial:"), value = 0.0001),

              rHandsontableOutput("simdigraph_act_vector"),

              fluidRow(class = "flex-container-sm",
                          icon("globe", class = "mt-4"),
                          h4("Resultado gráfico", class = "pagetitle2custom mt-2 mb-4")
                        ),
             
          ),

        conditionalPanel(class = ("flex-container-resp detail"),
          condition = "input.graph_selector_laboratorio == 'pcsd'",

              #fileInput("pcsd_wimp", i18n$t("Input file:"), accept = c(".xlsx")),

              numericInput("pcsd_iter", i18n$t("Número de la iteración:"), value = 0),

              numericInput("pcsd_max_iter", i18n$t("Número de iteraciones máximas:"), value = 30),

              numericInput("pcsd_stop_iter", i18n$t("Número de iteraciones sin cambios:"), value = 3),

              #numericInput("pcsd_act_vector", i18n$t("Change vector:"), value = 0, step = 0.01),

              selectInput("pcsd_infer", i18n$t("Función de propagación:"),
                          choices = c("transformacion lineal", "otra opción"),
                          selected = i18n$t("transformacion lineal")),

              selectInput("pcsd_thr", i18n$t("Función umbral:"),
                          choices = c("lineal", "otra opción"),
                          selected = i18n$t("lineal")),


              numericInput("pcsd_e", i18n$t("Valor diferencial:"), value = 0.0001),
              rHandsontableOutput("pcsd_act_vector")
             ),

        conditionalPanel(class = ("flex-container-resp detail"),
          condition = "input.graph_selector_laboratorio == 'pcsdindices'",
              #selectInput("pcsdindices_wimp", i18n$t("Input file:"),
                          #choices = c(i18n$t("WimpGrid_data.xlsx"), i18n$t("data.csv"), i18n$t("datos.txt"))),

              selectInput("pcsdindices_infer", i18n$t("Función de propagación:"),
                          choices = c("transformacion lineal", "transformación sigmoidea", "transformación binaria"),
                          selected = i18n$t("transformacion lineal")),

              selectInput("pcsdindices_thr", i18n$t("Función umbral:"),
                          choices = c("lineal", "sigmoide", "binario"),
                          selected = i18n$t("lineal")),

              #numericInput("pcsdindices_act_vector", i18n$t("Changes to simulate:"),
              #            value = 0, step = 0.01),
              numericInput("pcsdindices_max_iter", i18n$t("Número de iteraciones maximas:"), value = 30),
              numericInput("pcsdindices_e", i18n$t("Valor diferencial:"), value = 0.0001),
              numericInput("pcsdindices_stop_iter", i18n$t("Número de iteraciones sin cambios:"), value = 3),
              rHandsontableOutput("pcsdindices_act_vector"),

              htmlOutput("convergence"),

              fluidRow(class = "subheader-tab flex-container-sm",
              tabsetPanel(
                  tabPanel(i18n$t("Resumen"), DT::dataTableOutput("summary"), icon = icon("book")),
                  tabPanel(i18n$t("Auc"), DT::dataTableOutput("auc"), icon = icon("cube")),
                  tabPanel(i18n$t("Estabilidad"), DT::dataTableOutput("stability"), icon = icon("wave-square"))
              )),

            ),
          div(id = "pscd_showw",
            # Mostrar los datos de tabla_datos_repgrid
            fluidRow(class = "flex-container-sm",
                          icon("chart-line", class = "mt-4"),
                          h4("Resultado gráfico", class = "pagetitle2custom mt-2 mb-4"),
                          plotlyOutput("pscd_show")
                        ),
             
            
          ),
          div(id = "lab_showw",plotOutput("graph_output_laboratorio"))
      )
    )
  )

