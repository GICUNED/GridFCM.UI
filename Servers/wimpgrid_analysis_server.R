wimpgrid_analysis_server <- function(input, output, session) {
  # Lógica para la pestaña "Visualización"
  dataaa <- importwimp("WimpGrid_data.xlsx")
  print(dataaa)
  observeEvent(input$tab_visualizacion, {
    # Variables para almacenar los cambios de los inputs
    selfdigraph_layout <- reactiveVal("circle")
    selfdigraph_vertex_size <- reactiveVal(1)
    selfdigraph_edge_width <- reactiveVal(1)
    selfdigraph_color <- reactiveVal("red/green")
    
    idealdigraph_inc <- reactiveVal(FALSE)
    idealdigraph_layout <- reactiveVal("circle")
    idealdigraph_vertex_size <- reactiveVal(1)
    idealdigraph_edge_width <- reactiveVal(1)
    idealdigraph_color <- reactiveVal("red/green")
    
    # Observer event para el input layout de selfdigraph
    observeEvent(input$selfdigraph_layout, {
      selfdigraph_layout(input$selfdigraph_layout)
      a <- selfdigraph(dataaa, layout = selfdigraph_layout(), vertex.size = selfdigraph_vertex_size(),edge.width = selfdigraph_edge_width(), color = selfdigraph_color())
           print(a)
           print("fd")
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
      output$graph_output_visualizacion <- renderPlot({
        if (graph == "selfdigraph") {
           a <- selfdigraph(dataaa, layout = selfdigraph_layout(), vertex.size = selfdigraph_vertex_size(),edge.width = selfdigraph_edge_width(), color = selfdigraph_color())
           print(a)
        } else if (graph == "idealdigraph") {
          #idealdigraph(dataaa, inc = idealdigraph_inc(), layout = idealdigraph_layout(), vertex.size = idealdigraph_vertex_size(), edge.width = idealdigraph_edge_width(),color = idealdigraph_color())
        } else if (graph == "wimpindices") {
          #wimpindices(dataaa)
        }
      })
    })
  })

  # Lógica para la pestaña "Laboratorio"
observeEvent(input$tab_laboratorio, {
      
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


      # Variables reactivas para almacenar los cambios de los inputs de pcsdindices
  act_vector <- reactiveVal()
  infer <- reactiveVal("linear transform")
  thr <- reactiveVal("linear")
  max_iter <- reactiveVal(30)
  e <- reactiveVal(0.0001)
  stop_iter <- reactiveVal(3)

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

  # Variables reactivas para almacenar los cambios de los inputs de pscd
  pscd_iter <- reactiveVal(0)
  pscd_wimp <- reactiveVal()
  pscd_act_vector <- reactiveVal(0)
  pscd_infer <- reactiveVal("linear transform")
  pscd_thr <- reactiveVal("linear")
  pscd_max_iter <- reactiveVal(30)
  pscd_e <- reactiveVal(0.0001)
  pscd_stop_iter <- reactiveVal(3)

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
        output$graph_output_laboratorio <- renderPlot({
          if (graph == "simdigraph") {
            #simdigraph(dataaa, layout = simdigraph_layout(), vertex.size = simdigraph_vertex_size(),edge.width = simdigraph_edge_width(), color = simdigraph_color())
          } else if (graph == "pcsd") {
            #pcsd(dataaa, inc = pcsd_inc(), layout = pcsd_layout(), vertex.size = pcsd_vertex_size(),edge.width = pcsd_edge_width(), color = pcsd_color())
          } else if (graph == "pcsdindices") {
            #pcsdindices(dataaa)
          }
        })
      })
    })
  }
