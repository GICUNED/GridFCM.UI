repgrid_analisis_server <- function(input, output, session) {

  
  #if (is.null(session$userData$datos_repgrid)) {
  #  datos_control <- 0
  #  indice_control <- 0
 # }else{
    #datos_control <- session$userData$datos_repgrid
   # indice_control <-  gridindices(datos_control)
   #}
   

  repgrid_data <- session$userData$datos_repgrid
  print(repgrid_data)
  if (is.null(session$userData$datos_repgrid))
  {
    runjs("window.location.href = '/#!/import';")
    show("repgrid_warning")
    repgrid_data <-boeker
  } else {
    print("hide")
    hide("repgrid_warning")
  }

  indices_list <- gridindices(repgrid_data)

  output$biplot2d_plot <- renderPlot({
    
      OpenRepGrid::biplot2d(repgrid_data, c.label.col = "#005440",c.grid = "gray", c.grid.lty = "dotted", c.grid.lwd = 0.5, cex.axis = 0.8, cex.labels = 0.8,)
    
})

  # Generar gráfico tridimensional
  output$biplot3d_plot <- renderRglwidget({
   
    #OpenRepGrid::biplot3d(repgrid_data)
    
    try(close3d())
    #points3d(1:10, 1:10, 1:10)
    #axes3d()
    OpenRepGrid::biplot3d(repgrid_data)
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
     #indices_list[["distances"]][["Constructs"]] 
    
  })

  

  # Generar análisis por conglomerados
  output$cluster_plot_2 <- renderPlot({
    
    OpenRepGrid::cluster(repgrid_data,along=2)
    #indices_list[["distances"]][["Elements"]] 
    
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
    column_spec(1, bold = T, width = "25%") %>%
    column_spec(2, width = "25%") %>%
    column_spec(3, width = "25%") %>%
    column_spec(4, width = "25%")
    
  })
  
  output$construct <- renderText({
    
    INTc <- indices_list[["intensity"]][["Constructs"]] 

    knitr::kable(INTc, col.names = "Intensity",format = "html") %>%
    kable_styling("striped", full_width = F) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") %>%
    column_spec(1, bold = T)
    
  })


 output$elementss <- renderText({
    
    INTe <- indices_list[["intensity"]][["Elements"]] 
    knitr::kable(INTe, col.names = "Intensity",format = "html") %>%
    kable_styling("striped", full_width = F) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") %>%
    column_spec(1, bold = T)
    
  })


  output$constructs <- renderText({
    
    INTc <- indices_list[["dilemmas"]][["Congruency"]] #Constructs congruency
    INTc <- indexDilemma(repgrid_data,self=1,ideal=13, diff.congruent = 1, diff.discrepant = 4)
    print("dilemmmmmmmm")
    print(INTc$construct_classification)
    #print(indexDilemma(repgrid_data)[[1]])
    knitr::kable(INTc$construct_classification,format = "html") %>%
    #knitr::kable(INTc, col.names = "Intensity",format = "html") %>%
    kable_styling("striped", full_width = F) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") %>%
    column_spec(1, bold = T)
    
  })


  output$dilemmasss <- renderText({
    
    INTc <- indices_list[["dilemmas"]][["Dilemmas"]] #dilemmas
    INTc <- indexDilemma(repgrid_data,self=1,ideal=13, diff.congruent = 1, diff.discrepant = 4)
    print("dilemmmmmmmm")
    print(INTc$dilemmas_df)
    dilemmas_df <- INTc$dilemmas_df
    
    if (nrow(dilemmas_df) > 0) {

      dilemmas_df <- dilemmas_df %>% select(-id_c, -id_d)
      dilemmas_df$R <- round(dilemmas_df$R, 2) # digits
      ii <- str_detect(dilemmas_df$RexSI, "\\.")
      dilemmas_df$RexSI[ii] <- as.character(round(as.numeric(dilemmas_df$RexSI[ii]), digits))
      
      print(dilemmas_df)
      
      knitr::kable(dilemmas_df,format = "html") %>%
      #knitr::kable(INTc, col.names = "Intensity",format = "html") %>%
      kable_styling("striped", full_width = F) %>%
      row_spec(0, bold = T, color = "white", background = "#005440") %>%
      column_spec(1, bold = T)
      #cat("\n\tR = Correlation including Self & Ideal")
      #cat("\n\tRexSI = Correlation excluding Self & Ideal")
      #cor.used <- ifelse(exclude, "RexSI", "R")
      #cat("\n\t", cor.used, " was used as criterion", sep = "")
    } else {
      "No implicative dilemmas detected"
    }
    #knitr::kable(INTc$construct_classification,format = "html") %>%
    #knitr::kable(INTc, col.names = "Intensity",format = "html") %>%
    #kable_styling("striped", full_width = F) #%>%
    #row_spec(0, bold = T, color = "white", background = "#005440") %>%
    #column_spec(1, bold = T, color = "#005440")
  })

  

}
