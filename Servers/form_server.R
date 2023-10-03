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

    observeEvent(input$continuar_elementos, {
        shinyjs::hide("Elementos")
        shinyjs::show("preguntasDiadas")
        
    })    

    # Preguntas sobre los constructos
    observeEvent(input$aleatorio, {
        shinyjs::show("n_aleatorio")
        shinyjs::show("generar_aleatorio")
    })

    observeEvent(input$manual, {
        shinyjs::show("Constructos")
        shinyjs::hide("preguntasDiadas")
    })

    observeEvent(input$generar_aleatorio, {
        generar_diadas(input$n_aleatorio)
    })

    observeEvent(input$atras_preguntas_diada, {
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
        if((length(input$constructo_izq) > 0) && (length(input$constructo_der) > 0)){
            constructo <- paste(input$constructo_izq, " - ", input$constructo_der)
            constructos(c(constructos(), constructo))
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

    observeEvent(input$continuar_constructo, {
        shinyjs::hide("Constructos")
        shinyjs::show("PuntuacionesRepgrid")
        constructos_puntuables(constructos())
        elementos_puntuables(nombres())
        puntos_repgrid(NULL)
    })  

    observeEvent(input$atras_constructos, {
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
                paste("En qué se parecen tu YO ACTUAL y tu ", polo_derecho, "?")
            })
            output$pregunta_diferencia <- renderText({
                paste("En qué se diferencian tu YO ACTUAL y tu ", polo_derecho, "?")
            })
            output$pregunta_diferencia_2 <- renderText({
                paste("Por el contrario, mi ", polo_derecho, "  es:")
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
            constructos(c(constructos(), constructo_1))
            constructos(c(constructos(), constructo_2))

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

    observeEvent(input$atras_constructos_aleatorios, {
        shinyjs::hide("ConstructosAleatorios")
        shinyjs::show("preguntasDiadas")
    })


    # Puntuaciones para repgrid

    observe(
        if(length(elementos_puntuables()) > 0){
            output$elemento_puntuable <- renderText({
                unlist(elementos_puntuables()[1])
            })
        }
    )

    observe(
        if(length(constructos_puntuables()) > 0){
            output$polo_izq <- renderText({
                unlist(strsplit(constructos_puntuables()[1], " - "))[1]
            })

            output$polo_der <- renderText({
                unlist(strsplit(constructos_puntuables()[1], " - "))[2]
            })
        }
    )
                
    observeEvent(input$siguiente_puntuacion, {
        if(length(constructos_puntuables()) > 0){
            puntos_repgrid(c(puntos_repgrid(), input$puntos))
            constructos_puntuables(constructos_puntuables()[-1])
        }
        if(length(constructos_puntuables()) == 0 && length(elementos_puntuables()) > 0){
            
            constructos_puntuables(constructos())
            elementos_puntuables(elementos_puntuables()[-1])
            
        }
        if(length(elementos_puntuables()) ==0){
            shinyjs::hide("PuntuacionesRepgrid")
            shinyjs::show("ConfirmacionRepgrid")
        }
    })

    observeEvent(input$atras_puntuaciones, {
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
        message(polo_izq)
        message(polo_der)

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
                repgrid_home_server(input,output,session)
                runjs("window.location.href = '/#!/repgrid';")
            } 
        }
    })

    observeEvent(input$atras_confirmacion_repgrid, {
        shinyjs::hide("ConfirmacionRepgrid")
        shinyjs::show("Constructos")
    })
}