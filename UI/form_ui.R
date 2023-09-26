form_ui <- fluidPage( class="header-tab mix-diff",
    shiny.i18n::usei18n(i18n),
    shinyjs::useShinyjs(),

tabsetPanel(
    
  tabPanel(i18n$t("RepGrid"), id = "tab_data_w", icon = icon("magnifying-glass-chart"),

    fluidRow(class = ("flex-container-titles"),
        h2(i18n$t("Inicio formulario RepGrid"), class = "rg pagetitlecustom mt-2"),
    ),
    
    fluidRow(class = "mt-4 custom-margins justify-content-center align-items-start",
            column(5,
                box(
                    width = 12,
                    title = i18n$t("Elementos a valorar"),
                    icon = icon("people-arrows"),
                    collapsible = TRUE,
                    
                    textInput("nombrePaciente", i18n$t("Nombre:"), ""),
                    column(12, class="d-flex justify-content-center mt-3", actionButton("guardarNombre", i18n$t("Añadir"), status = "primary", icon = icon("plus")))
                )
            ),

            
            column(7, id = "namesForm",
            box(
                    width = 12,
                    title = i18n$t("Nombres Guardados"),
                    icon = icon("person"),
                    status = "success",
                    collapsible = FALSE,
                    actionButton("borrarElemento", i18n$t("Borrar"), status ="danger", disabled=TRUE, icon = icon("trash-can")),
                    

                    column(12, shinycssloaders::withSpinner(uiOutput("lista_nombres"), type = 4, color = "#022a0c", size = 0.6)),
                    column(12, class="d-flex justify-content-center mt-3", actionButton("continuar", i18n$t("Continuar"), status="success", icon = icon("arrow-right") ))
            )
        ),
    
    )
),

tabPanel(i18n$t("WimpGrid"), id = "tab_data_w", icon = icon("border-none"),

        fluidRow(class = ("flex-container-titles"),
            h2(i18n$t("Inicio formulario WimpGrid"), class = "wg pagetitlecustom mt-4"),
        ),
    
    )),

)