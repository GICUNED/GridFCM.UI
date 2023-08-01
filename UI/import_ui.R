import_ui <-  fluidPage(
    shiny.i18n::usei18n(i18n),
div(class = "custom-margins",
    h2(i18n$t("Importar datos para un nuevo análisis de rejilla"), class = "pagetitlecustom"),
    p(i18n$t("En esta página, puedes aprender sobre los tres tipos de análisis de rejilla y elegir cómo importar tus datos."), class = "desccustom mb-4"),

# información para cada tipo de análisis

  fluidRow(class="mb-4 mt-4 gap-2 justify-content-center",
  actionButton(class ="mb-2 ml-2 mr-2", "importar_formulario", i18n$t("Importar formulario"), status = 'secondary', icon = icon("file-lines")),
  actionButton(class ="mb-2 ml-2 mr-2", "importar_xlsx", i18n$t("Importar archivo xlsx"), status = 'primary', icon = icon("file-excel")),
  ),

    # Botones para elegir entre importar datos a través de un archivo xlsx o un formulario
    fluidRow(

      column(4,
        box(title = "RepGrid",
              icon = icon("magnifying-glass-chart"),
              status = "success",
              width = 12,
              p(i18n$t("Descripción del análisis RepGrid.")))),

      column(4,
       box(title = "WimpGrid",
              icon = icon("border-none"),
              status = "warning",
              width = 12,
              p(i18n$t("Descripción del análisis WimpGrid.")))),

      column(4,
       box(title = "FullGrid",
              icon = icon("table-cells"),
              status = "gray",
              width = 12,
              p(i18n$t("Descripción del análisis Fullgrid."))))
    ),
  ))
# información para cada tipo de análisis