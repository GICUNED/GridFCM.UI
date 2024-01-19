success_payment_ui <- fluidPage(class="custom-margins",
    useShinyjs(),

    fluidRow(class = "flex-container-titles",
        h2(i18n$t("Confirmación de pago"), class = "rg pagetitlecustom mt-2"),
    ),
    br(),
    fluidRow(class="success-help mb-2",
        uiOutput("confirmacionPago")
    ),

    br(),
    # meter redireccion a pagina licencias
    uiOutput("redirection"),
    # fluidRow( class = "flex-container-titles",
    #     div(id="redirectLicencias", class = "nav-item payments-page hidden-div", menuItem(i18n$t("Ir a Gestión de Suscripción"), href = route_link("plan"), newTab = FALSE))
    # ),
    
)
    

              
        
