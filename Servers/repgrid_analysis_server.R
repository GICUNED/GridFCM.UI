repgrid_analisis_server <- function(input, output, session) {

  observeEvent(input$importar_page_r, {
    # Navega a la página de creación de un nuevo análisis de rejilla
    # route_link("nombre_de_la_pagina_de_creacion")
    runjs("window.location.href = '/#!/import';")
    runjs("
      $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');

      $('.user-page')
        .find('.nav-link')
        .removeClass('active');

      $('#import-page')
        .find('.nav-link')
        .addClass('active');
    ")
  })

  
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
    repgrid_data <-boeker
  }

  indices_list <- gridindices(repgrid_data)

  output$biplot2d_plot <- renderPlot({
    
      OpenRepGrid::biplot2d(repgrid_data, c.label.col = "#005440",c.grid = "gray", c.grid.lty = "dotted", c.grid.lwd = 0.5, cex.axis = 0.8, cex.labels = 0.8,)
    
  })

  output$btn_download_2d <- downloadHandler(
    filename = function() {
      "grafico_bidimensional.png"
    },
    content = function(file) {
      # Tomar una captura de pantalla del gráfico y guardarla en un archivo PNG
      grDevices::png(file, width = 1200, height = 1200, units = "px", res = 100)
      grDevices::dev.capture(OpenRepGrid::biplot2d(repgrid_data, c.label.col = "#005440", c.grid = "gray", c.grid.lty = "dotted", c.grid.lwd = 0.5, cex.axis = 0.8, cex.labels = 0.8))
      grDevices::dev.off()
      file.copy("Rplot001.png", file)  # Copiar el archivo temporal a la ubicación deseada
      file.remove("Rplot001.png")  # Eliminar el archivo temporal
    }
  )

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

  output$matrix_constructs <- renderRHandsontable({
    rhandsontable(indices_list[["distances"]][["Constructs"]])
  })

  output$matrix_elements <- renderRHandsontable({
    rhandsontable(indices_list[["distances"]][["Elements"]])
  })

  output$btn_download_cluster1 <- downloadHandler(
    filename = function() {
      "constructos.png"
    },
    content = function(file) {
      # Tomar una captura de pantalla del gráfico y guardarla en un archivo PNG
      grDevices::png(file, width = 1200, height = 800, units = "px", res = 100)
      grDevices::dev.capture(OpenRepGrid::cluster(repgrid_data,along=1))
      grDevices::dev.off()
      file.copy("Rplot001.png", file)  # Copiar el archivo temporal a la ubicación deseada
      file.remove("Rplot001.png")  # Eliminar el archivo temporal
    }
  )

  # Generar análisis por conglomerados
  output$cluster_plot_2 <- renderPlot({
    
    OpenRepGrid::cluster(repgrid_data,along=2)
    #indices_list[["distances"]][["Elements"]] 
    
  })

  output$btn_download_cluster2 <- downloadHandler(
    filename = function() {
      "elementos.png"
    },
    content = function(file) {
      # Tomar una captura de pantalla del gráfico y guardarla en un archivo PNG
      grDevices::png(file, width = 1200, height = 800, units = "px", res = 100)
      grDevices::dev.capture(OpenRepGrid::cluster(repgrid_data,along=2))
      grDevices::dev.off()
      file.copy("Rplot001.png", file)  # Copiar el archivo temporal a la ubicación deseada
      file.remove("Rplot001.png")  # Eliminar el archivo temporal
    }
  )

  # Generar tabla de índices y valores matemáticos
  output$gridindices_table <- renderText({

    INTe <- indices_list[["intensity"]][["Elements"]]
    YOIDEAL <- INTe[length(INTe)]
    
    PVEFF <- indices_list[["pvaff"]] 
    INT <- indices_list[["intensity"]][["Total"]] 
    CON <- indices_list[["conflict"]]
    BIA <- indices_list[["bias"]]
    GCONS <- indices_list[["intensity"]][["Global Constructs"]]
    GELEM <- indices_list[["intensity"]][["Global Elements"]]

    tabla_indices <- data.frame(YOIDEAL,PVEFF,INT,CON,BIA,GCONS,GELEM)
    tabla_indices_round <- round(tabla_indices, 3)
    print(tabla_indices)

    knitr::kable(tabla_indices_round,col.names = c("Yo - Ideal", "PVAFF","Intensity","Conflicts","BIAS","Intensidad Global de Constructos","Intensidad Global de Elementos"),format = "html") %>%
    kable_styling("striped", full_width = T) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") %>%
    column_spec(1, bold = T, width = "10%") %>%
    column_spec(2, width = "10%") %>%
    column_spec(3, width = "10%") %>%
    column_spec(4, width = "10%") %>%
    column_spec(5, width = "10%") %>%
    column_spec(6, width = "20%") %>%
    column_spec(7, width = "20%")
  })
  
  output$construct <- renderDT({
    
    INTc <- indices_list[["intensity"]][["Constructs"]]

    # Ordenar los datos en orden descendente
    #INTc_ordenado <- sort(INTc, decreasing = TRUE)

    # Crear un data frame con los datos ordenados
    INTc_df <- data.frame(Intensity = round(INTc, 3))

    datatable(INTc_df, options = list(
      dom = 't',
      ordering = TRUE,
      columnDefs = list(list(className = 'dt-center', targets = "_all")),
      initComplete = JS(
        "function(settings, json) {",
        "$(this.api().table().header()).css({'background-color': '#005440', 'color': 'white'});",
        "}"
      )
    ))

    #knitr::kable(INTc_df, col.names = "Intensity",format = "html") %>%
    #kable_styling("striped", full_width = F) %>%
    #row_spec(0, bold = T, color = "white", background = "#005440") %>%
    #column_spec(1, bold = T)
    
  })


 output$elementss <- renderDT({
    
    INTe <- indices_list[["intensity"]][["Elements"]]

    #INTe_ordenado <- sort(INTe, decreasing = TRUE)
    INTe_df <- data.frame(Intensity = round(INTe, 3))

    datatable(INTe_df, options = list(
      dom = 't',
      ordering = TRUE,
      columnDefs = list(list(className = 'dt-center', targets = "_all")),
      initComplete = JS(
        "function(settings, json) {",
        "$(this.api().table().header()).css({'background-color': '#005440', 'color': 'white'});",
        "}")
    ))

    #knitr::kable(INTe_df, col.names = "Intensity",format = "html") %>%
    #kable_styling("striped", full_width = F) %>%
    #row_spec(0, bold = T, color = "white", background = "#005440") %>%
    #column_spec(1, bold = T)
    
  })


  output$constructs <- renderText({
    
    INTc <- indices_list[["dilemmas"]][["Congruency"]] #Constructs congruency
    INTc <- indexDilemma(repgrid_data,self=1,ideal=13, diff.congruent = 1, diff.discrepant = 4)
    print("dilemmmmmmmm")
    print(INTc$construct_classification)
    #print(indexDilemma(repgrid_data)[[1]])
    knitr::kable(INTc$construct_classification,format = "html") %>%
    #knitr::kable(INTc, col.names = "Intensity",format = "html") %>%
    kable_styling("striped", full_width = T) %>%
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
