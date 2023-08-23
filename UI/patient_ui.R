patient_ui <- fluidPage(
  shinyjs::useShinyjs(),
  shiny.i18n::usei18n(i18n),

  splitLayout(
    cellWidths = c("30%", "70%"),
    
    # Parte izquierda: Formulario para añadir paciente
    div(style = "padding: 20px;",
      actionButton("addPatient", "Añadir paciente"),
      
      shinyjs::hidden(
        div(id = "patientForm",
            sidebarPanel(
              textInput("nombre", "Nombre:"),
              numericInput("edad", "Edad:", value = 0),
              selectInput("genero", "Género:", c("hombre", "mujer", "no definido")),
              textInput("anotaciones", "Anotaciones:"),
              actionButton("guardarAddPatient", "Guardar")
            )
        )
      )
    ),
    
    # Parte derecha: Tabla que muestra los usuarios
    div(style = "padding: 20px;",
      tableOutput("user_table")
    )
  )
)