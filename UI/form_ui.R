form_ui <- fluidPage( class="header-tab mix-diff",

    shiny.i18n::usei18n(i18n),
    shinyjs::useShinyjs(),

tabsetPanel(
    
    tabPanel(i18n$t("RepGrid"), id = "tab_data", icon = icon("magnifying-glass-chart"),

        fluidRow(class = ("flex-container-titles mt-3"),
            h2(i18n$t("Inicio formulario RepGrid"), class = "rg pagetitlecustom"),
        ),
        
        fluidRow(id="Elementos", class = "mt-2 custom-margins justify-content-center align-items-start", 
            column(5, id= "formElementos",
                box(
                    width = 12,
                    title = i18n$t("Elementos a valorar"),
                    icon = icon("people-arrows"),
                    collapsible = FALSE,
                    
                    textInput("nombrePaciente", i18n$t("Nombre:"), ""),
                    column(12, class="d-flex justify-content-center mt-3", actionButton("guardarNombre", i18n$t("Añadir"), status = "primary", icon = icon("plus")))
                )
            ),
            column(7, id = "listadoElementos",
                box(
                        width = 12,
                        title = i18n$t("Nombres Guardados"),
                        icon = icon("person"),
                        status = "success",
                        collapsible = TRUE,
                        column(12, class="d-flex align-items-center mb-3",
                            h5(strong(i18n$t("Lista"))),
                            actionButton(class="ml-auto", "borrarElemento", i18n$t("Borrar"), status ="danger", disabled=TRUE, icon = icon("trash-can"))
                        ),

                        column(12, uiOutput("lista_nombres")),
                        column(12, class="d-flex justify-content-end mt-3", actionButton("continuar_elementos", i18n$t("Continuar"), status="success", icon = icon("arrow-right") ))
                ),
            ),
        ),

        column(12, class="mt-2 d-flex justify-content-center align-items-start",
            box(id = "preguntasDiadas",
                width=5,
                title = i18n$t("¿Desea añadir los constructos de forma manual o de forma aleatoria?"),
                collapsible = FALSE,
                    column(12, class="d-flex justify-content-center",
                    actionButton("atras_preguntas_diada", class="mr-2", icon=icon("left-long"), i18n$t("Atrás")),

                    actionButton("manual", class="ml-auto",status = "secondary", icon=icon("hand"), i18n$t("Manual")),
                    actionButton("aleatorio", class="ml-2", status = "warning", icon=icon("dice"), i18n$t("Aleatoria")),
                ),

                div(class="mt-2",
                    numericInput("n_aleatorio", i18n$t("Número de constructos que desea generar:"), value = 1, step=1),
                ),
                column(12, class="d-flex justify-content-center mt-2",
                    actionButton("generar_aleatorio", i18n$t("Generar diadas"), status = "success", icon=icon("gears"),  style = "display: none;")
                )
            )
        ),
        
        fluidRow(id="Constructos", class = "mt-2 custom-margins justify-content-center align-items-start",  
        
            column(5,
                box(
                    width = 12,
                    title = i18n$t("Polos"),
                    icon = icon("compass"),
                    collapsible = FALSE,
                    
                    div(class="mb-2",textInput("constructo_izq", i18n$t("Polo izquierdo:"), "")),
                    div(textInput("constructo_der", i18n$t("Polo derecho:"), "")),

                    # boton add constructos
                    column(12, class="d-flex justify-content-center mt-3", 
                    actionButton("guardarConstructo", status = "success", i18n$t("Añadir"), icon = icon("plus"), disabled=TRUE)
                    )
                ),
            ),

            column(7, id = "listadoConstructos",
                box(
                        width = 12,
                        title = i18n$t("Constructos guardados"),
                        icon = icon("arrow-right-arrow-left"),
                        status = "success",
                        collapsible = TRUE,
                        column(12, class="d-flex align-items-center mb-3",
                            h5(strong(i18n$t("Lista"))),
                            actionButton(class="ml-auto", "borrarConstructo", i18n$t("Borrar"), status ="danger", disabled=TRUE, icon = icon("trash-can"))
                        ),
                        
                        column(12, uiOutput("lista_constructos")),
                        column(12, class="d-flex justify-content-center mt-3",
                        
                            actionButton("atras_constructos", class="mr-2", icon=icon("left-long"), i18n$t("Atrás")),
                            actionButton("continuar_constructo",class="ml-auto", i18n$t("Continuar"), disabled=TRUE, status="success", icon = icon("arrow-right"))
                        )
                ),
            ),
        ),

        fluidRow(id="ConstructosAleatorios", class = "mt-2 justify-content-center align-items-start",  
            box(
                width = 6,
                title = i18n$t("Cuestionario"),
                icon = icon("question"),

                div(textOutput("pregunta_semejanza")),
                div(class="mt-2",textInput("respuesta_semejanza_1", i18n$t("Ambos somos:"))),
                div(class="mt-2",textInput("respuesta_semejanza_2", i18n$t("¿Qué sería, en tu opinión, lo opuesto?"))),
                
                div(class="mt-2", textOutput("pregunta_diferencia")),
                div(class="mt-2", textInput("respuesta_diferencia_1", i18n$t("Yo soy:") )),

                div(class="mt-2", textOutput("pregunta_diferencia_2")),
                div(class="mt-2", textInput("respuesta_diferencia_2", label = NULL)),
                
                column(12, class="d-flex justify-content-center mt-3",
                    actionButton("atras_constructos_aleatorios", class="mr-2", icon=icon("left-long"), i18n$t("Atrás")),
                    actionButton("siguiente_constructo", status="success", class="ml-auto", i18n$t("Siguiente"), icon = icon("arrow-right"), disabled=TRUE)
                )
            ),
        ),

        fluidRow(id="PuntuacionesRepgrid", class = "mt-2 custom-margins justify-content-center align-items-start",  
            box(
                title = i18n$t("Puntuaciones RepGrid"),
                icon=icon("star"),
                column(12, class="d-flex justify-content-center mb-3",
                    actionButton("atras_puntuaciones", class="mr-2", icon=icon("left-long"), i18n$t("Atrás")),
                    actionButton("reiniciar_puntuaciones", status="warning", class="mr-auto", icon=icon("arrow-rotate-left"), i18n$t("Reiniciar")),
                ),
                h6(strong(textOutput("elemento_puntuable"))),
                uiOutput("pagina_puntuaciones"),
                
                div(id="rg_success", class="icon-success vis-off", icon("circle-check")),

                column(12, class="d-flex justify-content-center mt-3",
                    actionButton("siguiente_puntuacion", status="success", class="ml-auto", i18n$t("Siguiente"), icon = icon("arrow-right"))
                )
            ),
        ),
        fluidRow(id="ConfirmacionRepgrid", class = "mt-2 justify-content-center align-items-start",  
            box(
                title = i18n$t("Puntuaciones guardadas con éxito. ¿Desea crear la rejilla?"),
                collapsible = FALSE,
                column(12, class="d-flex justify-content-center",
                actionButton("atras_confirmacion_repgrid",  class="mr-2", icon=icon("left-long"), i18n$t("Atrás")),
                actionButton("crearRepgrid", status = "success", icon=icon("magnifying-glass-chart"), i18n$t("Crear RepGrid"))
                    
                )
            )
        ),
    ),

    # WIMPGRID
    tabPanel(i18n$t("WimpGrid"), id = "tab_data_w", icon = icon("border-none"),

            fluidRow(class = ("flex-container-titles mt-3"),
                h2(i18n$t("Inicio formulario WimpGrid"), class = "wg pagetitlecustom"),
            ),
            fluidRow(id="ComprobarDatos_w", class = "mt-2 justify-content-center align-items-start",  
                box( 
                    width= 6,
                    status="warning",
                    collapsible = FALSE,
                    title = i18n$t("Selecciona una opción"),
                    column(12, class="d-flex justify-content-center align-items-center",
                        actionButton("comprobar_datos_previos_w", class="mr-2", status ="warning", icon=icon("clock-rotate-left"), i18n$t("Comprobar datos previos")),
                        actionButton("iniciar_nuevo_w", icon= icon("rectangle-list"), i18n$t("Iniciar formulario nuevo"))
                    ),
                    br(),
                    DTOutput("sim_rep_w")
                )
            ),

            column(12, class="mt-2 d-flex justify-content-center align-items-start",
                box(id = "preguntasDiadas_w",
                    width=6,
                    title = i18n$t("¿Desea añadir los constructos de forma manual o de forma aleatoria?"),
                    collapsible = FALSE,
                        column(12, class="d-flex justify-content-center",
                        actionButton("atras_preguntas_diada_w", class="mr-2", icon=icon("left-long"), i18n$t("Atrás")),

                        actionButton("manual_w", class="ml-auto", status = "secondary", icon=icon("hand"), i18n$t("Manual")),
                        actionButton("aleatorio_w", class="ml-2", status = "warning", icon=icon("dice"), i18n$t("Aleatoria")),
                    ),

                    div(class="mt-2",
                        numericInput("n_aleatorio_w", i18n$t("Número de constructos que desea generar:"), value = 1, step=1),
                    ),
                    
                    column(12, class="d-flex justify-content-center gap-1 mt-4",
                    actionButton("puntuaciones_w",  i18n$t("Puntuar constructos"), icon= icon("star"), status="info", style = "display: none;"),
                    actionButton("generar_elementos_w", i18n$t("Introducir elementos"),  icon= icon("face-grin"), style = "display: none;"),
                    ),

                    column(12, class="d-flex justify-content-center mt-2",
                        actionButton("generar_aleatorio_w", i18n$t("Generar diadas"), status = "success", icon=icon("gears"),  style = "display: none;"),
                    )
                )
            ),

            fluidRow(id="Constructos_w", class = "mt-2 custom-margins justify-content-center align-items-start",  
            
                column(5,
                    box(
                        width = 12,
                        title = i18n$t("Polos"),
                        icon = icon("compass"),
                        collapsible = FALSE,
                        
                        div(class="mb-2",textInput("constructo_izq_w", i18n$t("Polo izquierdo:"), "")),
                        div(textInput("constructo_der_w", i18n$t("Polo derecho:"), "")),

                        # boton add constructos
                        column(12, class="d-flex justify-content-center mt-3",
                                actionButton("atras_constructos_w", class="mr-2", icon=icon("left-long"), i18n$t("Atrás")),

                        actionButton("guardarConstructo_w", status = "success", i18n$t("Añadir"), icon = icon("plus"), disabled=TRUE)
                        )
                    ),
                ),

                column(7, id = "listadoConstructos_w",
                    box(
                            width = 12,
                            title = i18n$t("Constructos guardados"),
                            icon = icon("arrow-right-arrow-left"),
                            status = "secondary",
                            collapsible = TRUE,
                            column(12, class="d-flex align-items-center mb-3",
                                h5(strong(i18n$t("Lista"))),
                                actionButton(class="ml-auto", "borrarConstructo_w", i18n$t("Borrar"), status ="danger", disabled=TRUE, icon = icon("trash-can"))
                            ),
                            
                            column(12, uiOutput("lista_constructos_w")),
                            column(12, class="d-flex justify-content-center mt-3",
                            
                                actionButton("continuar_constructo_w",class="ml-auto", i18n$t("Continuar"), disabled=TRUE, status="success", icon = icon("arrow-right"))
                            )
                    ),
                ),
            ),

            fluidRow(id="ValoracionesWimpgrid", class = "mt-4 custom-margins justify-content-center align-items-start",  
                box(
                    title = i18n$t("Valoraciones Wimpgrid"),
                    h6(strong(textOutput("elemento_evaluable_w"))),
                    column(12, class="d-flex justify-content-between gap-1",
                        textOutput("polo_izq_w"),
                        textOutput("polo_der_w")
                    ),
                    
                    sliderInput("valora", "", min=-1, max=1, value=0, step=0.01, ticks=FALSE),
                    
                    column(12, class="d-flex justify-content-center mt-3",
                        actionButton("atras_evaluaciones_w", class="mr-2",icon=icon("left-long"), i18n$t("Atrás")),
                        actionButton("siguiente_evaluacion_w",class="ml-auto", status="success", i18n$t("Siguiente"), icon = icon("arrow-right"))
                    )
                )
            ),

            fluidRow(id="Elementos_w", class = "mt-2 custom-margins justify-content-center align-items-start", 
                column(5, id= "formElementos_w",
                    box(
                        width = 12,
                        title = i18n$t("Elementos a valorar"),
                        icon = icon("people-arrows"),
                        collapsible = FALSE,
                        
                        textInput("nombrePaciente_w", i18n$t("Nombre:"), ""),
                        column(12, class="d-flex justify-content-center mt-3",
                        actionButton("atras_elementos_w", class="mr-2", icon = icon("left-long"), i18n$t("Atrás")),
                        actionButton("guardarNombre_w", i18n$t("Añadir"), status = "primary", icon = icon("plus")),
                        )
                        
                    )
                ),
                column(7, id = "listadoElementos_w",
                    box(
                            width = 12,
                            title = i18n$t("Nombres Guardados"),
                            icon = icon("person"),
                            status = "warning",
                            collapsible = TRUE,
                            column(12, class="d-flex align-items-center mb-3",
                                h5(strong(i18n$t("Lista"))),
                                actionButton(class="ml-auto", "borrarElemento_w", i18n$t("Borrar"), status ="danger", disabled=TRUE, icon = icon("trash-can"))
                            ),

                            column(12, uiOutput("lista_nombres_w")),
                            column(12, class="d-flex justify-content-center mt-3", 
                            actionButton("continuar_elementos_w", class="ml-auto", i18n$t("Continuar"), status="success", icon = icon("arrow-right") ))
                    ),
                ),
            ),

            fluidRow(id="ConstructosAleatorios_w", class = "mt-2 justify-content-center align-items-start",  
                box(
                    width = 6,
                    title = i18n$t("Cuestionario"),
                    icon = icon("question"),

                    div(textOutput("pregunta_semejanza_w")),
                    div(class="mt-2",textInput("respuesta_semejanza_1_w", i18n$t("Ambos somos:"))),
                    div(class="mt-2",textInput("respuesta_semejanza_2_w", i18n$t("¿Qué sería, en tu opinión, lo opuesto?"))),
                    
                    div(class="mt-2", textOutput("pregunta_diferencia_w")),
                    div(class="mt-2", textInput("respuesta_diferencia_1_w", i18n$t("Yo soy:") )),

                    div(class="mt-2", textOutput("pregunta_diferencia_2_w")),
                    div(class="mt-2", textInput("respuesta_diferencia_2_w", label = NULL)),
                    
                    column(12, class="d-flex justify-content-center mt-3",
                        actionButton("atras_constructos_aleatorios_w", class="mr-2", icon=icon("left-long"), i18n$t("Atrás")),
                        actionButton("siguiente_constructo_w", status="success", class="ml-auto", i18n$t("Siguiente"), icon = icon("arrow-right"), disabled=TRUE)
                    )
                ),
            ),

            fluidRow(id="PuntuacionesWimpgrid", class = "mt-2 custom-margins justify-content-center align-items-start",  
                box(
                    title = i18n$t("Puntuaciones WimpGrid"),
                    icon=icon("star"),
                    column(12, class="d-flex justify-content-center mb-3",
                        actionButton("atras_puntuaciones_w", class="mr-2",icon=icon("left-long"), i18n$t("Atrás")),
                        actionButton("reiniciar_puntuaciones_w", status="warning", class="mr-auto", icon=icon("arrow-rotate-left"), i18n$t("Reiniciar"))
                    ),
                    h6(strong(textOutput("elemento_puntuable_w"))),
                    uiOutput("pagina_puntuaciones_w"),

                    div(id="wg_success", class="icon-success vis-off", icon("circle-check")),

                    column(12, class="d-flex justify-content-center mt-3",
                        actionButton("siguiente_puntuacion_w",  status="success", class="ml-auto", i18n$t("Siguiente"), icon = icon("arrow-right"))
                    )
                ),
            ),

            fluidRow(id="ConfirmacionWimpgrid", class = "mt-2 justify-content-center align-items-start",  
                box(
                    title = i18n$t("Puntuaciones guardadas con éxito. ¿Desea crear la rejilla?"),
                    collapsible = FALSE,
                    column(12, class="d-flex justify-content-center",
                    actionButton("atras_confirmacion_wimpgrid",  class="mr-2", icon=icon("left-long"), i18n$t("Atrás")),
                    actionButton("crearWimpgrid", status = "warning", icon=icon("magnifying-glass-chart"), i18n$t("Crear WimpGrid"))
                        
                    )
                )
            )
        )
    )
)