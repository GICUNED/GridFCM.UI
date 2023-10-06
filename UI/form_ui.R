form_ui <- fluidPage( class="header-tab mix-diff",
    shiny.i18n::usei18n(i18n),
    shinyjs::useShinyjs(),

tabsetPanel(
    
    tabPanel(i18n$t("RepGrid"), id = "tab_data", icon = icon("magnifying-glass-chart"),

        fluidRow(class = ("flex-container-titles"),
            h2(i18n$t("Inicio formulario RepGrid"), class = "rg pagetitlecustom mt-2"),
        ),
        
        fluidRow(id="Elementos", class = "mt-4 custom-margins justify-content-center align-items-start", 
            column(5, id= "formElementos",
                box(
                    width = 12,
                    title = i18n$t("Elementos a valorar"),
                    icon = icon("people-arrows"),
                    collapsible = TRUE,
                    
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
                        collapsible = FALSE,
                        actionButton("borrarElemento", i18n$t("Borrar"), status ="danger", disabled=TRUE, icon = icon("trash-can")),
                        

                        column(12, shinycssloaders::withSpinner(uiOutput("lista_nombres"), type = 4, color = "#022a0c", size = 0.6)),
                        column(12, class="d-flex justify-content-center mt-3", actionButton("continuar_elementos", i18n$t("Continuar"), status="success", icon = icon("arrow-right") ))
                ),
            ),
        ),

        column(12, id = "preguntasDiadas",
            box(
                title = i18n$t("¿Desea añdir los constructos de forma manual o de forma aleatoria?"),
                actionButton("manual", i18n$t("Manual")),
                actionButton("aleatorio", i18n$t("Aleatoria")),
                numericInput("n_aleatorio", i18n$t("Número de constructos que desea generar:"), value = 1, step=1),
                actionButton("generar_aleatorio", i18n$t("Generar diadas"), style = "display: none;"),
                actionButton("atras_preguntas_diada", i18n$t("Atrás"))
            )
        ),
        
        fluidRow(id="Constructos", class = "mt-4 custom-margins justify-content-center align-items-start",  
            
            textInput("constructo_izq", i18n$t("Polo izquierdo:"), ""),
            
            textInput("constructo_der", i18n$t("Polo derecho:"), ""),
            
            # boton add constructos
            actionButton("guardarConstructo", i18n$t("Añadir"), disabled=TRUE),

            column(7, id = "listadoConstructos",
                box(
                        width = 12,
                        title = i18n$t("Constructos guardados"),
                        status = "success",
                        collapsible = FALSE,
                        actionButton("borrarConstructo", i18n$t("Borrar"), status ="danger", disabled=TRUE, icon = icon("trash-can")),
                        
                        column(12, uiOutput("lista_constructos")),
                        column(12, class="d-flex justify-content-center mt-3", actionButton("continuar_constructo", i18n$t("Continuar"), disabled=TRUE, status="success", icon = icon("arrow-right") )),
                        actionButton("atras_constructos", i18n$t("Atrás"))
                ),
            ),
        ),
        fluidRow(id="ConstructosAleatorios", class = "mt-4 custom-margins justify-content-center align-items-start",  
            box(
                textOutput("pregunta_semejanza"),
                textInput("respuesta_semejanza_1", i18n$t("Ambos somos:")),
                textInput("respuesta_semejanza_2", i18n$t("¿Qué sería en, tu opinión, lo opuesto?")),
                textOutput("pregunta_diferencia"),
                textInput("respuesta_diferencia_1", i18n$t("Yo soy:")),
                textOutput("pregunta_diferencia_2"),
                textInput("respuesta_diferencia_2", ""),
                
                actionButton("atras_constructos_aleatorios", i18n$t("Atrás")),
                actionButton("siguiente_constructo", i18n$t("Siguiente"), disabled=TRUE)
            ),
        ),
        fluidRow(id="PuntuacionesRepgrid", class = "mt-4 custom-margins justify-content-center align-items-start",  
            box(
                title = i18n$t("Puntuaciones Repgrid"),
                textOutput("elemento_puntuable"),
                fluidRow(
                    textOutput("polo_izq"),
                    p(" - "),
                    textOutput("polo_der")
                ),
                
                sliderInput("puntos", "", min=-1, max=1, value=0, step=0.01, ticks=FALSE),
                actionButton("atras_puntuaciones", i18n$t("Atrás")),
                actionButton("siguiente_puntuacion", i18n$t("Siguiente"))
            ),
        ),
        fluidRow(id="ConfirmacionRepgrid", class = "mt-4 custom-margins justify-content-center align-items-start",  
            box(
                title = i18n$t("Puntuaciones guardadas con éxito. Desea crear la rejilla?"),
                actionButton("crearRepgrid", i18n$t("Crear Repgrid")),
                actionButton("atras_confirmacion_repgrid", i18n$t("Atrás"))
            )
        ),
    ),

    # WIMPGRID
    tabPanel(i18n$t("WimpGrid"), id = "tab_data_w", icon = icon("border-none"),

        fluidRow(class = ("flex-container-titles"),
            h2(i18n$t("Inicio formulario WimpGrid"), class = "wg pagetitlecustom mt-4"),
        ),
        fluidRow(id="ComprobarDatos_w", class = "mt-4 custom-margins justify-content-center align-items-start",  
            box(
                title = i18n$t("Comprobación de datos previos"),
                actionButton("comprobar_datos_previos_w", i18n$t("Comprobar datos previos"))
            )
        ),
        column(12, id = "preguntasDiadas_w",
            box(
                title = i18n$t("¿Desea añdir los constructos de forma manual o de forma aleatoria?"),
                actionButton("manual_w", i18n$t("Manual")),
                actionButton("aleatorio_w", i18n$t("Aleatoria")),
                numericInput("n_aleatorio_w", i18n$t("Número de constructos que desea generar:"), value = 1, step=1),
                actionButton("generar_elementos_w", i18n$t("Introducir elementos"), style = "display: none;"),
                actionButton("generar_aleatorio_w", i18n$t("Generar diadas"), style = "display: none;"),
                actionButton("puntuaciones_w", i18n$t("Puntuar constructos"), style = "display: none;"),
                actionButton("atras_preguntas_diada_w", i18n$t("Atrás"))
            )
        ),
        fluidRow(id="Constructos_w", class = "mt-4 custom-margins justify-content-center align-items-start",  
            
            textInput("constructo_izq_w", i18n$t("Polo izquierdo:"), ""),
            
            textInput("constructo_der_w", i18n$t("Polo derecho:"), ""),
            
            # boton add constructos
            actionButton("guardarConstructo_w", i18n$t("Añadir"), disabled=TRUE),

            column(7, id = "listadoConstructos_w",
                box(
                        width = 12,
                        title = i18n$t("Constructos guardados"),
                        status = "success",
                        collapsible = FALSE,
                        actionButton("borrarConstructo_w", i18n$t("Borrar"), status ="danger", disabled=TRUE, icon = icon("trash-can")),
                        
                        column(12, uiOutput("lista_constructos_w")),
                        column(12, class="d-flex justify-content-center mt-3", actionButton("continuar_constructo_w", i18n$t("Continuar"), disabled=TRUE, status="success", icon = icon("arrow-right") )),
                        actionButton("atras_constructos_w", i18n$t("Atrás"))
                )
            )
        ),
        fluidRow(id="ValoracionesWimpgrid", class = "mt-4 custom-margins justify-content-center align-items-start",  
            box(
                title = i18n$t("Valoraciones Wimpgrid"),
                textOutput("elemento_evaluable_w"),
                fluidRow(
                    textOutput("polo_izq_w"),
                    p(" - "),
                    textOutput("polo_der_w")
                ),
                
                sliderInput("valora", "", min=-1, max=1, value=0, step=0.01, ticks=FALSE),
                actionButton("atras_evaluaciones_w", i18n$t("Atrás")),
                actionButton("siguiente_evaluacion_w", i18n$t("Siguiente"))
            )
        ),
    
        fluidRow(id="Elementos_w", class = "mt-4 custom-margins justify-content-center align-items-start", 
            column(5, id= "formElementos_w",
                box(
                    width = 12,
                    title = i18n$t("Elementos a valorar"),
                    icon = icon("people-arrows"),
                    collapsible = TRUE,
                    
                    textInput("nombrePaciente_w", i18n$t("Nombre:"), ""),
                    column(12, class="d-flex justify-content-center mt-3", actionButton("guardarNombre_w", i18n$t("Añadir"), status = "primary", icon = icon("plus")))
                )
            ),
            column(7, id = "listadoElementos_w",
                box(
                        width = 12,
                        title = i18n$t("Nombres Guardados"),
                        icon = icon("person"),
                        status = "success",
                        collapsible = FALSE,
                        actionButton("borrarElemento_w", i18n$t("Borrar"), status ="danger", disabled=TRUE, icon = icon("trash-can")),
                        

                        column(12, shinycssloaders::withSpinner(uiOutput("lista_nombres_w"), type = 4, color = "#022a0c", size = 0.6)),
                        column(12, class="d-flex justify-content-center mt-3", 
                            actionButton("continuar_elementos_w", i18n$t("Continuar"), status="success", icon = icon("arrow-right")),
                            actionButton("atras_elementos_w", i18n$t("Atrás"))
                        )

                )
            ),
        ),

        fluidRow(id="ConstructosAleatorios_w", class = "mt-4 custom-margins justify-content-center align-items-start",  
            box(
                textOutput("pregunta_semejanza_w"),
                textInput("respuesta_semejanza_1_w", i18n$t("Ambos somos:")),
                textInput("respuesta_semejanza_2_w", i18n$t("¿Qué sería en, tu opinión, lo opuesto?")),
                textOutput("pregunta_diferencia_w"),
                textInput("respuesta_diferencia_1_w", i18n$t("Yo soy:")),
                textOutput("pregunta_diferencia_2_w"),
                textInput("respuesta_diferencia_2_w", ""),
                
                actionButton("atras_constructos_aleatorios_w", i18n$t("Atrás")),
                actionButton("siguiente_constructo_w", i18n$t("Siguiente"), disabled=TRUE)
            )
        ),
        fluidRow(id="PuntuacionesWimpgrid", class = "mt-4 custom-margins justify-content-center align-items-start",  
            box(
                title = i18n$t("Puntuaciones Wimpgrid"),
                textOutput("elemento_puntuable_w"),
                fluidRow(
                    textOutput("polo_izq_p_w"),
                    p(" - "),
                    textOutput("polo_der_p_w")
                ),
                
                sliderInput("puntos_w", "", min=-1, max=1, value=0, step=0.01, ticks=FALSE),
                actionButton("atras_puntuaciones_w", i18n$t("Atrás")),
                actionButton("siguiente_puntuacion_w", i18n$t("Siguiente"))
            )
        ),
        fluidRow(id="ConfirmacionWimpgrid", class = "mt-4 custom-margins justify-content-center align-items-start",  
            box(
                title = i18n$t("Puntuaciones guardadas con éxito. Desea crear la rejilla?"),
                downloadButton("crearWimpgrid", i18n$t("Crear Wimpgrid")),
                actionButton("atras_confirmacion_wimpgrid", i18n$t("Atrás"))
            )
        )
    )
),

)