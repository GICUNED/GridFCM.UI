form_repgrid_ui <- fluidPage(
    shiny.i18n::usei18n(i18n),
    shinyjs::useShinyjs(),

    titlePanel(i18n$t("Inicio formulario RepGrid")),
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
        hidden(actionButton("continuar", i18n$t("Continuar"), style = "display: none;" ,icon = icon("arrow-right")))
        )
    )
)