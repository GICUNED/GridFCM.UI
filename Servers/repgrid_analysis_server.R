repgrid_analisis_server <- function(input, output, session) {
  
  shinyjs::hide("context-rg-analysis")

  onevent("click", "tooltip-rg-analysis", shinyjs::show("context-rg-analysis"))
  onevent("click", "exit-rg-analysis-tooltip", shinyjs::hide("context-rg-analysis"))

  observeEvent(input$importar_page_r, {
    # Navega a la página de creación de un nuevo análisis de rejilla
    # route_link("nombre_de_la_pagina_de_creacion")
    runjs("window.location.href = '/#!/import';")
  })

  observeEvent(input$patients_page_r, {
    # Navega a la página de creación de un nuevo análisis de rejilla
    runjs("window.location.href = '/#!/patient';")
  })


  observeEvent(input$graph_selector, {

  seleccion <- input$graph_selector
  

  if(seleccion == 'Cluster Analysis' || seleccion == 'Análisis por Conglomerados'){
    runjs("document.exitFullscreen();")
    runjs("
     
    if ($('#rg-analysis-content').hasClass('fullscreen-style')) {
      $('#rg-analysis-content').removeClass('fullscreen-style');

      $('#mb_exit_fs_5').addClass('hidden');
      $('#mb_enter_fs_5').removeClass('hidden');

      $('#mb_exit_fs_6').addClass('hidden');
      $('#mb_enter_fs_6').removeClass('hidden');

      $('#mb_exit_fs_7').addClass('hidden');
      $('#mb_enter_fs_7').removeClass('hidden');
    }")
  } else if (seleccion == 'Índices Cognitivos' || seleccion == 'Cognitive Indices'){
    runjs("document.exitFullscreen();")
    runjs("
     
    if ($('#rg-analysis-content').hasClass('fullscreen-style')) {
      $('#rg-analysis-content').removeClass('fullscreen-style');

      $('#mb_exit_fs_5').addClass('hidden');
      $('#mb_enter_fs_5').removeClass('hidden');

      $('#mb_exit_fs_6').addClass('hidden');
      $('#mb_enter_fs_6').removeClass('hidden');

      $('#mb_exit_fs_7').addClass('hidden');
      $('#mb_enter_fs_7').removeClass('hidden');
    }")

  } else if (seleccion == 'Dilemas' || seleccion == 'Dilemmas'){
    runjs("document.exitFullscreen();")
    runjs("
     
    if ($('#rg-analysis-content').hasClass('fullscreen-style')) {
      $('#rg-analysis-content').removeClass('fullscreen-style');

      $('#mb_exit_fs_5').addClass('hidden');
      $('#mb_enter_fs_5').removeClass('hidden');

      $('#mb_exit_fs_6').addClass('hidden');
      $('#mb_enter_fs_6').removeClass('hidden');

      $('#mb_exit_fs_7').addClass('hidden');
      $('#mb_enter_fs_7').removeClass('hidden');
    }")
  }})


  #if (is.null(session$userData$datos_repgrid)) {
  #  datos_control <- 0
  #  indice_control <- 0
 # }else{
    #datos_control <- session$userData$datos_repgrid
   # indice_control <-  gridindices(datos_control)
   #}
   

  repgrid_data <- session$userData$datos_repgrid
  
 
  if (is.null(session$userData$datos_repgrid))
  {
    repgrid_data <-boeker
  }

  indices_list <- gridindices(repgrid_data)

  output$biplot2d_plot <- renderPlot({
    
      OpenRepGrid::biplot2d(repgrid_data, c.label.col = "#005440",c.grid = "gray", c.grid.lty = "dotted", e.point.cex = 1,
   e.label.cex = 1.1, c.point.cex = 1, rect.margins = c(.1, .1), c.label.cex = 1,c.grid.lwd = 0.7, cex.axis = 1, cex.labels = 1, var.cex = 1)
    
  })

  output$btn_download_2d <- downloadHandler(
    filename = function() {
      "grafico_bidimensional.png"
    },
    content = function(file) {
      # Tomar una captura de pantalla del gráfico y guardarla en un archivo PNG
      grDevices::png(file, width = 1200, height = 1200, units = "px", res = 100)
      grDevices::dev.capture(OpenRepGrid::biplot2d(repgrid_data, c.label.col = "#005440",c.grid = "gray", c.grid.lty = "dotted", e.point.cex = 1,
   e.label.cex = 1.1, c.point.cex = 1, c.label.cex = 1,c.grid.lwd = 0.7, cex.axis = 1, cex.labels = 1, var.cex = 1))
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
    OpenRepGrid::biplot3d(repgrid_data, c.cex = 1, c.text.col = "#005440",e.cex = 1, scale.e = 1.2)
    rglwidget()
    #try(close3d())
    #OpenRepGrid::biplot3d(repgrid_data)
    #points3d(1:10, 1:10, 1:10)
    #axes3d()
    #rglwidget()
  }, outputArgs = list(width = "auto", height = "300px"))

  # Generar análisis por conglomerados
  output$cluster_plot_1 <- renderPlot({
    
     OpenRepGrid::cluster(repgrid_data, along=1, cex = 0,
   lab.cex = 1, cex.main = 1)
     #indices_list[["distances"]][["Constructs"]] 
    
  })

  output$matrix_constructs <- renderRHandsontable({
    mc <- indices_list[["distances"]][["Constructs"]]
    izq <- session$userData$constructos_izq_rep
    der <- session$userData$constructos_der_rep
    res <- paste(izq, der, sep="/\n")
    colnames(mc) <- res

    rhandsontable(mc, rowHeaderWidth = 250) %>%
      hot_table(highlightCol = TRUE, highlightRow = TRUE, readOnly = TRUE, stretchH="all") %>%
      hot_context_menu(allowRowEdit = FALSE, allowColEdit = FALSE)
  })

  output$matrix_elements <- renderRHandsontable({
    rhandsontable(indices_list[["distances"]][["Elements"]], rowHeaderWidth = 100) %>%
      hot_table(highlightCol = TRUE, highlightRow = TRUE, readOnly = TRUE, stretchH="all") %>%
      hot_context_menu(allowRowEdit = FALSE, allowColEdit = FALSE)
  })

  output$btn_download_cluster1 <- downloadHandler(
    filename = function() {
      "constructos.png"
    },
    content = function(file) {
      # Tomar una captura de pantalla del gráfico y guardarla en un archivo PNG
      grDevices::png(file, width = 1200, height = 800, units = "px", res = 100)
      grDevices::dev.capture(OpenRepGrid::cluster(repgrid_data, along=1, cex = 0,
   lab.cex = 1, cex.main = 1))
      grDevices::dev.off()
      file.copy("Rplot001.png", file)  # Copiar el archivo temporal a la ubicación deseada
      file.remove("Rplot001.png")  # Eliminar el archivo temporal
    }
  )

  # Generar análisis por conglomerados
  output$cluster_plot_2 <- renderPlot({
    
    OpenRepGrid::cluster(repgrid_data,along=2, cex = 0,
   lab.cex = 1, cex.main = 1)
    #indices_list[["distances"]][["Elements"]] 
    
  })

  output$btn_download_cluster2 <- downloadHandler(
    filename = function() {
      "elementos.png"
    },
    content = function(file) {
      # Tomar una captura de pantalla del gráfico y guardarla en un archivo PNG
      grDevices::png(file, width = 1200, height = 800, units = "px", res = 100)
      grDevices::dev.capture(OpenRepGrid::cluster(repgrid_data,along=2,  cex = 0,
   lab.cex = 1, cex.main = 1))
      grDevices::dev.off()
      file.copy("Rplot001.png", file)  # Copiar el archivo temporal a la ubicación deseada
      file.remove("Rplot001.png")  # Eliminar el archivo temporal
    }
  )

  # Generar tabla de índices y valores matemáticos
  output$gridindices_table <- renderText({
    INTe <- indices_list[["intensity"]][["Elements"]]

    col <- ncol(session$userData$datos_repgrid)
    listado <- OpenRepGrid::indexSelfConstruction(session$userData$datos_repgrid, 1, col, method="pearson")
    YOIDEAL <- listado$self_ideal  # antes estab asi: INTe[length(INTe)]
    YOOTROS <- listado$self_others
    OTROSIDEAL <- listado$ideal_others

    PVEFF <- indices_list[["pvaff"]] 
    INT <- indices_list[["intensity"]][["Total"]] 
    CON <- indices_list[["conflict"]]
    BIA <- indices_list[["bias"]]
    GCONS <- indices_list[["intensity"]][["Global Constructs"]]
    GELEM <- indices_list[["intensity"]][["Global Elements"]]

    tabla_indices <- data.frame(YOIDEAL,YOOTROS,OTROSIDEAL,PVEFF,INT,CON,BIA,GCONS,GELEM)
    tabla_indices_round <- round(tabla_indices, 3)

    
    knitr::kable(tabla_indices_round,col.names = c(i18n$t("Yo/Ideal"), i18n$t("Yo/Otros"), i18n$t("Otros/Ideal"), "PVAFF", i18n$t("Intensidad"), i18n$t("Conflicts"),"BIAS", i18n$t("Intensidad Global de Constructos"), i18n$t("Intensidad Global de Elementos")),
    row.names = FALSE, format = "html") %>%
    kable_styling("striped", full_width = T) %>%
    row_spec(0, bold = T, color = "white", background = "#005440") #%>%
    # column_spec(1, bold = T, width = "10%") %>%
    # column_spec(2, width = "10%") %>%
    # column_spec(3, width = "10%") %>%
    # column_spec(4, width = "10%") %>%
    # column_spec(5, width = "10%") %>%
    # column_spec(6, width = "10%") %>%
    # column_spec(7, width = "10%")
  })
  
  output$construct <- renderDT({
    
    INTc <- indices_list[["intensity"]][["Constructs"]]

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
      ),
      paging = FALSE
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
        "}"),
      paging = FALSE
    ))

    #knitr::kable(INTe_df, col.names = "Intensity",format = "html") %>%
    #kable_styling("striped", full_width = F) %>%
    #row_spec(0, bold = T, color = "white", background = "#005440") %>%
    #column_spec(1, bold = T)
    
  })


  output$constructs <- renderText({
    min <- session$userData$repgrid_min
    max <- session$userData$repgrid_max
    message("minimos y maximos de la rejilla> ", min, "  ", max)
    INTc <- indices_list[["dilemmas"]][["Congruency"]] #Constructs congruency
    INTc <- indexDilemma(repgrid_data,self=1,ideal=session$userData$num_col_repgrid-2, diff.congruent = ((max-min)/6), diff.discrepant = ((max-min)/2)+0.001)
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
    min <- session$userData$repgrid_min
    max <- session$userData$repgrid_max
    message(indices_list[["dilemmas"]][["Dilemmas"]])
    INTc <- indices_list[["dilemmas"]][["Dilemmas"]] #dilemmas
    
    INTc <- indexDilemma(repgrid_data,self=1,ideal=session$userData$num_col_repgrid-2, diff.congruent = ((max-min)/6), diff.discrepant = ((max-min)/2) +0.001)
    
    print(INTc$dilemmas_df)
    dilemmas_df <- INTc$dilemmas_df
    
    if (nrow(dilemmas_df) > 0) {
      
      dilemmas_df <- dilemmas_df %>% select(-id_c, -id_d)
      
      dilemmas_df$R <- round(dilemmas_df$R, 2) # digits
      
      ii <- stringr::str_detect(dilemmas_df$RexSI, "\\.")
      
      dilemmas_df$RexSI[ii] <- as.character(round(as.numeric(dilemmas_df$RexSI[ii]), 3))
      
      
      
      knitr::kable(dilemmas_df,format = "html") %>%
      #knitr::kable(INTc, col.names = "Intensity",format = "html") %>%
      kable_styling("striped", full_width = F) %>%
      row_spec(0, bold = T, color = "white", background = "#005440") %>%
      column_spec(1, bold = T)
      
    } else {
      "No implicative dilemmas detected"
    }
  })


}
