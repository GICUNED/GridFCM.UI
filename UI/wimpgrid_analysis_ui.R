# UI de Wimpgrid.analysis
wimpgrid_analysis_ui <- fluidPage(
  h1("Análisis de Wimpgrid"),

  tabsetPanel(
    tabPanel("Visualización", id = "tab_visualizacion",
      # Mostrar los resultados de selfdigraph()
      # Agregar inputs para manipular el aspecto visual del digrafo
      # plotOutput("selfdigraphh"),
      # Mostrar los resultados de idealdigraph()
      # plotOutput("idealdigraphh"),
      # Agregar inputs para manipular el aspecto visual del digrafo
      # checkboxInput("mostrar_relaciones_inversas", "Mostrar relaciones inversas", value = FALSE),

      # Mostrar los resultados de wimpindices()
      # plotOutput("wimpindicess"),
      # Mostrar tablas con los índices matemáticos

      selectInput("graph_selector_visualizacion",
                  "Seleccione un gráfico:",
                  choices = c("selfdigraph", "idealdigraph", "wimpindices")),
      conditionalPanel(condition = "input.graph_selector_visualizacion == 'selfdigraph'",
                       selectInput("selfdigraph_layout", "Layout:",
                                   choices = c("circle", "rtcircle", "tree", "graphopt", "mds", "grid"),
                                   selected = "circle"),
                       numericInput("selfdigraph_vertex_size", "Tamaño de los vértices:", value = 1),
                       numericInput("selfdigraph_edge_width", "Ancho de las aristas:", value = 1),
                       selectInput("selfdigraph_color", "Paleta de colores:",
                                   choices = c("red/green", "grey scale"),
                                   selected = "red/green")
      ),
      conditionalPanel(condition = "input.graph_selector_visualizacion == 'idealdigraph'",
                       checkboxInput("idealdigraph_inc", "Ocultar relaciones directas", value = FALSE),
                       selectInput("idealdigraph_layout", "Layout:",
                                   choices = c("circle", "rtcircle", "tree", "graphopt", "mds", "grid"),
                                   selected = "circle"),
                       numericInput("idealdigraph_vertex_size", "Tamaño de los vértices:", value = 1),
                       numericInput("idealdigraph_edge_width", "Ancho de las aristas:", value = 1),
                       selectInput("idealdigraph_color", "Paleta de colores:",
                                   choices = c("red/green", "grey scale"),
                                   selected = "red/green")
      ),
      plotOutput("graph_output_visualizacion")
    ),
    tabPanel("Laboratorio", id = "tab_laboratorio",
     
      selectInput("graph_selector_laboratorio",
                  "Seleccione un gráfico:",
                  choices = c("simdigraph", "pcsd", "pcsdindices")),
      conditionalPanel(condition = "input.graph_selector_laboratorio == 'simdigraph'",
  numericInput("simdigraph_niter", "Número de la iteración:", value = 0),
  selectInput("simdigraph_layout", "Layout:",
              choices = c("circle", "rtcircle", "tree", "graphopt", "mds", "grid"),
              selected = "circle"),
  numericInput("simdigraph_vertex_size", "Tamaño de los vértices:", value = 1),
  numericInput("simdigraph_edge_width", "Ancho de las aristas:", value = 1),
  selectInput("simdigraph_color", "Paleta de colores:",
              choices = c("red/green", "grey scale"),
              selected = "red/green"),
  fileInput("simdigraph_wimp", "Archivo de entrada:", accept = c(".xlsx")),
  numericInput("simdigraph_act_vector", "Vector de cambios:", value = 0, step = 0.01),
  selectInput("simdigraph_infer", "Función de propagación:",
              choices = c("linear transform", "otra opción"),
              selected = "linear transform"),
  selectInput("simdigraph_thr", "Función umbral:",
              choices = c("linear", "otra opción"),
              selected = "linear"),
  numericInput("simdigraph_max_iter", "Número de iteraciones máximas:", value = 30),
  numericInput("simdigraph_e", "Valor diferencial:", value = 0.0001),
  numericInput("simdigraph_stop_iter", "Número de iteraciones sin cambios:", value = 3)
)
,
      conditionalPanel(condition = "input.graph_selector_laboratorio == 'pcsd'",
                 numericInput("pcsd_iter", "Número de la iteración:", value = 0),
                 fileInput("pcsd_wimp", "Archivo de entrada:", accept = c(".xlsx")),
                 numericInput("pcsd_act_vector", "Vector de cambios:", value = 0, step = 0.01),
                 selectInput("pcsd_infer", "Función de propagación:",
                             choices = c("linear transform", "otra opción"),
                             selected = "linear transform"),
                 selectInput("pcsd_thr", "Función umbral:",
                             choices = c("linear", "otra opción"),
                             selected = "linear"),
                 numericInput("pcsd_max_iter", "Número de iteraciones máximas:", value = 30),
                 numericInput("pcsd_e", "Valor diferencial:", value = 0.0001),
                 numericInput("pcsd_stop_iter", "Número de iteraciones sin cambios:", value = 3)
)
,
      conditionalPanel(condition = "input.graph_selector_laboratorio == 'pcsdindices'",
        selectInput("pcsdindices_wimp", "Archivo de entrada:",
                    choices = c("WimpGrid_data.xlsx", "data.csv", "datos.txt")),
        numericInput("pcsdindices_act_vector", "Cambios a simular:",
                    value = 0, step = 0.01),
        selectInput("pcsdindices_infer", "Función de propagación:",
                    choices = c("linear transform", "sigmoid transform", "exponential transform"),
                    selected = "linear transform"),
        selectInput("pcsdindices_thr", "Función umbral:",
                    choices = c("linear", "sigmoid", "exponential"),
                    selected = "linear"),
        numericInput("pcsdindices_max_iter", "Número de iteraciones máximas:", value = 30),
        numericInput("pcsdindices_e", "Valor diferencial:", value = 0.0001),
        numericInput("pcsdindices_stop_iter", "Número de iteraciones sin cambios:", value = 3)
      )
,
      plotOutput("graph_output_laboratorio")
    )
  )
)
