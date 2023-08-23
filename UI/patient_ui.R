patient_ui <- fluidPage(
    shiny.i18n::usei18n(i18n),
    shinyjs::useShinyjs(),
    
    actionButton("addPatient", "Añadir paciente"),
    
    hidden(
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
)