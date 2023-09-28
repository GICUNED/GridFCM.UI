form_server <- function(input, output, session){
    shinyjs::hide("listadoElementos")
    shinyjs::hide("Constructos")
    shinyjs::hide("preguntasDiadas")
    shinyjs::hide("ConstructosAleatorios")
    shinyjs::hide("n_aleatorio")

    nombres <- reactiveVal(list("Yo - Actual", "Yo - Ideal"))
    nombre_seleccionado <- reactiveVal(NULL)
    constructos <- reactiveVal(NULL)
    constructo_seleccionado <- reactiveVal(NULL)
    aleatorios <- reactiveVal(NULL)

    # Formulario para elementos

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
        lista_nombres <- nombres()
        # Asigna la lista reordenada a la variable reactiva nombres()
        session$userData$repgrid_form$elementos = list(lista_nombres)

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


    # Formulario para constructos manuales

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

    observeEvent(input$continuar_constructo, {
        constructos <- constructos()
        # Asigna la lista reordenada a la variable reactiva nombres()
        session$userData$repgrid_form$constructos = list(constructos)
        message(session$userData$repgrid_form$constructos)

        shinyjs::hide("Constructos")
    })  

    observeEvent(input$atras_constructos, {
        shinyjs::hide("Constructos")
        shinyjs::show("preguntasDiadas")
    })

    # Formulario para constructos aleatorios

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
        if(!is.null((aleatorios()))){
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
            message("borro")
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
}