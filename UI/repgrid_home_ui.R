repgrid_home_ui <- fluidPage(
  shiny.i18n::usei18n(i18n),
  shinyjs::useShinyjs(),
  
  fluidRow( class = ("flex-container-xl border-divider"),
    h2(i18n$t("Inicio de RepGrid"), class = "pagetitlecustom  mt-4"),
    p(i18n$t("Esta página te permite visualizar y manipular los datos importados de RepGrid y acceder a diferentes tipos de análisis."),  class = "desccustom mb-2")
  ),

shinyjs::hidden(fluidRow(id="repgrid_home_warn",class="mb-4 mt-4 gap-2 justify-content-center error-help hidden",
  column(12, class = "row flex-column justify-content-center",
      icon("triangle-exclamation", "fa-2x"),
      p(i18n$t("Para hacer el análisis es necesario importar un archivo o formulario"), class = "mt-2 mb-2"),
    ),

  column(12, class="d-flex justify-content-center", actionButton("importar_page", i18n$t("Importar archivos"), status = 'warning', icon = icon("file-lines"))),
  )),

  # Mostrar los datos importados en una tabla
  #tableOutput("tabla_datos_repgrid"),
  fluidRow( class="mb-4 button-container",
    h3(i18n$t("Tabla de Datos"), class = "mr-auto mb-0"),
    actionButton("guardar", i18n$t("Guardar"), style = "display: none;", status = 'success', icon = icon("save")),
    actionButton("reiniciar", i18n$t("Reiniciar"), style = "display: none;", status = 'danger', icon = icon("arrow-rotate-left")),
    actionButton("editar", i18n$t("Editar"), icon = icon("edit"))
  ),
    
  shinyjs::hidden(
    div(id = "tabla_datos_repgrid_container",
      # Mostrar los datos de tabla_datos_repgrid
      tags$style(".my-table .htCore .htNoWrap { white-space: normal; }"),
      rHandsontableOutput("tabla_datos_repgrid")
    )
  ),

  div(class=("row"), id = "prueba_container",
    # Mostrar los datos de prueba
    plotOutput("bert")
  ),

  # Agregar enlaces o botones para acceder a diferentes análisis
  #actionButton("analisis1", "Análisis 1"),
  #actionButton("analisis2", "Análisis 2"),
  #actionButton("analisis3", "Análisis 3")
)
