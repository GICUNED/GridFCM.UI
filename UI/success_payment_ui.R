success_payment_ui <- fluidPage(class="custom-margins",
    useShinyjs(),

    fluidRow(class = "flex-container-titles",
        h2(i18n$t("Confirmación de pago"), class = "rg pagetitlecustom mt-2"),
    ),
    br(),
    fluidRow(
        textOutput("confirmacionPago")
    ),

    br(),
    # meter redireccion a pagina licencias
    fluidRow(id="redirectLicencias", class = "flex-container-titles",
        div(class = "nav-item payments-page", menuItem(i18n$t("Ir a Gestión de Suscripción"), href = route_link("plan"), newTab = FALSE))
    ),
    
)
    

              
        
