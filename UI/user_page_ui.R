user_page_ui <- fluidPage(class="custom-margins",
    useShinyjs(),

    fluidRow(class = "flex-container-titles",
                h2(i18n$t("Panel de Usuario"), class = "rg pagetitlecustom mt-2"),
    ),

    fluidRow(class="user-container mt-4",

        div(class="user-details w-100",
            icon("circle-user"),
            h3(textOutput("nombre")),
            shinyjs::hidden(actionButton("admin_btn", class="ml-auto", i18n$t("Admin Panel"), status = 'secondary', icon = icon("gear"), newTab = TRUE))
        ),

        div(class="user-license w-100",
            uiOutput("suscripcion_activa"),
            uiOutput("fechas_suscripcion"),
            shinyjs::hidden(actionButton("redirect_licencias", class="ml-auto mr-auto mt-2", i18n$t("Gestionar Suscripción"), status = 'success', icon = icon("address-card")))
        ),
        
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
    

              
        
