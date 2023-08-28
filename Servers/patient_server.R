patient_server <- function(input, output, session){

    renderizarTabla <- function(){
        con <- establishDBConnection()
        query <- "SELECT * FROM paciente"
        users <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        users$genero <- as.factor(users$genero)
        # Convertir a un objeto POSIXct (Fecha y Hora) en R con la zona horaria de Madrid
        fecha_hora <- as.POSIXct(users$fecha_registro, origin = "1970-01-01", tz = "Europe/Madrid")
        # Formatear la fecha y hora en un formato legible
        users$fecha_registro <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
        users
    }
    renderizarTabla_opcion2 <- function(){
        con <- establishDBConnection()
        query <- "SELECT * FROM paciente"
        users <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        users$genero <- as.factor(users$genero)
        
        fecha_hora <- as.POSIXct(users$fecha_registro, origin = "1970-01-01", tz = "Europe/Madrid")
        users$fecha_registro <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
        
        datatable(users, escape = FALSE, options = list(
            columnDefs = list(list(targets = ncol(users), render = JS(
                "function(data, type, row, meta) {",
                "return '<button class=\"btn btn-primary\">Editar/Borrar/Repgrid/Wimpgrid(WIP)</button>';",
                "}"
            )))
        ))

        # ademas deberia haber boton de acceso a simulaciones de repgrid y wimpgrid del paciente, 
        # otro boton que permita importar y le lleve a la pagina de "importar"
        # ToDo Simon -> una vez esten los botones, gestionar dentro de session$patientID el id del paciente con el que se trabaja 
    }

    output$user_table <- renderDT({
        renderizarTabla()
    })
    
    observeEvent(input$addPatient, {
        shinyjs::show("patientForm")
    })

    runjs("
        $('#addPatient').on('click', function (){
            $('#patientForm').addClass('anim-fade-in');
            $('#patientForm').removeClass('anim-fade-out');}
        );
    ")

    shinyjs::onevent("click", "editarPaciente", {
        con <- establishDBConnection()

        # de momento 1, luego deberia coger el paciente de la fila correspondiente
        query <- "SELECT * FROM paciente where id = 2" 
        users <- DBI::dbGetQuery(con, query)

        shinyjs::show("editForm")
        updateTextInput(session, "nombreEdit", value = users$nombre)
        updateNumericInput(session, "edadEdit", value = users$edad)
        updateSelectInput(session, "generoEdit", selected = users$genero)
        updateTextInput(session, "anotacionesEdit", value = users$anotaciones)

        DBI::dbDisconnect(con)
    })
    shinyjs::onevent("click", "saveEdit", {
        con <- establishDBConnection()

        nombre <- input$nombreEdit
        edad <- input$edadEdit
        genero <- input$generoEdit
        anotaciones <- input$anotacionesEdit

        if (is.numeric(edad) && edad >= 0 && edad <= 120) {
            # Insertar los datos en la base de datos
            query <- sprintf("UPDATE paciente SET nombre = '%s', edad = %d, genero = '%s', anotaciones = '%s' WHERE id = %d",
                 nombre, edad, genero, anotaciones, 2)

            DBI::dbExecute(con, query)

            output$user_table <- renderDT({
                renderizarTabla()
            })

            #cerrar el formulario al darle a editar si todo esta ok, en vez de vaciar todos los campos como en insertar, aqui no tiene sentido
        }
        # else mensaje de error

        DBI::dbDisconnect(con)
    })

    shinyjs::onevent("click", "borrarPaciente", {
        # habría que sacar un mensajito diciendo seguro que quiere eliminar...
        con <- establishDBConnection()
        #borrar simulaciones asociadas

        queryRep <- "DELETE FROM repgrid where fk_paciente = 2"
        queryWimp <- "DELETE FROM wimpgrid where fk_paciente = 2"
        DBI::dbExecute(con, queryRep)
        DBI::dbExecute(con, queryWimp)

        # borrar tabla intermedia
        # cambiar luego los ids
        query1 <- "DELETE FROM psicologo_paciente WHERE fk_paciente = 2"
        DBI::dbExecute(con, query1)
        # borrar el paciente
        query2 <- "DELETE FROM paciente WHERE id = 2"
        DBI::dbExecute(con, query2)
        
        # Borrar simulaciones 

        DBI::dbDisconnect(con)

        output$user_table <- renderDT({
            renderizarTabla()
        })
    })
    
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
            query <- sprintf("INSERT INTO paciente (nombre, edad, genero, anotaciones, fecha_registro) VALUES ('%s', %d, '%s', '%s', '%s')",
                            nombre, edad, genero, anotaciones, fecha_registro)
            DBI::dbExecute(con, query)

            query_id_paciente <- sprintf("SELECT id FROM paciente WHERE nombre = '%s' and anotaciones = '%s' and genero = '%s' and edad = '%s'", nombre, anotaciones, genero, edad)
            id_paciente <- DBI::dbGetQuery(con, query_id_paciente)
            id_paciente <- as.integer(id_paciente)

            id_psicologo <- 1 # de momento

            query2 <- sprintf("INSERT INTO psicologo_paciente (fk_psicologo, fk_paciente) VALUES (%d, %d)", id_psicologo, id_paciente)
            DBI::dbExecute(con, query2)


            DBI::dbDisconnect(con)

            # Vaciar los campos del formulario
            updateTextInput(session, "nombre", value = "")
            updateNumericInput(session, "edad", value = 0)
            updateSelectInput(session, "genero", selected = "")
            updateTextInput(session, "anotaciones", value = "")

            output$user_table <- renderDT({
                renderizarTabla()
            })
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
    shinyjs::onevent("click", "edit-patient-cancel", {
        
        delay(100, shinyjs::hide("editForm"))
        
    }, add = TRUE)

}
