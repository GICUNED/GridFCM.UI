form_repgrid_ui <- fluidPage( class="header-tab mix-diff",
    shiny.i18n::usei18n(i18n),
    shinyjs::useShinyjs(),

tabsetPanel(
    
  tabPanel(i18n$t("RepGrid"), id = "tab_data_w", icon = icon("magnifying-glass-chart"),

    fluidRow(class = ("flex-container-titles"),
        h2(i18n$t("Inicio formulario RepGrid"), class = "rg pagetitlecustom mt-4"),
    ),
    
    sidebarLayout(
        sidebarPanel(
            h4(i18n$t("Introduzca elementos a valorar")),
            textInput("nombrePaciente", i18n$t("Nombre:"), ""),
            actionButton("guardarNombre", i18n$t("Añadir"))
        ),
        
        mainPanel(
            h3(i18n$t("Nombres Guardados:")),
            uiOutput("lista_nombres"),
            br(),
            hidden(actionButton("continuar", i18n$t("Continuar"), style = "display: none;" , status="success", icon = icon("arrow-right")))
        )
    )
),

tabPanel(i18n$t("WimpGrid"), id = "tab_data_w", icon = icon("border-none"),

        fluidRow(class = ("flex-container-titles"),
            h2(i18n$t("Inicio formulario WimpGrid"), class = "wg pagetitlecustom mt-4"),
        ),
    
    )),

)