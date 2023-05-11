repgrid_analisis_server <- function(input, output, session) {

  repgrid_data <- OpenRepGrid::importExcel("Servers/Repgrid_data.xlsx")
  indices_list <- gridindices(repgrid_data)
  # Generar gráfico bidimensional
  output$biplot2d_plot <- renderPlot({
    
    OpenRepGrid::biplot2d(repgrid_data, c.label.col = "#005440",c.grid = "gray", c.grid.lty = "dotted", c.grid.lwd = 0.5, cex.axis = 0.8, cex.labels = 0.8,)
  })

  # Generar gráfico tridimensional
  output$biplot3d_plot <- renderRglwidget({
   
    #OpenRepGrid::biplot3d(repgrid_data)
    
    try(close3d())
    #points3d(1:10, 1:10, 1:10)
    #axes3d()
    OpenRepGrid::biplot3d(boeker, c.label.col = "#005440")
    rglwidget()
    #try(close3d())
    #OpenRepGrid::biplot3d(repgrid_data)
    #points3d(1:10, 1:10, 1:10)
    #axes3d()
    #rglwidget()
  }, outputArgs = list(width = "auto", height = "300px"))

  # Generar análisis por conglomerados
  output$cluster_plot_1 <- renderPlot({
    
    OpenRepGrid::cluster(repgrid_data,along=1)
  })

  # Generar análisis por conglomerados
  output$cluster_plot_2 <- renderPlot({
    
    OpenRepGrid::cluster(repgrid_data,along=2)
  })


  # Generar tabla de índices y valores matemáticos
  output$gridindices_table <- renderText({
    
    PVEFF <- indices_list[["pvaff"]] 
    INT <- indices_list[["intensity"]][["Total"]] 
    CON <- indices_list[["conflict"]]
    BIA <- indices_list[["bias"]]
    knitr::kable(data.frame(PVEFF,INT,CON,BIA),col.names = c("PVAFF","Intensity","Conflicts","BIAS"),format = "html") %>%
    kable_styling("striped", full_width = T) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") %>%
    column_spec(1, bold = T, color = "#005440", width = "25%") %>%
    column_spec(2, width = "25%") %>%
    column_spec(3, width = "25%") %>%
    column_spec(4, width = "25%")
  })
  
  output$construct <- renderText({
    
    INTc <- indices_list[["intensity"]][["Constructs"]] 

    knitr::kable(INTc, col.names = "Intensity",format = "html") %>%
    kable_styling("striped", full_width = F) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") %>%
    column_spec(1, bold = T, color = "#005440")
  })


 output$elementss <- renderText({
    
    INTe <- indices_list[["intensity"]][["Elements"]] 
    knitr::kable(INTe, col.names = "Intensity",format = "html") %>%
    kable_styling("striped", full_width = F) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") %>%
    column_spec(1, bold = T, color = "#005440")
  })


  output$constructs <- renderText({
    
    INTc <- indices_list[["dilemmas"]][["Constructs"]] #Constructs congruency

    knitr::kable(INTc, col.names = "Intensity",format = "html") %>%
    kable_styling("striped", full_width = F) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") %>%
    column_spec(1, bold = T, color = "#005440")
  })


  output$dilemmasss <- renderText({
    
    INTc <- indices_list[["dilemmas"]][["Elements"]] #dilemmas

    knitr::kable(INTc, col.names = "Intensity",format = "html") %>%
    kable_styling("striped", full_width = F) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") %>%
    column_spec(1, bold = T, color = "#005440")
  })

  

}
