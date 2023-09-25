repgrid_home_ui <- fluidPage(
  shiny.i18n::usei18n(i18n),
  shinyjs::useShinyjs(),
  
  fluidRow( class = ("flex-container-titles"),
    h2(i18n$t("Inicio de RepGrid"), class = "pagetitlecustom  mt-2"),
    icon("circle-question", id = "tooltip-rg-home", class="tooltip-icon mb-4 ml-2"),
    div(id="context-rg-home", class="tooltip-container", icon("circle-xmark", id = "exit-rg-tooltip", class="exit-tooltip fa-solid"), p(i18n$t("Esta página te permite visualizar y manipular los datos importados de RepGrid y acceder a diferentes tipos de análisis."),  class = "desccustom-tooltip")),
  ),

shinyjs::hidden(fluidRow(id="repgrid_home_warn",class="mb-4 mt-4 gap-2 justify-content-center error-help hidden",
  column(12, class = "row flex-column justify-content-center",
      icon("triangle-exclamation", "fa-2x"),
      p(i18n$t("Para hacer el análisis es necesario importar o seleccionar un archivo o formulario"), class = "mt-2 mb-2"),
    ),

  column(12, class="d-flex justify-content-center", actionButton("importar_page", i18n$t("Importar archivos"), status = 'warning', icon = icon("file-lines"))),
  )),

  # Mostrar los datos importados en una tabla
  #tableOutput("tabla_datos_repgrid"),
  shinyjs::hidden(div(class ="custom-margins-lg", id = "rg-data-content",
    fluidRow( class="mb-2 button-container",
      #h3(id="i18n$t("Tabla de Datos"), class = "mr-auto mb-0"),
      #text output
      h4(class = "mr-auto mb-0", htmlOutput("titulo_repgrid")),

      actionButton("volver", i18n$t("Cancelar"), style = "display: none;", status = 'danger', icon = icon("circle-xmark")),
      actionButton("guardar", i18n$t("Guardar"), style = "display: none;", status = 'success', icon = icon("save")),
      actionButton("reiniciar", i18n$t("Reiniciar"), style = "display: none;", status = 'warning', icon = icon("arrow-rotate-left")),
      actionButton("editar", i18n$t("Editar"), icon = icon("edit")),
      actionButton("guardarBD", i18n$t("Guardar"), status = 'primary', icon = icon("database")),
      actionButton("guardarComo", i18n$t("Guardar como")),
      downloadButton("exportar", i18n$t("Exportar"))
    ),

    shinyjs::hidden(
    div(id = "tabla_datos_repgrid_container",
        # Mostrar los datos de tabla_datos_repgrid
        tags$style(".my-table .htCore .htNoWrap { white-space: normal; }"),
      rHandsontableOutput("tabla_datos_repgrid")
      # rHandsontableOutput("tabla_datos_repgrid")
    )
    ),

    div(class=("row"), id = "prueba_container",
      # Mostrar los datos de prueba
      plotOutput("bert")
      # plotOutput("bert")
    ),
  ))

  # Agregar enlaces o botones para acceder a diferentes análisis
  #actionButton("analisis1", "Análisis 1"),
  #actionButton("analisis2", "Análisis 2"),
  #actionButton("analisis3", "Análisis 3")
)
