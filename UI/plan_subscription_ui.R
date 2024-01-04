plan_subscription_ui <- fluidPage(class="custom-margins",
    useShinyjs(),

    fluidRow(class="advert-help w-100 mb-4", id="advertencia-planes",
        p( strong("Atención"), "Se si vuelve a comprar otra suscripción cuando sigue activa la actual, no se añade más tiempo a la suscripción. Por ello, es mejor configurar una renovación automática o esperar a que se termine la fecha de suscripción, para ampliar la actual.")
    ),
    fluidRow(id="panel-compra",
        fluidRow(class = "flex-container-titles",
            h2(i18n$t("Planes de Suscripción"), class = "rg pagetitlecustom mt-2"),
        ),
        # column(id="panel-compra-individual", width=4, offset = 0, style='padding:0px;',
        #     h4(i18n$t("Sucripción individual")),
        #     h6(i18n$t("Anual")),
        #     h6(i18n$t("Precio: 20€")),
        #     a(i18n$t("Comprar"), href=""),
        # ),
        # column(width = 4, offset = 0, style='padding:0px;'),
        # column(id="panel-compra-organizacion", width=4, offset = 0, style='padding:0px;',
        #     h4(i18n$t("Sucripción organizacional")),
        #     h6(i18n$t("Anual")),
        #     h6(i18n$t("Precio: Desde 40€ (2 licencias)")),
        #     a(i18n$t("Comprar"), href=""),
        # ),
        column(12, offset = 0, class="mt-2 mb-2 p-0 box-shadow-1 overflow-hidden",
            uiOutput("pricing_table")
       ),
        
    ),


    column(12, id="panel-gestion-licencias", class="mt-4 mb-2",
        fluidRow(class = "flex-container-titles",
            h2(i18n$t("Gestión de Licencias"), class = "rg pagetitlecustom mt-2"),
        ),
        column(12, class = "patients-table p-3 bg-white rounded-lg mt-2",
            shinycssloaders::withSpinner(DTOutput("subscription_table"), type = 4, color = "#022a0c", size = 0.6),
            div(class = "button-container mt-2 justify-content-center",    
                actionButton("darLicencia", i18n$t("Añadir Participante"), disabled=TRUE, icon = icon("plus"), status="success"),
            ),
        ),
        br(),
        br(),
        column(12, id = "gestion-licencias", class = "p-3 mt-4 bg-white rounded-lg mix-diff simulation-tab",

            # Boton para editar la simulacion repgrid
            div(class = "button-container pb-2",
                h4(class = "paciente-seleccionado mr-auto mb-0 font-weight-bold", htmlOutput("suscripcion_licencia_header")),
                #actionButton("cargarSimulacion", i18n$t("Abrir simulación"), disabled=TRUE, icon = icon("download")),
                #actionButton("borrarSimulacion", i18n$t("Borrar simulación"), disabled=TRUE, status ="danger", icon = icon("trash-can"))
            ),
            shinycssloaders::withSpinner(DTOutput("licencias_table"), type = 4, color = "#022a0c", size = 0.6)
        ),

        #Formulario para añadir participante
        shinyjs::hidden(
            fluidRow(id = "participantForm",
                div(class = "patient-backdrop"),
                div(class="patient-form-container",
                    div(class = "flex-container-resp-col",
                        div(class = "card-title border-divider-sm",
                        icon("circle-xmark", id = "new-participant-cancel", class = "fa-solid exit-patients"), 
                        span(i18n$t("Nuevo participante")),
                        ),
                        div(id="primer_paso", class = "flex-container-resp-col",
                            textInput("email_participant", i18n$t("Email:")),
                            textOutput("email_text"),
                            # actionButton("continue", i18n$t("Continuar"), status = 'success', disabled=TRUE, icon = icon("save"))
                            actionButton("guardarAddParticipant", i18n$t("Añadir"), status = 'success', disabled=TRUE, icon = icon("save"))
                        ),
                        div(id="segundo_paso", class = "flex-container-resp-col hidden-div",
                            actionButton("confirmAddParticipant", i18n$t("Confirmar"), status = 'success', disabled=TRUE, icon = icon("save"))
                        )
                        
                    )
                ),
            )
        )
        
        
    ),
    
)
    

              
        
