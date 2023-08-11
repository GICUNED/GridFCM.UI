import_excel_ui <-  fluidPage(
     shiny.i18n::usei18n(i18n),
div(class = "custom-margins flex-container-xl",

   fluidRow( class = ("flex-container-xl"),
      h2(i18n$t("Importar datos desde archivo xlsx"), class = "pagetitlecustom"),
      p(i18n$t("En esta página, puedes descargar plantillas de xlsx y documentos de ayuda, y subir archivos xlsx para importar datos."), class = "desccustom mb-4"),
   ),
    
    fluidRow(
       # Widgets para importar archivos xlsx y seleccionar el tipo de datos
      column(6,
      box(
       width = 12,
       title = i18n$t("Importar archivos RepGrid"),
       icon = icon("magnifying-glass-chart"),
       status = "success",
       collapsible = FALSE,
       fileInput("archivo_repgrid", i18n$t("Seleccionar archivo RepGrid (.xlsx)")),
       column(12, class="d-flex justify-content-center mb-2 mt-2", actionButton("importar_datos", i18n$t("Importar Datos"), status = 'success', icon = icon("file-import")))
      )),

      column(6,
      box(
       width = 12,
       title = i18n$t("Importar archivos WimpGrid"),
       icon = icon("border-none"),
       status = "warning",
       collapsible = FALSE,
       fileInput("archivo_wimpgrid", i18n$t("Seleccionar archivo WimpGrid (.xlsx)")),
       column(12, class="d-flex justify-content-center mb-2 mt-2", actionButton("importar_datos_w", i18n$t("Importar Datos"), status = 'warning', icon = icon("file-import")))
      )),

       # Enlaces a plantillas de xlsx y documentos de ayuda
      box(
       width = 12,
       title = i18n$t("Plantillas y documentos de ayuda"),
       icon = icon("folder-open"),
       collapsible = FALSE,
       class="flex-container-docs",

       div(class="flex-container-resp-col download-container gap-2 justify-content-center",
         a(icon("file-pdf"), i18n$t("Documento de ayuda para RepGrid"), href = "ruta/al/archivo/ayuda_repgrid.pdf", target = "_blank", class = "link"),
         downloadButton("download_link_repgrid", i18n$t("Descargar plantilla RepGrid"), class = 'repgrid-btn'),
       ),

       div(class="flex-container-resp-col download-container gap-2 justify-content-center",
         a(icon("file-pdf"), i18n$t("Documento de ayuda para WimpGrid"), href = "ruta/al/archivo/ayuda_wimpgrid.pdf", target = "_blank", class = "link"),
         downloadButton("download_link_wimpgrid", i18n$t("Descargar plantilla WimpGrid"), class = 'wimpgrid-btn')
       )

       )
    )
  ))