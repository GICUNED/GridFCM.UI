form_server <- function(input, output, session){
    shinyjs::hide("listadoElementos")
    shinyjs::hide("Constructos")
    shinyjs::hide("preguntasDiadas")
    shinyjs::hide("ConstructosAleatorios")
    shinyjs::hide("n_aleatorio")
    shinyjs::hide("PuntuacionesRepgrid")
    shinyjs::hide("ConfirmacionRepgrid")
    shinyjs::show("Elementos")

    nombres <- reactiveVal(list("Yo - Actual", "Yo - Ideal"))
    nombre_seleccionado <- reactiveVal(NULL)
    constructos <- reactiveVal(NULL)
    constructo_seleccionado <- reactiveVal(NULL)
    aleatorios <- reactiveVal(NULL)
    elementos_puntuables <- reactiveVal(NULL)
    constructos_puntuables <- reactiveVal(NULL)
    puntos_repgrid <- reactiveVal(NULL)

    # Formulario para elementos repgrid

    observeEvent(input$guardarNombre, {
        if (nchar(input$nombrePaciente) > 2) {
            nombres <- c(nombres(), as.character(input$nombrePaciente))
            shinyjs::show("listadoElementos")
            if("Yo - Ideal" %in% nombres){
                posicion_ideal <- which(nombres == "Yo - Ideal")
            }else{
                posicion_ideal <- -1
            }
            # Mueve "Yo - Ideal" al final de la lista
            if(posicion_ideal != -1){
                nombres <- c(nombres[-posicion_ideal], nombres[posicion_ideal])
            }
            nombres(nombres)
            #reactiveVal entre parentesis sin parametros devuelve el valor del objeto
            
            updateTextInput(session, "nombrePaciente", value = "")

            output$lista_nombres <- renderUI({
                if (length(nombres) > 0) {
                    menu_items <- lapply(nombres, function(nombre) {
                        menuItem(nombre, icon = icon("user"), tabName=nombre)
                    })
                    sidebarMenu(id="menu_elementos", menu_items)
                } 
            })
        }
        
    })

    observe(
        if(!is.null(input$menu_elementos)){
            nombre_seleccionado(input$menu_elementos)
            shinyjs::enable("borrarElemento")
        }
        else{
            shinyjs::disable("borrarElemento")
        }
    )
    
    observeEvent(input$borrarElemento, {
        nombre <- nombre_seleccionado()
        if(!is.null(nombre)){
            nombres_lista <- nombres()
            # Eliminar el nombre seleccionado
            nombres_lista <- nombres_lista[nombres_lista != nombre]
            nombres(nombres_lista)
            output$lista_nombres <- renderUI({
                menu_items <- lapply(nombres(), function(nombre) {
                    menuItem(nombre, icon = icon("user"), tabName=nombre)
                })
                sidebarMenu(id="menu_elementos", menu_items)
            })
        }
    })

    shinyjs::onclick("continuar_elementos", {
        shinyjs::hide("Elementos")
        shinyjs::show("preguntasDiadas")
    })    

    # Preguntas sobre los constructos
    shinyjs::onclick("aleatorio", {
        shinyjs::show("n_aleatorio")
        shinyjs::show("generar_aleatorio")
    })

    shinyjs::onclick("manual", {
        shinyjs::show("Constructos")
        shinyjs::hide("preguntasDiadas")
    })

    shinyjs::onclick("generar_aleatorio", {
        generar_diadas(input$n_aleatorio)
    })

    shinyjs::onclick("atras_preguntas_diada", {
        shinyjs::hide("preguntasDiadas")
        shinyjs::show("Elementos")
    })


    # Formulario para constructos manuales repgrid

    observe(
        if((input$constructo_izq != "") && (input$constructo_der != "")){
            shinyjs::enable("guardarConstructo")
        }
        else{
            shinyjs::disable("guardarConstructo")
        }
    )

    observeEvent(input$guardarConstructo, {
        if((nchar(input$constructo_izq) > 0) && (nchar(input$constructo_der) > 0)){
            constructo <- paste(input$constructo_izq, " - ", input$constructo_der)
            if (!(constructo %in% constructos())) {
                constructos(c(constructos(), constructo))
            } else {
                # Puedes mostrar un mensaje de error si el constructo ya existe
                # Por ejemplo, usando showNotification
                showNotification(i18n$t("El constructo ya existe"), type = "error")
            }
            updateTextInput(session, "constructo_izq", value="")
            updateTextInput(session, "constructo_der", value="")
            output$lista_constructos <- renderUI({
                menu_items <- lapply(constructos(), function(nombre) {
                    menuItem(nombre, tabName=nombre)
                })
                sidebarMenu(id="menu_constructos", menu_items)
            })
        }
    })

    observe(
        if(!is.null(input$menu_constructos)){
            constructo_seleccionado(input$menu_constructos)
            shinyjs::enable("borrarConstructo")
        }
        else{
            shinyjs::disable("borrarConstructo")
        }
    )

    observeEvent(input$borrarConstructo, {
        constructo <- constructo_seleccionado()
        if(!is.null(constructo)){
            constructos <- constructos()
            # Eliminar el nombre seleccionado
            lista_constructos <- constructos[constructos != constructo]
            constructos(lista_constructos)
            output$lista_constructos <- renderUI({
                menu_items <- lapply(constructos(), function(nombre) {
                    menuItem(nombre, tabName=nombre)
                })
                sidebarMenu(id="menu_constructos", menu_items)
            })
        }
    })

    observe(
        if(length(constructos()) > 0){
            shinyjs::enable("continuar_constructo")
        }else{
            shinyjs::disable("continuar_constructo")
        }
    )

    shinyjs::onclick("continuar_constructo", {
        shinyjs::hide("Constructos")
        shinyjs::show("PuntuacionesRepgrid")
        constructos_puntuables(constructos())
        elementos_puntuables(nombres())
        puntos_repgrid(NULL)
    })  

    shinyjs::onclick("atras_constructos", {
        shinyjs::hide("Constructos")
        shinyjs::show("preguntasDiadas")
    })

    # Formulario para constructos aleatorios repgrid

    generar_diadas <- function(n_pares){
        # elementos sin el yo-ideal que debería estar último
        yo_actual <- nombres()[1]
        elementos <- nombres()
        without_yo_ideal <- (length(elementos)-1)
        elementos <- elementos[2 : without_yo_ideal]
        if(n_pares > length(elementos) || n_pares < 1){
            showModal(modalDialog(
                title = paste(i18n$t("Debe introducir un número entre 1 y "), length(elementos)),
                footer = tagList(
                    modalButton("OK"),
                )
            ))
        }
        else{
            pares_seleccionados <- list()
            elementos_aleatorios <- list()
            # Realiza la selección n_pares veces
                # Selecciona dos valores aleatorios sin reemplazo
            aleatorio <- sample(elementos, size = n_pares, replace = FALSE)
            for(i in 1:n_pares){
                pareja <- list(c(yo_actual, aleatorio[i]))
                elementos_aleatorios <- append(elementos_aleatorios, pareja)
            }

            aleatorios(elementos_aleatorios)
            shinyjs::show("ConstructosAleatorios")
            shinyjs::hide("preguntasDiadas")
        }
    }

    observe(
        if(length(aleatorios()) > 0){
            polo_derecho <- aleatorios()[[1]][[2]]

            output$pregunta_semejanza <- renderText({
                paste(i18n$t("¿En qué se parecen tu YO ACTUAL y tu"), polo_derecho, "?")
            })
            output$pregunta_diferencia <- renderText({
                paste(i18n$t("¿En qué se diferencian tu YO ACTUAL y tu"), polo_derecho, "?")
            })
            output$pregunta_diferencia_2 <- renderText({
                paste(i18n$t("Por el contrario, mi "), polo_derecho, i18n$t("  es:"))
            })
        }
    )

    observe(
        if((input$respuesta_semejanza_1 != "") && (input$respuesta_semejanza_2 != "") && 
                (input$respuesta_diferencia_1 != "") && (input$respuesta_diferencia_2 != "")){
            shinyjs::enable("siguiente_constructo")
        }
    )

    observeEvent(input$siguiente_constructo, {
        r1 <- input$respuesta_semejanza_1
        r2 <- input$respuesta_semejanza_2
        r3 <- input$respuesta_diferencia_1
        r4 <- input$respuesta_diferencia_2
        aleatorios <- aleatorios()
        if(!is.null(aleatorios)){
            # me guardo los dos constructos
            constructo_1 <- paste(r1, " - ", r2)
            constructo_2 <- paste(r3, " - ", r4)
            if (!(constructo_1 %in% constructos())) {
                constructos(c(constructos(), constructo_1))
            }
            if (!(constructo_2 %in% constructos())) {
                constructos(c(constructos(), constructo_2))
            }
            # actualizo las respuestas a ""
            updateTextInput(session, "respuesta_semejanza_1", value="")
            updateTextInput(session, "respuesta_semejanza_2", value="")
            updateTextInput(session, "respuesta_diferencia_1", value="")
            updateTextInput(session, "respuesta_diferencia_2", value="")

            # lo quito de la lista de aleatorios ya que se ha usado
            aleatorios(aleatorios[-1])
            if(length(aleatorios()) == 0){
                aleatorios(NULL)
            }
            # espero que se acutalicen las preguntas?
            if(is.null(aleatorios())){
                output$lista_constructos <- renderUI({
                    menu_items <- lapply(constructos(), function(nombre) {
                        menuItem(nombre, tabName=nombre)
                    })
                    sidebarMenu(id="menu_constructos", menu_items)
                })
                shinyjs::hide("ConstructosAleatorios")
                shinyjs::show("Constructos")

            }
        }        
    })

    shinyjs::onclick("atras_constructos_aleatorios", {
        shinyjs::hide("ConstructosAleatorios")
        shinyjs::show("preguntasDiadas")
    })


    # Puntuaciones para repgrid
    renderizar_puntos <- function(){
        output$pagina_puntuaciones <- renderUI({
            num_constructos <- length(constructos_puntuables())
            constructos_separados <- strsplit(constructos_puntuables(), " - ")
            polo_izq <- sapply(constructos_separados, function(x) x[1])
            polo_der <- sapply(constructos_separados, function(x) x[2])

            constructos <- c()
            for(j in 1:num_constructos){
                constructos[[j]] <- fluidRow(
                    column(12, class="d-flex justify-content-between gap-1",
                        polo_izq[j],
                        textOutput("-"),
                        polo_der[j]
                    ),
                    column(12, 
                        sliderInput(
                            paste("slider_", j),
                            label = " ",
                            min = -1, max = 1, value = 0, step = 0.01, ticks = FALSE
                        )
                    )
                )
            }
            constructos
        })
    }

    observe(
        if(length(elementos_puntuables()) > 0){
            output$elemento_puntuable <- renderText({
                unlist(elementos_puntuables()[1])
            })
            renderizar_puntos()
        }
    )
                
    shinyjs::onclick("siguiente_puntuacion", {
        slider_names <- list()
        for(i in 1:length(constructos())){
            slider <- paste("slider_", i)
            puntos_repgrid(c(puntos_repgrid(), input[[slider]]))
        }
        if(length(elementos_puntuables()) > 0){
            elementos_puntuables(elementos_puntuables()[-1])
        }
        if(length(elementos_puntuables()) == 0){
            shinyjs::hide("PuntuacionesRepgrid")
            shinyjs::show("ConfirmacionRepgrid")
        }
    })


    shinyjs::onclick("atras_puntuaciones", {
        shinyjs::hide("PuntuacionesRepgrid")
        shinyjs::show("Constructos")
    })


    # Página de confirmación puntuaciones. Sacar un resumen?

    generar_excel <- function(){
        puntuaciones <- puntos_repgrid()
        elementos <- nombres()
        constructos <- constructos()
        n_constructos <- length(constructos)
        n_elementos <- length(elementos)
        primera_fila <- c("-1", elementos, "1")
        constructos_separados <- strsplit(constructos, " - ")
        polo_izq <- sapply(constructos_separados, function(x) x[1])
        polo_der <- sapply(constructos_separados, function(x) x[2])

        wb <- createWorkbook()
        sheet <- addWorksheet(wb, "Sheet1")
        num_filas <- n_constructos + 1
        num_columnas <- n_elementos + 2

        writeData(wb, sheet, primera_fila, startRow=1)
        writeData(wb, sheet, polo_izq, startRow=2, startCol=1)
        writeData(wb, sheet, polo_der, startRow=2, startCol=num_columnas)
        
        i = 1
        for (columna in 3:num_columnas-1) {
            for (fila in 2:num_filas) {
                writeData(wb, sheet, puntuaciones[i], startCol = columna, startRow = fila)
                i <- i+1
            }
        }

        ruta <- tempdir()
        nombre <- file.path(ruta, "formulario_repgrid.xlsx")
        saveWorkbook(wb, nombre, overwrite=TRUE)

        return(nombre)
    }
    
    shinyjs::onclick("crearRepgrid", {
        
        ruta_excel <- generar_excel()
        id_paciente <- session$userData$id_paciente

        if(file.exists(ruta_excel)){
            excel_repgrid_codificar <- read.xlsx(ruta_excel, colNames=FALSE)
            file.remove(ruta_excel)
            ruta_destino_rep <- tempfile(fileext = ".xlsx")
            fecha <- codificar_excel_BD(excel_repgrid_codificar, 'repgrid_xlsx', id_paciente)
            id <- decodificar_BD_excel('repgrid_xlsx', ruta_destino_rep, id_paciente)
            session$userData$fecha_repgrid <- fecha
            #constructos
            constructos_izq <- excel_repgrid_codificar[2:nrow(excel_repgrid_codificar), 1]
            constructos_der <- excel_repgrid_codificar[2:nrow(excel_repgrid_codificar), ncol(excel_repgrid_codificar)]
            session$userData$constructos_izq_rep <- constructos_izq
            session$userData$constructos_der_rep <- constructos_der
            datos_repgrid <- OpenRepGrid::importExcel(ruta_destino_rep)
            excel_repgrid <- read.xlsx(ruta_destino_rep)
            # aqui voy a comprobar si estoy importando el excel exportado con los numeros como strings
            columnas_a_convertir <- 2:(ncol(excel_repgrid) - 1)
            # Utiliza lapply para aplicar la conversión a las columnas seleccionadas
            excel_repgrid[, columnas_a_convertir] <- lapply(excel_repgrid[, columnas_a_convertir], as.numeric)
            session$userData$datos_to_table <- excel_repgrid
            num_columnas <- ncol(session$userData$datos_to_table)
            session$userData$num_col_repgrid <- num_columnas
            num_rows <- nrow(session$userData$datos_to_table)
            session$userData$num_row_repgrid <- num_rows
            session$userData$datos_repgrid <- datos_repgrid
            file.remove(ruta_destino_rep)
            if (!is.null(datos_repgrid)) {
                try <- tryCatch(
                    {
                        repgrid_home_server(input,output,session)
                        runjs("window.location.href = '/#!/repgrid';")
                    },
                    error = function(e){
                        message("Se ha producido un error: ", conditionMessage(e), "\n")
                    }
                )
                
                shinyjs::hide("ConfirmacionRepgrid")
                nombres(NULL)
                constructos(NULL)
                aleatorios(NULL)
                elementos_puntuables(NULL)
                constructos_puntuables(NULL)
                puntos_repgrid(NULL)
            } 
        }
    })

    shinyjs::onclick("atras_confirmacion_repgrid", {
        shinyjs::hide("ConfirmacionRepgrid")
        shinyjs::show("Constructos")
    })

    # WIMPGRID ---------------------------------------------------------

    shinyjs::hide("Constructos_w")
    shinyjs::hide("preguntasDiadas_w")
    shinyjs::hide("ConstructosAleatorios_w")
    shinyjs::hide("n_aleatorio_w")
    shinyjs::hide("PuntuacionesWimpgrid")
    shinyjs::hide("ConfirmacionWimpgrid")
    shinyjs::hide("ValoracionesWimpgrid")
    shinyjs::hide("Elementos_w")
    shinyjs::hide("puntuaciones_w")
    shinyjs::hide("generar_aleatorio_w")
    shinyjs::hide("generar_elementos_w")
    shinyjs::hide("sim_rep_w")
    shinyjs::show("ComprobarDatos_w")

    nombres_w <- reactiveVal(list("Yo - Actual", "Yo - Ideal"))
    nombres_valoraciones_w <- reactiveVal(list("Yo - Actual", "Yo - Ideal"))
    nombre_seleccionado_w <- reactiveVal(NULL)
    constructos_w <- reactiveVal(NULL)
    constructo_seleccionado_w <- reactiveVal(NULL)
    aleatorios_w <- reactiveVal(NULL)
    elementos_evaluables_w <- reactiveVal(NULL)
    elementos_puntuables_w <- reactiveVal(NULL)
    constructos_puntuables_w <- reactiveVal(NULL)
    puntos_wimpgrid <- reactiveVal(NULL)
    valoracion_actual <- reactiveVal(list())
    valoracion_ideal <- reactiveVal(list())
    valoracion_hipotetico <- reactiveVal(list())
    fechas_repgrid <- reactiveVal(list())

    observe(
        output$lista_constructos_w <- renderUI({
            menu_items <- lapply(constructos_w(), function(nombre) {
                menuItem(nombre, tabName=nombre)
            })
            sidebarMenu(id="menu_constructos_w", menu_items)
        })
    )

    # COMPROBAR DATOS PREVIOS ------------------------------------------------------
    cargar_fechas <- function(){
        con <- establishDBConnection()
        query <- sprintf("SELECT distinct(fecha_registro) FROM repgrid_xlsx WHERE fk_paciente=%d", session$userData$id_paciente)
        repgridDB <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        
        if(!is.null(repgridDB)){
            fecha_hora <- repgridDB$fecha_registro
            fechasRep <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
            
            df <- data.frame(Fechas = fechasRep)
            fechas_repgrid(fechasRep)
            output$sim_rep_w <- renderDT(
                datatable(df, 
                    selection = "single",
                    rownames = FALSE,
                    escape = FALSE,
                    options = list(
                        order = list(0, 'asc'),
                        searching = FALSE
                    ),
                    colnames = i18n$t("Simulaciones Repgrid")
                )
            ) 
        }
    }

    observeEvent(input$comprobar_datos_previos_w, {
        if(!is.null(session$userData$id_paciente)){
            shinyjs::show("sim_rep_w")
            cargar_fechas()
        }
    })  

    observeEvent(input$sim_rep_w_rows_selected, {
        selected_row <- input$sim_rep_w_rows_selected
        fechas <- fechas_repgrid()
        fecha <- fechas[selected_row]
        ruta_destino <- tempfile(fileext = ".xlsx")
        id <- decodificar_BD_excel('repgrid_xlsx', ruta_destino, session$userData$id_paciente, fecha)
        excel_repgrid <- read.xlsx(ruta_destino)
        file.remove(ruta_destino)
        # saco los constructos
        constructos_izq <- excel_repgrid[1:nrow(excel_repgrid), 1]
        constructos_der <- excel_repgrid[1:nrow(excel_repgrid), ncol(excel_repgrid)]
        res <- paste(constructos_izq, constructos_der, sep=" - ")
        constructos_w(res)
        # oculto cosas
        shinyjs::hide("ComprobarDatos_w")
        shinyjs::hide("iniciar_nuevo_w")
        shinyjs::hide("sim_rep_w")
        shinyjs::show("Constructos_w")
        
    })
    
    shinyjs::onclick("iniciar_nuevo_w", {
        shinyjs::hide("ComprobarDatos_w")
        shinyjs::hide("iniciar_nuevo_w")
        shinyjs::hide("sim_rep_w")
        shinyjs::hide("n_aleatorio_w")
        shinyjs::hide("generar_aleatorio_w")
        shinyjs::hide("generar_elementos_w")
        shinyjs::show("preguntasDiadas_w")
        constructos_w(NULL)
    })  

    # FIN COMPROBAR DATOS PREVIOS --------------------------------------------------



    # COMO SE GENERAN LOS CONSTRUCTOS -------------------------------------------

    shinyjs::onclick("manual_w", {
        shinyjs::hide("preguntasDiadas_w")
        shinyjs::show("Constructos_w")
    })

    shinyjs::onclick("atras_preguntas_diada_w", {
        shinyjs::hide("preguntasDiadas_w")
        shinyjs::show("ComprobarDatos_w")
        shinyjs::show("iniciar_nuevo_w")
    })

    # FIN PREGUNTAS GENERACION DE CONSTRUCTOS ---------------------------------------

    # CONSTRUCTOS MANUALES WIMPGRID ---------------------------------------------
    # Formulario para constructos manuales wimpgrid

    observe(
        if((input$constructo_izq_w != "") && (input$constructo_der_w != "")){
            shinyjs::enable("guardarConstructo_w")
        }
        else{
            shinyjs::disable("guardarConstructo_w")
        }
    )

    observeEvent(input$guardarConstructo_w, {
        if((nchar(input$constructo_izq_w) > 0) && (nchar(input$constructo_der_w) > 0)){
            constructo <- paste(input$constructo_izq_w, " - ", input$constructo_der_w)
            if (!(constructo %in% constructos_w())) {
                constructos_w(c(constructos_w(), constructo))
            } else {
                # Puedes mostrar un mensaje de error si el constructo ya existe
                # Por ejemplo, usando showNotification
                showNotification(i18n$t("El constructo ya existe"), type = "error")
            }
            updateTextInput(session, "constructo_izq_w", value="")
            updateTextInput(session, "constructo_der_w", value="")
            
        }
    })

    observe(
        if(!is.null(input$menu_constructos_w)){
            constructo_seleccionado_w(input$menu_constructos_w)
            shinyjs::enable("borrarConstructo_w")
        }
        else{
            shinyjs::disable("borrarConstructo_w")
        }
    )

    observeEvent(input$borrarConstructo_w, {
        constructo <- constructo_seleccionado_w()
        if(!is.null(constructo)){
            constructos <- constructos_w()
            # Eliminar el nombre seleccionado
            lista_constructos <- constructos[constructos != constructo]
            constructos_w(lista_constructos)
            
        }
    })

    observe(
        if(length(constructos_w()) > 0){
            shinyjs::enable("continuar_constructo_w")
        }else{
            shinyjs::disable("continuar_constructo_w")
        }
    )

    shinyjs::onclick("continuar_constructo_w", {
        shinyjs::hide("Constructos_w")
        shinyjs::show("ValoracionesWimpgrid")
        constructos_puntuables_w(constructos_w())

        elementos_evaluables_w(nombres_valoraciones_w())
        valoracion_actual(NULL)
        valoracion_ideal(NULL)
        valoracion_hipotetico(NULL)
        updateSliderInput(session, "valora", value=0)
    })  

    shinyjs::onclick("atras_constructos_w", {
        shinyjs::hide("Constructos_w")
        shinyjs::show("preguntasDiadas_w")
    })

    # FIN CONSTRUCTOS MANUALES WIMPGRID ---------------------------------

    

    # CONSTRUCTOS ALEATORIOS WIMPGRID ------------------------------------------------
    # Formulario para constructos aleatorios wimpgrid
    # Primero meter elementos

    shinyjs::onclick("generar_aleatorio_w", {
        generar_diadas_w(input$n_aleatorio_w)
    })

    shinyjs::onclick("aleatorio_w", {
        shinyjs::hide("preguntasDiadas_w")
        shinyjs::show("Elementos_w")
    })

    observeEvent(input$guardarNombre_w, {
        if (nchar(input$nombrePaciente_w) > 2) {
            nombres <- c(nombres_w(), as.character(input$nombrePaciente_w))
            shinyjs::show("listadoElementos")
            if("Yo - Ideal" %in% nombres){
                posicion_ideal <- which(nombres == "Yo - Ideal")
            }else{
                posicion_ideal <- -1
            }
            # Mueve "Yo - Ideal" al final de la lista
            if(posicion_ideal != -1){
                nombres <- c(nombres[-posicion_ideal], nombres[posicion_ideal])
            }
            nombres_w(nombres)
            #reactiveVal entre parentesis sin parametros devuelve el valor del objeto
            
            updateTextInput(session, "nombrePaciente_w", value = "")

            output$lista_nombres_w <- renderUI({
                if (length(nombres) > 0) {
                    menu_items <- lapply(nombres, function(nombre) {
                        menuItem(nombre, icon = icon("user"), tabName=nombre)
                    })
                    sidebarMenu(id="menu_elementos_w", menu_items)
                } 
            })
        }
        
    })

    observe(
        if(!is.null(input$menu_elementos_w)){
            nombre_seleccionado_w(input$menu_elementos_w)
            shinyjs::enable("borrarElemento_w")
        }
        else{
            shinyjs::disable("borrarElemento_w")
        }
    )
    
    observeEvent(input$borrarElemento_w, {
        nombre <- nombre_seleccionado_w()
        if(!is.null(nombre)){
            nombres_lista <- nombres_w()
            # Eliminar el nombre seleccionado
            nombres_lista <- nombres_lista[nombres_lista != nombre]
            nombres_w(nombres_lista)
            output$lista_nombres_w <- renderUI({
                menu_items <- lapply(nombres_w(), function(nombre) {
                    menuItem(nombre, icon = icon("user"), tabName=nombre)
                })
                sidebarMenu(id="menu_elementos_w", menu_items)
            })
        }
    })

    shinyjs::onclick("atras_elementos_w", {
        shinyjs::hide("Elementos_w")
        shinyjs::show("preguntasDiadas_w")
    })

    shinyjs::onclick("continuar_elementos_w", {
        shinyjs::hide("Elementos_w")
        shinyjs::show("preguntasDiadas_w")
        shinyjs::show("generar_elementos_w")
        shinyjs::show("n_aleatorio_w")
        shinyjs::show("generar_aleatorio_w")
    }) 

    shinyjs::onclick("generar_elementos_w", {
        shinyjs::hide("preguntasDiadas_w")
        shinyjs::show("Elementos_w")
    })
     
    # Una vez metidos los elementos igual que en repgrid, se meten los constructos aleatoriamente comparando elementos

    generar_diadas_w <- function(n_pares){
        # elementos sin el yo-ideal que debería estar último
        yo_actual <- nombres_w()[1]
        elementos <- nombres_w()
        without_yo_ideal <- (length(elementos)-1)
        elementos <- elementos[2 : without_yo_ideal]
        if(n_pares > length(elementos) || n_pares < 1){
            showModal(modalDialog(
                title = paste(i18n$t("Debe introducir un número entre 1 y "), length(elementos)),
                footer = tagList(
                    modalButton("OK"),
                )
            ))
        }
        else{
            pares_seleccionados <- list()
            elementos_aleatorios <- list()
            # Realiza la selección n_pares veces
                # Selecciona dos valores aleatorios sin reemplazo
            aleatorio <- sample(elementos, size = n_pares, replace = FALSE)
            for(i in 1:n_pares){
                pareja <- list(c(yo_actual, aleatorio[i]))
                elementos_aleatorios <- append(elementos_aleatorios, pareja)
            }

            aleatorios_w(elementos_aleatorios)
            shinyjs::show("ConstructosAleatorios_w")
            shinyjs::hide("preguntasDiadas_w")
        }
    }

    observe(
        if(length(aleatorios_w()) > 0){
            polo_derecho <- aleatorios_w()[[1]][[2]]

            output$pregunta_semejanza_w <- renderText({
                paste("En qué se parecen tu YO ACTUAL y tu ", polo_derecho, "?")
            })
            output$pregunta_diferencia_w <- renderText({
                paste("En qué se diferencian tu YO ACTUAL y tu ", polo_derecho, "?")
            })
            output$pregunta_diferencia_2_w <- renderText({
                paste("Por el contrario, mi ", polo_derecho, "  es:")
            })
        }
    )

    observe(
        if((input$respuesta_semejanza_1_w != "") && (input$respuesta_semejanza_2_w != "") && 
                (input$respuesta_diferencia_1_w != "") && (input$respuesta_diferencia_2_w != "")){
            shinyjs::enable("siguiente_constructo_w")
        }
        else{
            shinyjs::disable("siguiente_constructo_w")
        }
    )

    observeEvent(input$siguiente_constructo_w, {
        r1 <- input$respuesta_semejanza_1_w
        r2 <- input$respuesta_semejanza_2_w
        r3 <- input$respuesta_diferencia_1_w
        r4 <- input$respuesta_diferencia_2_w
        aleatorios <- aleatorios_w()
        if(!is.null(aleatorios)){
            # me guardo los dos constructos
            constructo_1 <- paste(r1, " - ", r2)
            constructo_2 <- paste(r3, " - ", r4)
            if (!(constructo_1 %in% constructos_w())) {
                constructos_w(c(constructos_w(), constructo_1))
            }
            if (!(constructo_2 %in% constructos_w())) {
                constructos_w(c(constructos_w(), constructo_2))
            }

            # actualizo las respuestas a ""
            updateTextInput(session, "respuesta_semejanza_1_w", value="")
            updateTextInput(session, "respuesta_semejanza_2_w", value="")
            updateTextInput(session, "respuesta_diferencia_1_w", value="")
            updateTextInput(session, "respuesta_diferencia_2_w", value="")

            # lo quito de la lista de aleatorios ya que se ha usado
            aleatorios_w(aleatorios[-1])
            if(length(aleatorios_w()) == 0){
                aleatorios_w(NULL)
            }
            # espero que se acutalicen las preguntas?
            if(is.null(aleatorios_w())){
                
                shinyjs::hide("ConstructosAleatorios_w")
                shinyjs::show("Constructos_w")

            }
        }        
    })

    shinyjs::onclick("atras_constructos_aleatorios_w", {
        shinyjs::hide("ConstructosAleatorios_w")
        shinyjs::show("preguntasDiadas_w")
    })

    # FIN CONSTRUCTOS ALEATORIOS ---------------------------------------------------

    # VALORACIONES WIMPGRID --------------------------------------------------------
    # Valoraciones 

    observe(
        if(length(elementos_evaluables_w()) > 0){
            output$elemento_evaluable_w <- renderText({
                unlist(elementos_evaluables_w()[1])
            })
        }
    )

    observe(
        if(length(constructos_puntuables_w()) > 0){
            output$polo_izq_w <- renderText({
                unlist(strsplit(constructos_puntuables_w()[1], " - "))[1]
            })

            output$polo_der_w <- renderText({
                unlist(strsplit(constructos_puntuables_w()[1], " - "))[2]
            })
        }
    )

    valor_hipotetico_calculado <- function(actual, ideal){
        h <- 0
        if(actual != 0){
            if(actual < 0){
                h <- 1
            }
            else{
                h <- -1
            }
        }
        else if(actual == 0 && ideal != 0){
            if(ideal < 0){
                h <- -1
            }
            else{
                h <- 1
            }
        }
        else if((actual == 0) && (ideal == 0)){
            h <- 1
        }
        else{
            message("algo fue mal en valor_hipotetico_calculado")
        }

        return(h)
    }
                
    shinyjs::onclick("siguiente_evaluacion_w", {
        if(length(elementos_evaluables_w()) > 0){
            if(unlist(elementos_evaluables_w()[1]) == "Yo - Actual"){
                valoracion_actual(c(valoracion_actual(), input$valora))
            }
            if(unlist(elementos_evaluables_w()[1]) == "Yo - Ideal"){
                valoracion_ideal(c(valoracion_ideal(), input$valora))
                # estableciendo el yo hipotetico
                valor_hipotetico <- valor_hipotetico_calculado(valoracion_actual()[length(valoracion_actual())], valoracion_ideal()[length(valoracion_ideal())])
                valoracion_hipotetico(c(valoracion_hipotetico(), valor_hipotetico))
            }
            elementos_evaluables_w(elementos_evaluables_w()[-1])
        }
        if(length(elementos_evaluables_w()) == 0 && length(constructos_puntuables_w()) > 0){
            elementos_evaluables_w(nombres_valoraciones_w())
            constructos_puntuables_w(constructos_puntuables_w()[-1])
        }
        if(length(constructos_puntuables_w()) == 0){
            
            shinyjs::hide("ValoracionesWimpgrid")
            shinyjs::show("preguntasDiadas_w")
            shinyjs::show("puntuaciones_w")
            shinyjs::hide("n_aleatorio_w")
            shinyjs::hide("generar_aleatorio_w")
            shinyjs::hide("generar_elementos_w")
        }
        updateSliderInput(session, "valora", value=0)
    })

    shinyjs::onclick("atras_evaluaciones_w", {
        shinyjs::hide("ValoracionesWimpgrid")
        shinyjs::show("Constructos_w")
    })
    # FIN VALORACIONES WIMPGRID -----------------------------------------------------

    # PUNTUACIONES WIMPGRID ---------------------------------------------------------
    generar_elementos_wimpgrid <- function(constructos){
        elementos <- list()
        valores_hipoteticos <- valoracion_hipotetico()
        resultado <- lapply(constructos, function(cadena) unlist(strsplit(cadena, " - ")))
        i <- 1
        for(e in resultado){
            if(valores_hipoteticos[i] == 1){
                elementos <- c(elementos, sprintf("Yo - Totalmente%s", e[2]))
            }
            else{
                elementos <- c(elementos, sprintf("Yo - Totalmente %s", e[1]))
            }
            i <- i+1
        }
        return(elementos)
    }

    shinyjs::onclick("puntuaciones_w", {
        shinyjs::hide("preguntasDiadas_w")
        shinyjs::show("PuntuacionesWimpgrid")
        constructos_puntuables_w(constructos_w())
        elementos_puntuables_w(generar_elementos_wimpgrid(constructos_w()))
        puntos_wimpgrid(NULL)
        #actuales <- rep(valoracion_actual(), each = length(constructos_puntuables_w()))
    })

    observe(
        if(length(valoracion_actual()) == length(constructos_w()) && length(valoracion_actual()) > 0){
            shinyjs::show("puntuaciones_w")
        }
        else{
            shinyjs::hide("puntuaciones_w")
        }
    )
    
    renderizar_puntos_w <- function(){
        output$pagina_puntuaciones_w <- renderUI({
            num_constructos <- length(constructos_puntuables_w())
            constructos_separados <- strsplit(constructos_puntuables_w(), " - ")
            polo_izq <- sapply(constructos_separados, function(x) x[1])
            polo_der <- sapply(constructos_separados, function(x) x[2])

            constructos <- c()
            for(j in 1:num_constructos){
                actual <- valoracion_actual()[j]
                constructos[[j]] <- fluidRow(
                    column(12, class="d-flex justify-content-between gap-1",
                        polo_izq[j],
                        textOutput("-"),
                        polo_der[j]
                    ),
                    column(12, 
                        sliderInput(
                            paste("slider_", j),
                            label = " ",
                            min = -1, max = 1, value = actual, step = 0.01, ticks = FALSE
                        )
                    )
                )
            }
            constructos
        })
    }

    observe(
        if(length(elementos_puntuables_w()) > 0){
            message(unlist(elementos_puntuables_w()[1]))
            output$elemento_puntuable_w <- renderText({
                unlist(elementos_puntuables_w()[1])
            })
            renderizar_puntos_w()
        }
    )

    shinyjs::onclick("siguiente_puntuacion_w", {
        slider_names <- list()
        for(i in 1:length(constructos_w())){
            slider <- paste("slider_", i)
            puntos_wimpgrid(c(puntos_wimpgrid(), input[[slider]]))
        }
        if(length(elementos_puntuables_w()) > 0){
            elementos_puntuables_w(elementos_puntuables_w()[-1])
        }
        if(length(elementos_puntuables_w()) == 0){
            shinyjs::hide("PuntuacionesWimpgrid")
            shinyjs::show("ConfirmacionWimpgrid")
        }
    })

    shinyjs::onclick("atras_puntuaciones_w", {
        shinyjs::hide("PuntuacionesWimpgrid")
        shinyjs::show("preguntasDiadas_w")
    })

    shinyjs::onclick("atras_confirmacion_wimpgrid", {
        shinyjs::hide("ConfirmacionWimpgrid")
        shinyjs::show("preguntasDiadas_w")
    })
    # FIN PUNTUACIONES WIMPGRID ---------------------------------------------------------

    # CREAR WIMPGRID XSLX ----------------------------------------------------

    generar_excel_w <- function(){
        puntuaciones <- puntos_wimpgrid()
        constructos <- constructos_w()
        elementos <- generar_elementos_wimpgrid(constructos)
        n_constructos <- length(constructos)
        n_elementos <- length(elementos)
        primera_fila <- c("-1", elementos, "Yo - Ideal", "1")
        constructos_separados <- strsplit(constructos, " - ")
        polo_izq <- sapply(constructos_separados, function(x) x[1])
        polo_der <- sapply(constructos_separados, function(x) x[2])

        wb <- createWorkbook()
        sheet <- addWorksheet(wb, "Sheet1")
        num_filas <- n_constructos + 1
        num_columnas <- n_elementos + 3

        writeData(wb, sheet, primera_fila, startRow=1)
        writeData(wb, sheet, polo_izq, startRow=2, startCol=1)
        writeData(wb, sheet, polo_der, startRow=2, startCol=num_columnas)
        writeData(wb, sheet, valoracion_ideal(), startRow=2, startCol=num_columnas-1)
        
        i = 1
        for (columna in 4:num_columnas-2) {
            for (fila in 2:num_filas) {
                writeData(wb, sheet, puntuaciones[i], startCol = columna, startRow = fila)
                i <- i+1
            }
        }

        ruta <- tempdir()
        nombre <- file.path(ruta, "formulario_wimprid.xlsx")
        saveWorkbook(wb, nombre, overwrite=TRUE)

        return(nombre)
    }

    #output$crearWimpgrid <- downloadHandler(
     #   filename = function() {
     #       "wimp.xlsx"
     #   },
     #   content = function(file) {
     #       ruta_excel <- generar_excel_w()

           # file.copy(ruta_excel, file)
        #}
    #)

    shinyjs::onclick("crearWimpgrid", {
        ruta_excel <- generar_excel_w()
        id_paciente <- session$userData$id_paciente

        if(file.exists(ruta_excel)){
            excel_wimp_codificar <- read.xlsx(ruta_excel, colNames=FALSE)
            file.remove(ruta_excel)
            ruta_destino_wimp <- tempfile(fileext = ".xlsx")
            fecha <- codificar_excel_BD(excel_wimp_codificar, 'wimpgrid_xlsx', id_paciente)
            id <- decodificar_BD_excel('wimpgrid_xlsx', ruta_destino_wimp, id_paciente)

            #constructos
            constructos_izq <- excel_wimp_codificar[2:nrow(excel_wimp_codificar), 1]
            constructos_der <- excel_wimp_codificar[2:nrow(excel_wimp_codificar), ncol(excel_wimp_codificar)]
            session$userData$constructos_izq <- constructos_izq
            session$userData$constructos_der <- constructos_der

            session$userData$fecha_wimpgrid <- fecha
            session$userData$id_wimpgrid <- id
            datos_wimpgrid <- importwimp(ruta_destino_wimp)
            excel_wimp<-read.xlsx(ruta_destino_wimp)
            
            columnas_a_convertir <- 2:(ncol(excel_wimp) - 1)
            # Utiliza lapply para aplicar la conversión a las columnas seleccionadas
            excel_wimp[, columnas_a_convertir] <- lapply(excel_wimp[, columnas_a_convertir], as.numeric)

            session$userData$datos_to_table_w <- excel_wimp
            num_columnas <- ncol(session$userData$datos_to_table_w)
            session$userData$num_col_wimpgrid <- num_columnas

            num_rows <- nrow(session$userData$datos_to_table_w)
            session$userData$num_row_wimpgrid <- num_rows
            session$userData$datos_wimpgrid <- datos_wimpgrid
            
            file.remove(ruta_destino_wimp)
            if (!is.null(datos_wimpgrid)) {
                # Solo archivo WimpGrid cargado, navegar a WimpGrid Home
                wimpgrid_analysis_server(input,output,session)
                runjs("window.location.href = '/#!/wimpgrid';")
                shinyjs::hide("ConfirmacionWimpgrid")
                nombres_w(NULL)
                nombres_valoraciones_w(NULL)
                nombre_seleccionado_w(NULL)
                constructos_w(NULL)
                constructo_seleccionado_w(NULL)
                aleatorios_w(NULL)
                elementos_evaluables_w(NULL)
                elementos_puntuables_w(NULL)
                constructos_puntuables_w(NULL)
                puntos_wimpgrid(NULL)
                valoracion_actual(NULL)
                valoracion_hipotetico(NULL)
            }  
        }
    })


    # FIN CREAR WIMPGRID XLSX ---------------------------------------------------
}