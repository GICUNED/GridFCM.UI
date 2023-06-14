
#source("global.R")
wimpgrid_analysis_ui <- fluidPage(
  shiny.i18n::usei18n(i18n),

  tabsetPanel(
      tabPanel(i18n$t("Data"), id = "tab_data_w", icon = icon("table"),
          fluidRow( class = ("flex-container-xl border-divider"),
                      h2(i18n$t("WimpGrid Home"), class = "pagetitlecustom  mt-4"),
                      p(i18n$t("Esta página te permite visualizar y manipular los datos importados de Wimpgrid y acceder a diferentes tipos de análisis."),  class = "desccustom mb-2"),
                  ),

  # Mostrar los datos importados en una tabla
  #tableOutput("tabla_datos_repgrid"),
  fluidRow( class="mb-4 button-container",
    h3(i18n$t("Data Table"), class = "mr-auto mb-0"),
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

  tabPanel(i18n$t("Visualization"), id = "tab_visualizacion", icon = icon("square-poll-vertical"),

  fluidRow(class = ("flex-container-xl border-divider"),
        h2(i18n$t("WimpGrid Analysis"), class = "pagetitlecustom  mt-4"),
        p(i18n$t("Esta página te permite..."),  class = "desccustom mb-4"),

        column(12, class = ("input-container"),
        # Agregar un selectInput para elegir el gráfico a mostrar
        selectInput("graph_selector_visualizacion",
                    i18n$t("Select a graph:"),
                    choices = c(i18n$t("selfdigraph"), i18n$t("idealdigraph"), i18n$t("wimpindices"))),
        ),
      ),
        conditionalPanel(class = ("flex-container-resp"), condition = "input.graph_selector_visualizacion == 'selfdigraph'",

                         selectInput("selfdigraph_layout", i18n$t("Layout:"),
                                     choices = c(i18n$t("circle"), i18n$t("rtcircle"), i18n$t("tree"), i18n$t("graphopt"), i18n$t("mds"), i18n$t("grid")),
                                     selected = i18n$t("circle")),

                          selectInput("selfdigraph_color", i18n$t("Color palette:"),
                                     choices = c(i18n$t("red/green"), i18n$t("grey scale")),
                                     selected = i18n$t("red/green")),

                         numericInput("selfdigraph_vertex_size", i18n$t("Vertex size:"), value = 1),

                         numericInput("selfdigraph_edge_width", i18n$t("Edge width:"), value = 1)


        ),
        conditionalPanel(class = ("flex-container-resp detail"), condition = "input.graph_selector_visualizacion == 'idealdigraph'",

                         checkboxInput("idealdigraph_inc", i18n$t("Hide direct relationships"), value = FALSE),

                         selectInput("idealdigraph_layout", i18n$t("Layout:"),
                                     choices = c(i18n$t("circle"), i18n$t("rtcircle"), i18n$t("tree"), i18n$t("graphopt"), i18n$t("mds"), i18n$t("grid")),
                                     selected = i18n$t("circle")),

                          selectInput("idealdigraph_color", i18n$t("Color palette:"),
                                     choices = c(i18n$t("red/green"), i18n$t("grey scale")),
                                     selected = i18n$t("red/green")),

                         numericInput("idealdigraph_vertex_size", i18n$t("Vertex size:"), value = 1),

                         numericInput("idealdigraph_edge_width", i18n$t("Edge width:"), value = 1)


        ),
        conditionalPanel(condition = "input.graph_selector_visualizacion == 'wimpindices'",
                        htmlOutput("dens"),
                        rHandsontableOutput("distance"),

                        titlePanel("Centralidad"),
                        tabsetPanel(
                            tabPanel("Degree", DT::dataTableOutput("table_degree")),
                            tabPanel("Closeness", DT::dataTableOutput("table_closeness")),
                            tabPanel("Betweenness", DT::dataTableOutput("table_betweenness"))
                        ),
                        DT::dataTableOutput(("inconsistences"))),
        plotOutput("graph_output_visualizacion")

      ),
      tabPanel(i18n$t("Laboratory"), id = "tab_laboratorio", icon = icon("flask-vial"),

      fluidRow( class = ("flex-container-xl border-divider"),
        h2(i18n$t("WimpGrid Analysis"), class = "pagetitlecustom  mt-4"),
        p(i18n$t("Esta página te permite..."),  class = "desccustom mb-4"),

        column(12, class = ("input-container"),
          # Agregar un selectInput para elegir el gráfico a mostrar
          selectInput("graph_selector_laboratorio",
                    i18n$t("Select a graph:"),
                    choices = c(i18n$t("simdigraph"), i18n$t("pcsd"), i18n$t("pcsdindices"))),
                ),

      ),
      conditionalPanel(class = ("flex-container-resp detail"),
          condition = "input.graph_selector_laboratorio == 'simdigraph'",


            shinyjs::hidden(
              div(id = "simdig_inp",fileInput("simdigraph_wimp", i18n$t("Input file:"), accept = c(".xlsx")))),

            selectInput("simdigraph_layout", i18n$t("Layout:"),
                          choices = c(i18n$t("circle"), i18n$t("rtcircle"), i18n$t("tree"), i18n$t("graphopt"), i18n$t("mds"), i18n$t("grid")),
                          selected = i18n$t("circle")),

            selectInput("simdigraph_color", i18n$t("Color palette:"),
                          choices = c(i18n$t("red/green"), i18n$t("grey scale")),
                          selected = i18n$t("red/green")),

            numericInput("simdigraph_vertex_size", i18n$t("Vertex size:"), value = 1),

            numericInput("simdigraph_edge_width", i18n$t("Edge width:"), value = 1),

            numericInput("simdigraph_niter", i18n$t("Iteration number:"), value = 0),

            numericInput("simdigraph_max_iter", i18n$t("Maximum number of iterations:"), value = 30),

            numericInput("simdigraph_stop_iter", i18n$t("Number of iterations without changes:"), value = 3),

            #numericInput("simdigraph_act_vector", i18n$t("Change vector:"), value = 0, step = 0.01),

            selectInput("simdigraph_infer", i18n$t("Propagation function:"),
                          choices = c(i18n$t("linear transform"), i18n$t("another option")),
                          selected = i18n$t("linear transform")),

            selectInput("simdigraph_thr", i18n$t("Threshold function:"),
                          choices = c(i18n$t("linear"), i18n$t("another option")),
                          selected = i18n$t("linear")),

            numericInput("simdigraph_e", i18n$t("Differential value:"), value = 0.0001),
            rHandsontableOutput("simdigraph_act_vector")
        ),

        conditionalPanel(class = ("flex-container-resp detail"),
          condition = "input.graph_selector_laboratorio == 'pcsd'",

              #fileInput("pcsd_wimp", i18n$t("Input file:"), accept = c(".xlsx")),

              numericInput("pcsd_iter", i18n$t("Iteration number:"), value = 0),

              numericInput("pcsd_max_iter", i18n$t("Maximum number of iterations:"), value = 30),

              numericInput("pcsd_stop_iter", i18n$t("Number of iterations without changes:"), value = 3),

              #numericInput("pcsd_act_vector", i18n$t("Change vector:"), value = 0, step = 0.01),

              selectInput("pcsd_infer", i18n$t("Propagation function:"),
                          choices = c(i18n$t("linear transform"), i18n$t("another option")),
                          selected = i18n$t("linear transform")),

              selectInput("pcsd_thr", i18n$t("Threshold function:"),
                          choices = c(i18n$t("linear"), i18n$t("another option")),
                          selected = i18n$t("linear")),


              numericInput("pcsd_e", i18n$t("Differential value:"), value = 0.0001),
              rHandsontableOutput("pcsd_act_vector")
             ),

        conditionalPanel(class = ("flex-container-resp detail"),
          condition = "input.graph_selector_laboratorio == 'pcsdindices'",
              #selectInput("pcsdindices_wimp", i18n$t("Input file:"),
                          #choices = c(i18n$t("WimpGrid_data.xlsx"), i18n$t("data.csv"), i18n$t("datos.txt"))),

              selectInput("pcsdindices_infer", i18n$t("Propagation function:"),
                          choices = c(i18n$t("linear transform"), i18n$t("sigmoid transform"), i18n$t("binary transform")),
                          selected = i18n$t("linear transform")),

              selectInput("pcsdindices_thr", i18n$t("Threshold function:"),
                          choices = c(i18n$t("linear"), i18n$t("sigmoid"), i18n$t("binary")),
                          selected = i18n$t("linear")),

              #numericInput("pcsdindices_act_vector", i18n$t("Changes to simulate:"),
              #            value = 0, step = 0.01),
              numericInput("pcsdindices_max_iter", i18n$t("Maximum number of iterations:"), value = 30),
              numericInput("pcsdindices_e", i18n$t("Differential value:"), value = 0.0001),
              numericInput("pcsdindices_stop_iter", i18n$t("Number of iterations without changes:"), value = 3),
              rHandsontableOutput("pcsdindices_act_vector"),

              htmlOutput("convergence"),
              tabsetPanel(
                  tabPanel(i18n$t("Summary"), DT::dataTableOutput("summary")),
                  tabPanel(i18n$t("Auc"), DT::dataTableOutput("auc")),
                  tabPanel(i18n$t("Stability"), DT::dataTableOutput("stability"))
              )

            ),
          div(id = "pscd_showw",
            # Mostrar los datos de tabla_datos_repgrid
            plotlyOutput("pscd_show")
          ),
          div(id = "lab_showw",plotOutput("graph_output_laboratorio"))
      )
    )
  )

