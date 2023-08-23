patient_server <- function(input, output, session){
    observeEvent(input$addPatient, {
        shinyjs::show("patientForm")
    })
    shinyjs::onevent("click", "guardarAddPatient", {
        con <- establishDBConnection()

        nombre <- input$nombre
        edad <- input$edad
        genero <- input$genero
        anotaciones <- input$anotaciones
        fecha_registro <- as.POSIXct(Sys.time(), tz = "Europe/Madrid")
        fk_psicologo <- 1 # de momento 


        # Insertar los datos en la base de datos
        query <- sprintf("INSERT INTO paciente (nombre, edad, genero, anotaciones, fecha_registro, fk_psicologo) VALUES ('%s', %d, '%s', '%s', '%s', '%d')",
                        nombre, edad, genero, anotaciones, fecha_registro, fk_psicologo)
        DBI::dbExecute(con, query)
        DBI::dbDisconnect(con)

        # Vaciar los campos del formulario
        updateTextInput(session, "nombre", value = "")
        updateNumericInput(session, "edad", value = 0)
        updateSelectInput(session, "genero", selected = "")
        updateTextInput(session, "anotaciones", value = "")
    })
}
