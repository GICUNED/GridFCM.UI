#source("global.R")
wimpgrid_analysis_ui <- fluidPage(
    #shiny.i18n::usei18n(i18n),
    h1(i18n$t("Wimpgrid Analysis")),

    tabsetPanel(
      tabPanel(i18n$t("Visualization"), id = "tab_visualizacion",
        selectInput("graph_selector_visualizacion",
                    i18n$t("Select a graph:"),
                    choices = c(i18n$t("selfdigraph"), i18n$t("idealdigraph"), i18n$t("wimpindices"))),
        conditionalPanel(condition = "input.graph_selector_visualizacion == 'selfdigraph'",
                         selectInput("selfdigraph_layout", i18n$t("Layout:"),
                                     choices = c(i18n$t("circle"), i18n$t("rtcircle"), i18n$t("tree"), i18n$t("graphopt"), i18n$t("mds"), i18n$t("grid")),
                                     selected = i18n$t("circle")),
                         numericInput("selfdigraph_vertex_size", i18n$t("Vertex size:"), value = 1),
                         numericInput("selfdigraph_edge_width", i18n$t("Edge width:"), value = 1),
                         selectInput("selfdigraph_color", i18n$t("Color palette:"),
                                     choices = c(i18n$t("red/green"), i18n$t("grey scale")),
                                     selected = i18n$t("red/green"))
        ),
        conditionalPanel(condition = "input.graph_selector_visualizacion == 'idealdigraph'",
                         checkboxInput("idealdigraph_inc", i18n$t("Hide direct relationships"), value = FALSE),
                         selectInput("idealdigraph_layout", i18n$t("Layout:"),
                                     choices = c(i18n$t("circle"), i18n$t("rtcircle"), i18n$t("tree"), i18n$t("graphopt"), i18n$t("mds"), i18n$t("grid")),
                                     selected = i18n$t("circle")),
                         numericInput("idealdigraph_vertex_size", i18n$t("Vertex size:"), value = 1),
                         numericInput("idealdigraph_edge_width", i18n$t("Edge width:"), value = 1),
                         selectInput("idealdigraph_color", i18n$t("Color palette:"),
                                     choices = c(i18n$t("red/green"), i18n$t("grey scale")),
                                     selected = i18n$t("red/green"))
        ),
        plotOutput("graph_output_visualizacion")
      ),
      tabPanel(i18n$t("Laboratory"), id = "tab_laboratorio",
        selectInput("graph_selector_laboratorio",
                    i18n$t("Select a graph:"),
                    choices = c(i18n$t("simdigraph"), i18n$t("pcsd"), i18n$t("pcsdindices"))),
        conditionalPanel(
          condition = "input.graph_selector_laboratorio == 'simdigraph'",
              numericInput("simdigraph_niter", i18n$t("Iteration number:"), value = 0),
              selectInput("simdigraph_layout", i18n$t("Layout:"),
                          choices = c(i18n$t("circle"), i18n$t("rtcircle"), i18n$t("tree"), i18n$t("graphopt"), i18n$t("mds"), i18n$t("grid")),
                          selected = i18n$t("circle")),
              numericInput("simdigraph_vertex_size", i18n$t("Vertex size:"), value = 1),
              numericInput("simdigraph_edge_width", i18n$t("Edge width:"), value = 1),
              selectInput("simdigraph_color", i18n$t("Color palette:"),
                          choices = c(i18n$t("red/green"), i18n$t("grey scale")),
                          selected = i18n$t("red/green")),
              fileInput("simdigraph_wimp", i18n$t("Input file:"), accept = c(".xlsx")),
              numericInput("simdigraph_act_vector", i18n$t("Change vector:"), value = 0, step = 0.01),
              selectInput("simdigraph_infer", i18n$t("Propagation function:"),
                          choices = c(i18n$t("linear transform"), i18n$t("another option")),
                          selected = i18n$t("linear transform")),
              selectInput("simdigraph_thr", i18n$t("Threshold function:"),
                          choices = c(i18n$t("linear"), i18n$t("another option")),
                          selected = i18n$t("linear")),
              numericInput("simdigraph_max_iter", i18n$t("Maximum number of iterations:"), value = 30),
              numericInput("simdigraph_e", i18n$t("Differential value:"), value = 0.0001),
              numericInput("simdigraph_stop_iter", i18n$t("Number of iterations without changes:"), value = 3)
            ),
        conditionalPanel(
          condition = "input.graph_selector_laboratorio == 'pcsd'",
              numericInput("pcsd_iter", i18n$t("Iteration number:"), value = 0),
              fileInput("pcsd_wimp", i18n$t("Input file:"), accept = c(".xlsx")),
              numericInput("pcsd_act_vector", i18n$t("Change vector:"), value = 0, step = 0.01),
              selectInput("pcsd_infer", i18n$t("Propagation function:"),
                          choices = c(i18n$t("linear transform"), i18n$t("another option")),
                          selected = i18n$t("linear transform")),
              selectInput("pcsd_thr", i18n$t("Threshold function:"),
                          choices = c(i18n$t("linear"), i18n$t("another option")),
                          selected = i18n$t("linear")),
              numericInput("pcsd_max_iter", i18n$t("Maximum number of iterations:"), value = 30),
              numericInput("pcsd_e", i18n$t("Differential value:"), value = 0.0001),
              numericInput("pcsd_stop_iter", i18n$t("Number of iterations without changes:"), value = 3)
            ),
        conditionalPanel(
          condition = "input.graph_selector_laboratorio == 'pcsdindices'",
              selectInput("pcsdindices_wimp", i18n$t("Input file:"),
                          choices = c(i18n$t("WimpGrid_data.xlsx"), i18n$t("data.csv"), i18n$t("datos.txt"))),
              numericInput("pcsdindices_act_vector", i18n$t("Changes to simulate:"),
                          value = 0, step = 0.01),
              selectInput("pcsdindices_infer", i18n$t("Propagation function:"),
                          choices = c(i18n$t("linear transform"), i18n$t("sigmoid transform"), i18n$t("binary transform")),
                          selected = i18n$t("linear transform")),
              selectInput("pcsdindices_thr", i18n$t("Threshold function:"),
                          choices = c(i18n$t("linear"), i18n$t("sigmoid"), i18n$t("binary")),
                          selected = i18n$t("linear")),
              numericInput("pcsdindices_max_iter", i18n$t("Maximum number of iterations:"), value = 30),
              numericInput("pcsdindices_e", i18n$t("Differential value:"), value = 0.0001),
              numericInput("pcsdindices_stop_iter", i18n$t("Number of iterations without changes:"), value = 3)
            ),

      
          div(id = "pscd_showw",
            # Mostrar los datos de tabla_datos_repgrid
            plotlyOutput("pscd_show")
          ),
        

          div(id = "lab_showw",plotOutput("graph_output_laboratorio"))
      )
    )
  )

