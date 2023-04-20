import_excel_ui <-  div(
    h2("Importar datos desde archivo xlsx", class = "pagetitlecustom"),
    p("En esta página, puedes descargar plantillas de xlsx y documentos de ayuda, y subir archivos xlsx para importar datos.", class = "desccustom"),

    # Enlaces a plantillas de xlsx y documentos de ayuda
    fluidRow(
      column(6,
             h3("Plantillas y documentos de ayuda"),
             a("Descargar plantilla RepGrid", href = "ruta/al/archivo/plantilla_repgrid.xlsx", download = "plantilla_repgrid.xlsx", icon("download")),
             br(),
             a("Descargar plantilla WimpGrid", href = "ruta/al/archivo/plantilla_wimpgrid.xlsx", download = "plantilla_wimpgrid.xlsx", icon("download")),
             br(),
             a("Documento de ayuda para RepGrid", href = "ruta/al/archivo/ayuda_repgrid.pdf", target = "_blank", icon("file-pdf")),
             br(),
             a("Documento de ayuda para WimpGrid", href = "ruta/al/archivo/ayuda_wimpgrid.pdf", target = "_blank", icon("file-pdf"))
      ),

      # Widgets para importar archivos xlsx y seleccionar el tipo de datos
      column(6,
             h3("Importar archivos xlsx"),
             fileInput("archivo_repgrid", "Seleccionar archivo RepGrid (.xlsx)"),
             fileInput("archivo_wimpgrid", "Seleccionar archivo WimpGrid (.xlsx)"),
             actionButton("importar_datos", "Importar datos")
      )
    )
  )