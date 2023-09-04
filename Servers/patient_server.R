patient_server <- function(input, output, session){

    user_data <- reactiveValues(users = NULL, selected_user_id = NULL)
    repgrid_data_DB <- reactiveValues(fechas = NULL)

    renderizarTabla <- function(){
        con <- establishDBConnection()
        query <- "SELECT * FROM paciente"
        users <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        users$genero <- as.factor(users$genero)
        # Convertir a un objeto POSIXct (Fecha y Hora) en R con la zona horaria de Madrid
        fecha_hora <- as.POSIXct(users$fecha_registro, origin = "1970-01-01")
        # Formatear la fecha y hora en un formato legible
        users$fecha_registro <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
        user_data$users <- users # variable reactiva
        DT::datatable(users, selection = 'single')
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

        $('#editarPaciente').on('click', function (){
            $('#editForm').addClass('anim-fade-in');
            $('#editForm').removeClass('anim-fade-out');}
        );
    ")

    # gestion de las filas seleccionadas en la tabla pacientes
    observeEvent(input$user_table_rows_selected, {
        selected_row <- input$user_table_rows_selected
        if (!is.null(selected_row)) {
            # Obtén el ID del usuario de la fila seleccionada
            users <- user_data$users
            selected_user_id <- users[selected_row, "id"]
            user_data$selected_user_id <- selected_user_id # reactiva
            
            # Ahora puedes utilizar selected_user_id para realizar acciones específicas
            # relacionadas con el usuario seleccionado, como mostrar detalles adicionales,
            # eliminar el usuario de la base de datos, etc.
            
            # Por ejemplo, imprimir el ID del usuario en la consola
            message(selected_user_id)
        }
    })

    # gestion de las filas seleccionadas en la tabla de simulaciones repgrid
    observeEvent(input$simulaciones_rep_rows_selected, {
        selected_row <- input$simulaciones_rep_rows_selected

        if (!is.null(selected_row)) {
            # hacer consulta para obtener el txt de repgrid aqui con la fecha seleccionada
            fechas <- repgrid_data_DB$fechas
            fecha <- fechas[selected_row]
            session$userData$fecha_repgrid <- fecha
        }

        
    })
    
    
    observeEvent(input$simulacionesRepgrid, {
        con <- establishDBConnection()
        query <- sprintf("SELECT distinct(fecha_registro) FROM repgrid_xlsx WHERE fk_paciente=%d", user_data$selected_user_id)
        repgridDB <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        
        if(!is.null(repgridDB)){
            fecha_hora <- repgridDB$fecha_registro#as.POSIXct(repgridDB$fecha_registro, origin = "1970-01-01", tz = "Europe/Madrid")
            fechasRep <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
            repgrid_data_DB$fechas <- fechasRep

            output$simulaciones_rep <- renderDT({
                datatable(data.frame(Fecha = repgrid_data_DB$fechas), selection = 'single')
            })
        }
        
    })
    
    # Editar simulaciones repgrid. Guardar los datos
    # boton de cargar simulacion seleccionada
    observeEvent(input$editarSimulacionRepgrid, {
        # codigo duplicado de importar excel server....
        ruta_destino <- "/srv/shiny-server/ficheros/excel_rep.xlsx"
        decodificar_BD_excel('repgrid_xlsx', ruta_destino, user_data$selected_user_id, session$userData$fecha_repgrid )

        datos_repgrid <- OpenRepGrid::importExcel(ruta_destino)
        
        excel_repgrid <- read.xlsx(ruta_destino)

        #convertir nums a formato numerico y no texto como estaba importado
        columnas_a_convertir <- 2:(ncol(excel_repgrid) - 1)
        # Utiliza lapply para aplicar la conversión a las columnas seleccionadas
        excel_repgrid[, columnas_a_convertir] <- lapply(excel_repgrid[, columnas_a_convertir], as.numeric)

        session$userData$datos_to_table <- excel_repgrid
        num_columnas <- ncol(session$userData$datos_to_table)
        session$userData$num_col_repgrid <- num_columnas
        num_rows <- nrow(session$userData$datos_to_table)
        session$userData$num_row_repgrid <- num_rows
        session$userData$datos_repgrid <- datos_repgrid

        if (!is.null(datos_repgrid)) {
            # Solo archivo RepGrid cargado, navegar a RepGrid Home
            session$userData$id_paciente <- user_data$selected_user_id
            repgrid_home_server(input,output,session)
            runjs("window.location.href = '/#!/repgrid';")
        } 
    })


    shinyjs::onevent("click", "editarPaciente", {
        con <- establishDBConnection()

        # de momento 1, luego deberia coger el paciente de la fila correspondiente
        query <- sprintf("SELECT * FROM paciente where id = %d", user_data$selected_user_id ) 
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
                 nombre, edad, genero, anotaciones, user_data$selected_user_id )

            DBI::dbExecute(con, query)

            output$user_table <- renderDT({
                renderizarTabla()
            })

            #cerrar el formulario al darle a editar si todo esta ok, en vez de vaciar todos los campos como en insertar, aqui no tiene sentido
        }
        else{
            mensaje <- paste("El valor debe estar entre el rango 0 y 120.")
            showModal(modalDialog(
                title = "Error",
                mensaje,
                easyClose = TRUE
            ))
        }

        DBI::dbDisconnect(con)
    })

    shinyjs::onevent("click", "borrarPaciente", {
        # habría que sacar un mensajito diciendo seguro que quiere eliminar...
        con <- establishDBConnection()
        #borrar simulaciones asociadas

        queryRep <- sprintf("DELETE FROM repgrid_xlsx where fk_paciente = %d", user_data$selected_user_id)
        queryWimp <- sprintf("DELETE FROM wimpgrid_xlsx where fk_paciente = %d", user_data$selected_user_id)
        DBI::dbExecute(con, queryRep)
        DBI::dbExecute(con, queryWimp)

        # borrar tabla intermedia
        # cambiar luego los ids
        query1 <- sprintf("DELETE FROM psicologo_paciente WHERE fk_paciente = %d", user_data$selected_user_id)
        DBI::dbExecute(con, query1)
        # borrar el paciente
        query2 <- sprintf("DELETE FROM paciente WHERE id = %d", user_data$selected_user_id)
        DBI::dbExecute(con, query2)
        
        # Borrar simulaciones 

        DBI::dbDisconnect(con)

        #output$user_table <- renderDT({
        #    renderizarTabla()
        #})
    })
    
    shinyjs::onevent("click", "guardarAddPatient", {
        
        con <- establishDBConnection()

        nombre <- input$nombre
        edad <- input$edad
        genero <- input$genero
        anotaciones <- input$anotaciones
        fecha_registro <- format(Sys.time(), format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Madrid")
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

            #output$user_table <- renderDT({
            #    renderizarTabla()
            #})
        }
        else{
            mensaje <- paste("El valor debe estar entre el rango 0 y 120.")
            showModal(modalDialog(
                title = "Error",
                mensaje,
                easyClose = TRUE
            ))
        }
    })

    observeEvent(input$importarGridPaciente, {
        # hacer que no se muestren lo de ficheros y formularios??? no se
        session$userData$id_paciente <- user_data$selected_user_id
        import_excel_server(input, output, session)
        runjs("window.location.href = '/#!/import';")
    })

    runjs("
    $('#new-patient-cancel').on('click', function (){
        $('#patientForm').removeClass('anim-fade-in');
        $('#patientForm').addClass('anim-fade-out'); }
    );
    $('#edit-patient-cancel').on('click', function (){
        $('#editForm').removeClass('anim-fade-in');
        $('#editForm').addClass('anim-fade-out'); }
    );
    ")

    shinyjs::onevent("click", "new-patient-cancel", {
        
        delay(100, shinyjs::hide("patientForm"))
        
    }, add = TRUE)
    shinyjs::onevent("click", "edit-patient-cancel", {
        
        delay(100, shinyjs::hide("editForm"))
        
    }, add = TRUE)

}
