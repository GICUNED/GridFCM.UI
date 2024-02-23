user_page_ui <- fluidPage(class="custom-margins-md",
    useShinyjs(),

    fluidRow(class = "flex-container-titles",
                h2(i18n$t("Panel de Usuario"), class = "rg pagetitlecustom mt-2"),
    ),

    fluidRow(class="user-container mt-4 mb-4",

        div(class="user-details w-100",
            icon("circle-user"),
            h3(textOutput("nombre")),
            shinyjs::hidden(actionButton("admin_btn", class="ml-auto", i18n$t("Admin Panel"), status = 'secondary', icon = icon("gear"), newTab = TRUE))
        ),

        div(class="user-license w-100",
            uiOutput("suscripcion_activa"),
            uiOutput("fechas_suscripcion"),
            div(class = "mx-auto text-center",
                shinyjs::hidden(actionButton("redirect_licencias", class="ml-auto mr-auto mt-2", i18n$t("Gestionar Suscripción"), status = 'success', icon = icon("address-card"))),
                shinyjs::hidden(actionButton("metricas", class="ml-auto mr-auto mt-2", i18n$t("Métricas"), status = 'warning', icon = icon("bar-chart")))
            )
        ),
        
    ),

    div(class = "mx-auto text-center rounded-custom",
        id = "iframeContainer",
        style = "display: none;",  # Oculta el div inicialmente
        tags$iframe(
            title = "Report Section",
            width = "100%",
            height = "600",
            src = "https://app.powerbi.com/view?r=eyJrIjoiYzY1MjE2ZDktMGU3Mi00Y2ZiLWEyNjQtOWFjNmQxYzYxMjUxIiwidCI6ImFhODJlNjc3LWVkZTQtNGY1Mi04NjA5LTI1Yjk5N2Y1ODM2OCIsImMiOjh9",
            frameborder = "0",
            allowfullscreen = TRUE
        ),
    ),

     fluidRow(id="usuarios_demo", class="p-0 mt-4 mb-2 custom-margins",
       
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
    

              
        
