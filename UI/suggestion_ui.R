suggestion_ui <- fluidPage(class="custom-margins",
    useShinyjs(),

    fluidRow(class = "flex-container-titles",
                h2(i18n$t("Sugerencias"), class = "rg pagetitlecustom mt-2"),
    ),
    fluidRow(id="sugerencias_usuarios", class="mt-2 justify-content-center align-items-start",

        column(7,
            box(title = i18n$t("Buzón"),
                icon = icon("envelopes-bulk"),
                status = "success",
                width = 12,
                textAreaInput("sugerencia", i18n$t("Escriba su sugerencia aquí"),  rows = 5),
                # Botón de enviar
                column(12, class=" d-flex justify-content-center", actionButton("send_suggestion", class = "mt-2", status="success", icon=icon("paper-plane"), i18n$t("Enviar"), disable= TRUE))
                
            )
        )
    ),
    fluidRow(id="sugerencias_admin",
        DTOutput("tabla_sugerencias")
    ),
    br(),
    br(),
    # fluidRow( class="mb-2 button-container",
    #     div(class = "flex-container-mini",
    #         downloadButton("exportar_usuarios", status ="primary", i18n$t("Exportar"))
    #     )
    # ),
    column(
        id="usuarios_demo",
        width = 12,
        div(class = "flex-container-mini",
            downloadButton("exportar_usuarios", status ="primary", i18n$t("Exportar"))
        ),
        fluidRow(
            div(
                h2("Usuarios demo"),
                DTOutput("tabla_usuario_demo")
            )
        )
    )
)
    

              
        
