import_excel_ui <-  fluidPage(
     shiny.i18n::usei18n(i18n),
div(class = "custom-margins",
    h2("Importar datos desde archivo xlsx", class = "pagetitlecustom"),
    p("En esta página, puedes descargar plantillas de xlsx y documentos de ayuda, y subir archivos xlsx para importar datos.", class = "desccustom mb-3"),

    
    fluidRow(
       # Widgets para importar archivos xlsx y seleccionar el tipo de datos
      column(6,
      box(
       width = 12,
       title = "Importar archivos RepGrid",
       icon = icon("magnifying-glass-chart"),
       status = "success",
       collapsible = FALSE,
       fileInput("archivo_repgrid", "Seleccionar archivo RepGrid (.xlsx)"),
       column(12, class="d-flex justify-content-center mb-2", actionButton("importar_datos", "Importar Datos", status = 'success', icon = icon("file-import")))
      )),

      column(6,
      box(
       width = 12,
       title = "Importar archivos WimpGrid",
       icon = icon("border-none"),
       status = "warning",
       collapsible = FALSE,
       fileInput("archivo_wimpgrid", "Seleccionar archivo WimpGrid (.xlsx)"),
       column(12, class="d-flex justify-content-center mb-2", actionButton("importar_datos_w", "Importar Datos", status = 'warning', icon = icon("file-import")))
      )),

       # Enlaces a plantillas de xlsx y documentos de ayuda
      column(12,
      box(
       width = 12,
       title = "Plantillas y documentos de ayuda",
       icon = icon("folder-open"),
       collapsible = FALSE,
       a(icon("download"), "Descargar plantilla RepGrid", href = "/UI/plantillas/RepGrid_Template.xlsx", download = "plantilla_repgrid.xlsx", class = "link"),
       br(),
       a(icon("download"), "Descargar plantilla WimpGrid", href = "/UI/plantillas/WimpGrid_Template.xlsx", download = "plantilla_wimpgrid.xlsx", class = "link"),
       br(),
       a(icon("file-pdf"), "Documento de ayuda para RepGrid", href = "ruta/al/archivo/ayuda_repgrid.pdf", target = "_blank", class = "link"),
       br(),
       a(icon("file-pdf"), "Documento de ayuda para WimpGrid", href = "ruta/al/archivo/ayuda_wimpgrid.pdf", target = "_blank", class = "link")
       ))
    )
  ))