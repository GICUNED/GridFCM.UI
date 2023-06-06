wimpgrid_analysis_server <- function(input, output, session) {
# Lógica para la pestaña "Visualización"
dataaa <- importwimp("WimpGrid_data.xlsx")
print(dataaa)
scn <- scenariomatrix(dataaa,c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
#VARIABLES OF THE FORM

selfdigraph_layout <- reactiveVal("circle")
selfdigraph_vertex_size <- reactiveVal(1)
selfdigraph_edge_width <- reactiveVal(1)
selfdigraph_color <- reactiveVal("red/green")

idealdigraph_inc <- reactiveVal(FALSE)
idealdigraph_layout <- reactiveVal("circle")
idealdigraph_vertex_size <- reactiveVal(1)
idealdigraph_edge_width <- reactiveVal(1)
idealdigraph_color <- reactiveVal("red/green")
 
observeEvent(input$tab_visualizacion, {
    
})

# Observer event para el input layout de selfdigraph
observeEvent(input$selfdigraph_layout, {
  selfdigraph_layout(input$selfdigraph_layout)           
})

# Observer event para el input vertex.size de selfdigraph
observeEvent(input$selfdigraph_vertex_size, {
  selfdigraph_vertex_size(input$selfdigraph_vertex_size)
})

# Observer event para el input edge.width de selfdigraph
observeEvent(input$selfdigraph_edge_width, {
  selfdigraph_edge_width(input$selfdigraph_edge_width)
})

# Observer event para el input color de selfdigraph
observeEvent(input$selfdigraph_color, {
  selfdigraph_color(input$selfdigraph_color)
})

# Observer event para el input inc de idealdigraph
observeEvent(input$idealdigraph_inc, {
  idealdigraph_inc(input$idealdigraph_inc)
})

# Observer event para el input layout de idealdigraph
observeEvent(input$idealdigraph_layout, {
  idealdigraph_layout(input$idealdigraph_layout)
})

# Observer event para el input vertex.size de idealdigraph
observeEvent(input$idealdigraph_vertex_size, {
  idealdigraph_vertex_size(input$idealdigraph_vertex_size)
})

# Observer event para el input edge.width de idealdigraph
observeEvent(input$idealdigraph_edge_width, {
  idealdigraph_edge_width(input$idealdigraph_edge_width)
})

# Observer event para el input color de idealdigraph
observeEvent(input$idealdigraph_color, {
  idealdigraph_color(input$idealdigraph_color)
})

# Lógica para mostrar los resultados de selfdigraph()
observeEvent(input$graph_selector_visualizacion, {
  graph <- input$graph_selector_visualizacion
})

# Definir la lógica del servidor para la aplicación
output$graph_output_visualizacion <- renderPlot({
  # Verificar que input$graph_selector_visualizacion no es NULL
  req(input$graph_selector_visualizacion)

  # Asignar el input a una variable
  graph <- input$graph_selector_visualizacion
  print("grapfh selected in view")
  print(graph)
  # Dependiendo de la selección del usuario, dibuja el gráfico correspondiente
  if (graph == "selfdigraph") {
    selfdigraph(dataaa, layout = selfdigraph_layout(), vertex.size = selfdigraph_vertex_size(),edge.width = selfdigraph_edge_width(), color = selfdigraph_color())
  } else if (graph == "idealdigraph") {
    idealdigraph(dataaa, inc = idealdigraph_inc(), layout = idealdigraph_layout(), vertex.size = idealdigraph_vertex_size(), edge.width = idealdigraph_edge_width(),color = idealdigraph_color())
  } else if (graph == "wimpindices") {
    print("wimpindices")
    # Get column names
    column_names <- names(wimpindices(dataaa))

    # Print column names
    cat("Columns:", paste(column_names, collapse = ", "))
    print(wimpindices(dataaa)[["distance"]])
        #wimpindices(dataaa)
  }
})
output$dens <- renderText({

    INTe <- wimpindices(dataaa)[["density"]]
    knitr::kable(INTe, col.names = "density",format = "html") %>%
    kable_styling("striped", full_width = F) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") %>%
    column_spec(1, bold = T, color = "#005440")
})
output$distance <- DT::renderDataTable({

    INTe <- wimpindices(dataaa)[["distance"]]
    DT::datatable(INTe)
})
centrality <- wimpindices(dataaa)[["centrality"]]

  # Creamos las tablas dinámicas para cada subconjunto
  output$table_degree <- DT::renderDataTable({
    DT::datatable(centrality$degree)
  })
  
  output$table_closeness <- DT::renderDataTable({
    DT::datatable(centrality$closeness)
  })
  
  output$table_betweenness <- DT::renderDataTable({
    DT::datatable(centrality$betweenness)
  })
output$inconsistences <- DT::renderDataTable({

    INTe <- wimpindices(dataaa)[["inconsistences"]]
     DT::datatable(INTe)
})

# Variables reactivas para almacenar los cambios de los inputs de simdigraph

simdigraph_niter <- reactiveVal(0)
simdigraph_layout <- reactiveVal("circle")
simdigraph_vertex_size <- reactiveVal(1)
simdigraph_edge_width <- reactiveVal(1)
simdigraph_color <- reactiveVal("red/green")

simdigraph_wimp <- reactiveVal()
simdigraph_act_vector <- reactiveVal(0)
simdigraph_infer <- reactiveVal("linear transform")
simdigraph_thr <- reactiveVal("linear")
simdigraph_max_iter <- reactiveVal(30)
simdigraph_e <- reactiveVal(0.0001)
simdigraph_stop_iter <- reactiveVal(3)

# Variables reactivas para almacenar los cambios de los inputs de pcsdindices
  act_vector <- reactiveVal()
  infer <- reactiveVal("linear transform")
  thr <- reactiveVal("linear")
  max_iter <- reactiveVal(30)
  e <- reactiveVal(0.0001)
  stop_iter <- reactiveVal(3)

  # Variables reactivas para almacenar los cambios de los inputs de pscd
  pscd_iter <- reactiveVal(0)
  pscd_wimp <- reactiveVal()
  pscd_act_vector <- reactiveVal(0)
  pscd_infer <- reactiveVal("linear transform")
  pscd_thr <- reactiveVal("linear")
  pscd_max_iter <- reactiveVal(30)
  pscd_e <- reactiveVal(0.0001)
  pscd_stop_iter <- reactiveVal(3)

# Lógica para la pestaña "Laboratorio"
observeEvent(input$tab_laboratorio, {
        
})

# Observer event para el input niter de simdigraph
observeEvent(input$simdigraph_niter, {
  simdigraph_niter(input$simdigraph_niter)
})

# Observer event para el input layout de simdigraph
observeEvent(input$simdigraph_layout, {
  simdigraph_layout(input$simdigraph_layout)
})

# Observer event para el input vertex.size de simdigraph
observeEvent(input$simdigraph_vertex_size, {
  simdigraph_vertex_size(input$simdigraph_vertex_size)
})

# Observer event para el input edge.width de simdigraph
observeEvent(input$simdigraph_edge_width, {
  simdigraph_edge_width(input$simdigraph_edge_width)
})

# Observer event para el input color de simdigraph
observeEvent(input$simdigraph_color, {
  simdigraph_color(input$simdigraph_color)
})

# Observer event para el input wimp de simdigraph
observeEvent(input$simdigraph_wimp, {
  simdigraph_wimp(input$simdigraph_wimp)
})

# Observer event para el input act.vector de simdigraph
observeEvent(input$simdigraph_act_vector, {
  simdigraph_act_vector(input$simdigraph_act_vector)
})

# Observer event para el input infer de simdigraph
observeEvent(input$simdigraph_infer, {
  simdigraph_infer(input$simdigraph_infer)
})

# Observer event para el input thr de simdigraph
observeEvent(input$simdigraph_thr, {
  simdigraph_thr(input$simdigraph_thr)
})

# Observer event para el input max.iter de simdigraph
observeEvent(input$simdigraph_max_iter, {
  simdigraph_max_iter(input$simdigraph_max_iter)
})

# Observer event para el input e de simdigraph
observeEvent(input$simdigraph_e, {
  simdigraph_e(input$simdigraph_e)
})

# Observer event para el input stop.iter de simdigraph
observeEvent(input$simdigraph_stop_iter, {
  simdigraph_stop_iter(input$simdigraph_stop_iter)
})

# Observer event para el input act.vector de pcsdindices
observeEvent(input$pcsdindices_act_vector, {
  act_vector(input$pcsdindices_act_vector)
})

# Observer event para el input infer de pcsdindices
observeEvent(input$pcsdindices_infer, {
  infer(input$pcsdindices_infer)
})

# Observer event para el input thr de pcsdindices
observeEvent(input$pcsdindices_thr, {
  thr(input$pcsdindices_thr)
})

# Observer event para el input max.iter de pcsdindices
observeEvent(input$pcsdindices_max_iter, {
  max_iter(input$pcsdindices_max_iter)
})

# Observer event para el input e de pcsdindices
observeEvent(input$pcsdindices_e, {
  e(input$pcsdindices_e)
})

# Observer event para el input stop.iter de pcsdindices
observeEvent(input$pcsdindices_stop_iter, {
  stop_iter(input$pcsdindices_stop_iter)
})


# Observer event para el input iter de pscd
observeEvent(input$pscd_iter, {
  pscd_iter(input$pscd_iter)
})

# Observer event para el input wimp de pscd
observeEvent(input$pscd_wimp, {
  pscd_wimp(input$pscd_wimp)
})

# Observer event para el input act.vector de pscd
observeEvent(input$pscd_act_vector, {
  pscd_act_vector(input$pscd_act_vector)
})

# Observer event para el input infer de pscd
observeEvent(input$pscd_infer, {
  pscd_infer(input$pscd_infer)
})

# Observer event para el input thr de pscd
observeEvent(input$pscd_thr, {
  pscd_thr(input$pscd_thr)
})

# Observer event para el input max.iter de pscd
observeEvent(input$pscd_max_iter, {
  pscd_max_iter(input$pscd_max_iter)
})

# Observer event para el input e de pscd
observeEvent(input$pscd_e, {
  pscd_e(input$pscd_e)
})

# Observer event para el input stop.iter de pscd
observeEvent(input$pscd_stop_iter, {
  pscd_stop_iter(input$pscd_stop_iter)
})

    
# Lógica para mostrar los resultados de simdigraph()
observeEvent(input$graph_selector_laboratorio, {
  graph <- input$graph_selector_laboratorio
})

output$graph_output_laboratorio <- renderPlot({
# Verificar que input$graph_selector_visualizacion no es NULL
req(input$graph_selector_laboratorio)

# Asignar el input a una variable
graph <- input$graph_selector_laboratorio

# Dependiendo de la selección del usuario, dibuja el gráfico correspondiente
print("grapfh selected in laboratory")
print(graph)
if (graph == "simdigraph") {
  shinyjs::show("lab_showw")
  shinyjs::hide("pscd_showw")
  sim_stop_it <- simdigraph_stop_iter()
  scn <- scenariomatrix(dataaa,act.vector= c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),infer = simdigraph_infer(),
                           thr = simdigraph_thr(), max.iter = simdigraph_max_iter(), e = simdigraph_e(),
                           stop.iter = sim_stop_it)
  simdigraph(scn,niter=simdigraph_niter(), layout = simdigraph_layout(), vertex.size = simdigraph_vertex_size(),edge.width = simdigraph_edge_width(), color = simdigraph_color())
  
  
} else if (graph == "pcsd") {
  #pscd_stop_it <- pscd_stop_iter()
  # <- scenariomatrix(dataaa,act.vector= c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),infer = pscd_infer(),
                  #         thr = pscd_thr(), max.iter = pscd_max_iter(), e = pscd_e(),
                  #         stop.iter = pscd_stop_it)
  #pscdit <- pscd_iter()                       
  #pcsd(scn, vline =pscdit)
  shinyjs::hide("lab_showw")
  shinyjs::show("pscd_showw")
  
} else if (graph == "pcsdindices") {
  shinyjs::show("lab_showw")
  shinyjs::hide("pscd_showw")
  scn <- scenariomatrix(dataaa,act.vector= c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),infer = infer(),
                           thr = thr(), max.iter = max_iter(), e = e(),
                           stop.iter = stop_iter())
  pcsdindices(scn)
 
  
}
})

output$pscd_show <- renderPlotly({
  req(input$graph_selector_laboratorio)

# Asignar el input a una variable
graph <- input$graph_selector_laboratorio
  if (graph == "pcsd") {

    shinyjs::hide("lab_showw")
    shinyjs::show("pscd_showw")
  pscd_stop_it <- pscd_stop_iter()
  scn <- scenariomatrix(dataaa,act.vector= c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),infer = pscd_infer(),
                           thr = pscd_thr(), max.iter = pscd_max_iter(), e = pscd_e(),
                           stop.iter = pscd_stop_it)
  pscdit <- pscd_iter()                       
  pcsd(scn, vline =pscdit)
   
  } else {
    shinyjs::show("lab_showw")
    shinyjs::hide("pscd_showw")
  }
})

}
