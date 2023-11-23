user_page_ui <- fluidPage(class="custom-margins",
    useShinyjs(),

    fluidRow(class = "flex-container-titles",
                h2(i18n$t("Panel de Usuario"), class = "rg pagetitlecustom mt-2"),
    ),

    br(),
    br(),
    textOutput("nombre"),
    br(),
    fluidRow(id="suscripcion_activa",
        textOutput("suscripcion_activa")
    ),
    br(),
    textOutput("fechas_suscripcion"),
    br(),
    # meter redireccion a pagina licencias
    div(id="redirect-licencias", menuItem(i18n$t("Ir a Gestión de Suscripción"), href = route_link("plan"), newTab = FALSE)),
    )
    

              
        
