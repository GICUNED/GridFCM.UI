import_ui <-  div(
    h2("Importar datos para un nuevo análisis de rejilla", class = "pagetitlecustom"),
    p("En esta página, puedes aprender sobre los tres tipos de análisis de rejilla y elegir cómo importar tus datos.", class = "desccustom mb-3"),

    # información para cada tipo de análisis
    fluidRow(

      column(4,
        box(title = "RepGrid",
              width = 12,
              p("Descripción del análisis RepGrid."))),

      column(4,
       box(title = "WimpGrid",
              width = 12,
              p("Descripción del análisis WimpGrid."))),

      column(4,
       box(title = "Fullgrid",
              width = 12,
              p("Descripción del análisis Fullgrid.")))
    ),

    # Botones para elegir entre importar datos a través de un archivo xlsx o un formulario

    fluidRow(

        column(12, class="d-flex mb-3 mt-3 justify-content-center", actionButton("importar_xlsx", "Importar archivo xlsx", status = 'primary', icon = icon("file-excel"))),

      column(12, class="d-flex justify-content-center", actionButton("importar_formulario", "Importar formulario", status = 'secondary', icon = icon("file-lines"))),
    )
  )