user_page_ui <- fluidPage(class="custom-margins",
    useShinyjs(),

    fluidRow(class = "flex-container-titles",
                h2(i18n$t("Panel de Usuario"), class = "rg pagetitlecustom mt-2"),
    ),

    fluidRow(class="user-container mt-4",

        column(6, 

            div(class="user-details",
                icon("circle-user"),
                h3(textOutput("nombre")),
            ),

            div(class="user-license",
                textOutput("suscripcion_activa"),
                textOutput("fechas_suscripcion")
            ),
        ),

        column(6, class="d-flex justify-content-start gap-1 align-items-center flex-column",
            shinyjs::hidden(actionButton("redirect_licencias", class="ml-auto", i18n$t("Gestionar Suscripción"), status = 'success', icon = icon("address-card"))),
            shinyjs::hidden(actionButton("admin_btn", class="ml-auto", i18n$t("Admin Panel"), status = 'secondary', icon = icon("gear"), newTab = TRUE))
        )
    ),

     column(12,
        id="usuarios_demo", class="p-0 mt-4 mb-2",
       
        column(12,
            fluidRow(class = "flex-container-titles",
                h2(i18n$t("Usuarios demo"), class = "rg pagetitlecustom mt-2"),
            ),
            column(12, class = "patients-table p-3 bg-white rounded-lg  mt-2",
                DTOutput("tabla_usuario_demo"),
                div(class = "button-container mt-2 justify-content-center",    
                    downloadButton("exportar_usuarios", status ="primary", i18n$t("Exportar"))
                )
            )
            ),
            
    )
 )
    

              
        
