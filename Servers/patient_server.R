patient_server <- function(input, output, session){
    observeEvent(input$addPatient, {
        shinyjs::show("patientForm")
    })

    runjs("
        $('#addPatient').on('click', function (){
            $('#patientForm').addClass('anim-fade-in');
            $('#patientForm').removeClass('anim-fade-out');}
        );
    ")

    
    shinyjs::onevent("click", "guardarAddPatient", {
        
        con <- establishDBConnection()

        nombre <- input$nombre
        edad <- input$edad
        genero <- input$genero
        anotaciones <- input$anotaciones
        fecha_registro <- as.POSIXct(Sys.time(), tz = "Europe/Madrid")
        fk_psicologo <- 1 # de momento 

        if (is.numeric(edad) && edad >= 0 && edad <= 120) {
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
        }
        # falta el else con el mensaje de error
    })

    runjs("
    $('#new-patient-cancel').on('click', function (){
            $('#patientForm').removeClass('anim-fade-in');
            $('#patientForm').addClass('anim-fade-out'); }
        );
        ")

    shinyjs::onevent("click", "new-patient-cancel", {
        
        delay(100, shinyjs::hide("patientForm"))
        
    }, add = TRUE)

    output$user_table <- renderTable({
        con <- establishDBConnection()
        query <- "SELECT * FROM paciente"
        users <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        
        users$genero <- as.factor(users$genero)
        
        users
    })
}