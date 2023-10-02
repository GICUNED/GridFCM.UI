patient_server <- function(input, output, session){
    user_data <- reactiveValues(users = NULL, selected_user_id = NULL)
    repgrid_data_DB <- reactiveValues(fechas = NULL)
    wimpgrid_data_DB <- reactiveValues(fechas = NULL)
    repgrid_fecha_seleccionada <- reactiveVal(NULL)
    wimpgrid_fecha_seleccionada <- reactiveVal(NULL)
    nombrePaciente <- reactiveVal()

    shinyjs::hide("patientSimulations")
    shinyjs::hide("patientIndicator")
    shinyjs::hide("simulationIndicatorRG")
    shinyjs::hide("simulationIndicatorWG")

    shinyjs::hide("import-page")
    shinyjs::hide("form-page")
    shinyjs::hide("excel-page")

    renderizarTabla <- function(){
        output$user_table <- renderDT({
            con <- establishDBConnection()
            query <- sprintf("SELECT p.nombre, p.edad, p.genero, p.fecha_registro, p.diagnostico, p.anotaciones FROM paciente as p, psicologo_paciente as pp WHERE pp.fk_paciente = p.id and pp.fk_psicologo = %d", 1)
            users <- DBI::dbGetQuery(con, query)
            DBI::dbDisconnect(con)
            
            # Cambiar los nombres de las columnas
            colnames(users) <- c("Name", "Age", "Gender", "Registered", "Problem", "Annotations")
            
            # Convertir género en factor
            users$Gender <- as.factor(users$Gender)
            
            # Convertir fecha_registro a POSIXct y formatear
            fecha_hora <- as.POSIXct(users$Registered, origin = "1970-01-01")
            users$Registered <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
            
            user_data$users <- users # variable reactiva
            DT::datatable(users, selection = 'single', rownames = FALSE)
        })
    }


    # si se borran todos los pacientes...
    observe({
        if(length(user_data$users) == 0){
            shinyjs::disable("borrarPaciente")
            shinyjs::disable("simulacionesDisponibles")
            shinyjs::disable("editarPaciente")
            shinyjs::disable("importarGridPaciente")
        }
    })

    renderizarTabla()
    
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
            shinyjs::enable("borrarPaciente")
            shinyjs::enable("simulacionesDisponibles")
            shinyjs::enable("editarPaciente")
            shinyjs::enable("importarGridPaciente")
            shinyjs::disable("borrarSimulacion")

            #ocultar simulaciones por si se habían desplegado
            delay(200, shinyjs::show("patientIndicator"))
            shinyjs::hide("simulaciones_rep")
            shinyjs::hide("simulaciones_wimp")
            shinyjs::hide("patientSimulations")
            # Obtén el ID del usuario de la fila seleccionada
            users <- user_data$users
            date <- users[selected_row, "Registered"]
            name <- users[selected_row, "Name"]
            age <- as.integer(users[selected_row, "Age"])
            con <- establishDBConnection()
            query <- sprintf("SELECT id from PACIENTE WHERE edad=%d and nombre='%s' and fecha_registro='%s'", age, name, date)
            selected_user_id <- as.integer(DBI::dbGetQuery(con, query))
            user_data$selected_user_id <- selected_user_id # reactiva
            
            pacientename <- DBI::dbGetQuery(con, sprintf("SELECT nombre from paciente WHERE id = %d", user_data$selected_user_id))
            nombrePaciente(pacientename)
            DBI::dbDisconnect(con)
            shinyjs::show("simulaciones_wimp")
            shinyjs::show("patientSimulations")
            shinyjs::show("simulaciones_rep")

            shinyjs::show("import-page")
            shinyjs::show("form-page")
            shinyjs::show("excel-page")

            cargar_fechas_wimpgrid()
            cargar_fechas()
            message(paste("id del paciente: ", selected_user_id))            
            
        } else {
                shinyjs::hide("simulationIndicatorRG")
                shinyjs::hide("simulationIndicatorWG")
                shinyjs::hide("patientIndicator")
        }
    })

    cargar_fechas <- function(){
        con <- establishDBConnection()
        query <- sprintf("SELECT distinct(fecha_registro) FROM repgrid_xlsx WHERE fk_paciente=%d", user_data$selected_user_id)
        repgridDB <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        
        if(!is.null(repgridDB)){
            fecha_hora <- repgridDB$fecha_registro#as.POSIXct(repgridDB$fecha_registro, origin = "1970-01-01", tz = "Europe/Madrid")
            fechasRep <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
            repgrid_data_DB$fechas <- fechasRep

            delay(200, shinyjs::show("simulationIndicatorRG"))

            output$simulaciones_rep <- renderDT({
                datatable(data.frame(Fecha = repgrid_data_DB$fechas), selection = 'single', rownames = FALSE, options = list(order = list(0, 'asc')))
            })
        }
    }

    cargar_fechas_wimpgrid <- function(){
        con <- establishDBConnection()
        query <- sprintf("SELECT distinct(fecha_registro), comentarios FROM wimpgrid_xlsx, wimpgrid_params WHERE fk_paciente=%d and wimpgrid_xlsx.id = fk_wimpgrid", user_data$selected_user_id)
        wimpgridDB <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        
        if(!is.null(wimpgridDB)){
            fecha_hora <- wimpgridDB$fecha_registro#as.POSIXct(repgridDB$fecha_registro, origin = "1970-01-01", tz = "Europe/Madrid")
            fechasWimp <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
            wimpgrid_data_DB$fechas <- fechasWimp
            anotaciones <- wimpgridDB$comentarios 

            delay(200, shinyjs::show("simulationIndicatorWG"))
            
            output$simulaciones_wimp <- renderDT({
                datatable(data.frame(Registered = fechasWimp, Annotations = anotaciones), selection = 'single', rownames = FALSE, options = list(order = list(0, 'asc')))
            })
        }
    }
    
    # gestion de las filas seleccionadas en la tabla de simulaciones repgrid
    observeEvent(input$simulaciones_rep_rows_selected, {
        selected_row <- input$simulaciones_rep_rows_selected
        proxy <- dataTableProxy("simulaciones_wimp")

        if (!is.null(selected_row)) {
            proxy %>% selectRows(NULL) # deselecciono la fila wimpgrid
            wimpgrid_fecha_seleccionada(NULL) # reseteo la fecha wimpgrid
            shinyjs::enable("cargarSimulacion")
            shinyjs::enable("borrarSimulacion")
            # hacer consulta para obtener el txt de repgrid aqui con la fecha seleccionada
            fechas <- repgrid_data_DB$fechas
            fecha <- fechas[selected_row]
            session$userData$fecha_repgrid <- fecha
            repgrid_fecha_seleccionada(fecha)
        }
    })
    
    # gestion de las filas seleccionadas en la tabla de simulaciones wimpgrid
    observeEvent(input$simulaciones_wimp_rows_selected, {
        selected_row <- input$simulaciones_wimp_rows_selected
        proxy <- dataTableProxy("simulaciones_rep")
        if (!is.null(selected_row)) {
            proxy %>% selectRows(NULL) # deselecciono la fila repgrid
            repgrid_fecha_seleccionada(NULL) # reseteo la fecha repgrid el boton cargar
            shinyjs::enable("cargarSimulacion")
            shinyjs::enable("borrarSimulacion")
            fechas <- wimpgrid_data_DB$fechas
            fecha <- fechas[selected_row]
            session$userData$fecha_wimpgrid <- fecha
            wimpgrid_fecha_seleccionada(fecha)
      
        }
    })

    observeEvent(input$cargarSimulacion, {
        id_paciente <- user_data$selected_user_id
        fecha_rep <- session$userData$fecha_repgrid
        fecha_wimp <- session$userData$fecha_wimpgrid
        if(!is.null(repgrid_fecha_seleccionada()) || !is.null(wimpgrid_fecha_seleccionada())){
            if(!is.null(repgrid_fecha_seleccionada())){
                ruta_destino <- tempfile(fileext = ".xlsx")
                id <- decodificar_BD_excel('repgrid_xlsx', ruta_destino, id_paciente, fecha_rep)
                datos_repgrid <- OpenRepGrid::importExcel(ruta_destino)
                excel_repgrid <- read.xlsx(ruta_destino)
                file.remove(ruta_destino)

                #convertir nums a formato numerico y no texto como estaba importado
                columnas_a_convertir <- 2:(ncol(excel_repgrid) - 1)
                # Utiliza lapply para aplicar la conversión a las columnas seleccionadas
                excel_repgrid[, columnas_a_convertir] <- lapply(excel_repgrid[, columnas_a_convertir], as.numeric)

                #constructos
                constructos_izq <- excel_repgrid[1:nrow(excel_repgrid), 1]
                constructos_der <- excel_repgrid[1:nrow(excel_repgrid), ncol(excel_repgrid)]
                session$userData$constructos_izq_rep <- constructos_izq
                session$userData$constructos_der_rep <- constructos_der

                session$userData$datos_to_table <- excel_repgrid
                num_columnas <- ncol(session$userData$datos_to_table)
                session$userData$num_col_repgrid <- num_columnas
                num_rows <- nrow(session$userData$datos_to_table)
                session$userData$num_row_repgrid <- num_rows
                session$userData$datos_repgrid <- datos_repgrid
                #repgrid_fecha_seleccionada(NULL)

                if (!is.null(datos_repgrid)) {
                    # Solo archivo RepGrid cargado, navegar a RepGrid Home
                    session$userData$id_paciente <- user_data$selected_user_id
                    repgrid_home_server(input,output,session)
                    runjs("window.location.href = '/#!/repgrid';")
                } 
            }
            if(!is.null(wimpgrid_fecha_seleccionada())){
                ruta_destino <- tempfile(fileext = ".xlsx")
                id <- decodificar_BD_excel('wimpgrid_xlsx', ruta_destino, id_paciente, fecha_wimp)
                session$userData$id_wimpgrid <- id
                datos_wimpgrid <- importwimp(ruta_destino)
                excel_wimp <- read.xlsx(ruta_destino)
                file.remove(ruta_destino)
                # convertir los numeros tipo string a tipo numerico
                columnas_a_convertir <- 2:(ncol(excel_wimp) - 1)
                # Utiliza lapply para aplicar la conversión a las columnas seleccionadas
                excel_wimp[, columnas_a_convertir] <- lapply(excel_wimp[, columnas_a_convertir], as.numeric)

                #constructos
                constructos_izq <- excel_wimp[1:nrow(excel_wimp), 1]
                constructos_der <- excel_wimp[1:nrow(excel_wimp), ncol(excel_wimp)]
                session$userData$constructos_izq <- constructos_izq
                session$userData$constructos_der <- constructos_der

                session$userData$datos_to_table_w <- excel_wimp
                num_columnas <- ncol(session$userData$datos_to_table_w)
                session$userData$num_col_wimpgrid <- num_columnas
                num_rows <- nrow(session$userData$datos_to_table_w)
                session$userData$num_row_wimpgrid <- num_rows
                # Almacenar los objetos importados en el entorno de la sesión para su uso posterior
                #session$userData$datos_repgrid <- datos_repgrid
                session$userData$datos_wimpgrid <- datos_wimpgrid
                #wimpgrid_fecha_seleccionada(NULL)

                if (!is.null(datos_wimpgrid)) {
                    session$userData$id_paciente <- user_data$selected_user_id
                    wimpgrid_analysis_server(input,output,session)
                    runjs("window.location.href = '/#!/wimpgrid';")
                }   
            }
            proxy <- dataTableProxy("user_table")
            proxy %>% selectRows(NULL)
            shinyjs::hide("patientSimulations")
        }
    })

    observeEvent(input$borrarSimulacion, {
        nombrepaciente <- nombrePaciente()
        showModal(modalDialog(
            title = i18n$t("Confirmar borrado"),
            sprintf("¿Está seguro de que quiere eliminar esta simulación de %s? Esto no se puede deshacer.", nombrepaciente),
            footer = tagList(
            modalButton("Cancelar"),
            actionButton("confirmarBorradoSimulacion", "Confirmar", class = "btn-danger")
            )
        ))
    })

    observeEvent(input$confirmarBorradoSimulacion, {
        removeModal()  # Cierra la ventana modal de confirmación
        
        # Proceso de borrado de la simulación
        id_paciente <- user_data$selected_user_id
        fecha_rep <- repgrid_fecha_seleccionada()
        fecha_wimp <- wimpgrid_fecha_seleccionada()
        
        if (!is.null(fecha_rep) || !is.null(fecha_wimp)) {
            con <- establishDBConnection()
            if (!is.null(fecha_rep)) {
                query <- sprintf("DELETE FROM repgrid_xlsx where fecha_registro = '%s' and fk_paciente = %d", fecha_rep, id_paciente)
                DBI::dbExecute(con, query)
                cargar_fechas()
            }
            if (!is.null(fecha_wimp)) {
                id_wx <- as.integer(DBI::dbGetQuery(con, sprintf("SELECT distinct(wp.fk_wimpgrid) from wimpgrid_params as wp, wimpgrid_xlsx as wx where wp.fk_wimpgrid = wx.id and wx.fk_paciente = %d and wx.fecha_registro = '%s'", 
                                                    user_data$selected_user_id, fecha_wimp)))
                if (!is.na(id_wx)) {
                    query_wp <- sprintf("DELETE FROM wimpgrid_params where fk_wimpgrid = %d", id_wx)
                    DBI::dbExecute(con, query_wp)
                }
                query <- sprintf("DELETE FROM wimpgrid_xlsx where fecha_registro = '%s' and fk_paciente = %d", fecha_wimp, id_paciente)
                DBI::dbExecute(con, query)
                cargar_fechas_wimpgrid()
            }
            DBI::dbDisconnect(con)
            shinyjs::disable("borrarSimulacion")           
        }
    })


    observeEvent(input$importarGridPaciente, {
        shinyjs::hide("patientSimulations")
        session$userData$id_paciente <- user_data$selected_user_id
        proxy <- dataTableProxy("user_table")
        proxy %>% selectRows(NULL)
        import_excel_server(input, output, session)
        runjs("window.location.href = '/#!/import';")
    })

    shinyjs::onevent("click", "patientIndicator", {
        runjs("window.location.href = '/#!/patient';")
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
        updateTextInput(session, "diagnosticoEdit", value = users$diagnostico)
        updateTextInput(session, "anotacionesEdit", value = users$anotaciones)

        DBI::dbDisconnect(con)
    })

    shinyjs::onevent("click", "saveEdit", {

        con <- establishDBConnection()

        nombre <- input$nombreEdit
        edad <- input$edadEdit
        genero <- input$generoEdit
        diagnostico <- input$diagnosticoEdit
        anotaciones <- input$anotacionesEdit

        if (is.numeric(edad) && edad >= 0 && edad <= 120) {
            # Insertar los datos en la base de datos
            query <- sprintf("UPDATE paciente SET nombre = '%s', edad = %d, genero = '%s', diagnostico = '%s', anotaciones = '%s' WHERE id = %d",
                 nombre, edad, genero, diagnostico, anotaciones, user_data$selected_user_id )
            DBI::dbExecute(con, query)
            
            renderizarTabla()
            
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

    observeEvent(input$borrarPaciente, {
        if(!is.null(nombrePaciente)){
            showModal(modalDialog(
                title = i18n$t("Confirmar borrado"),
                i18n$t("¿Está seguro de que quiere eliminar al paciente? Se borrarán todas sus simulaciones"),
                footer = tagList(
                    modalButton(i18n$t("Cancelar")),
                    actionButton("confirmarBorrado", i18n$t("Confirmar"), class = "btn-danger")
                )
            ))
        }
        else{
            showModal(modalDialog(
                title = i18n$t("Debe seleccionar un paciente para poder borrarlo."),
                    modalButton(i18n$t("OK"))
                )
            )
        }
    })
    observeEvent(input$confirmarBorrado, {
        removeModal()  # Cierra la ventana modal de confirmación
        # habría que sacar un mensajito diciendo seguro que quiere eliminar...
        con <- establishDBConnection()
        #borrar simulaciones asociadas

        queryRep <- sprintf("DELETE FROM repgrid_xlsx where fk_paciente = %d", user_data$selected_user_id)
        DBI::dbExecute(con, queryRep)
        id_wx <- DBI::dbGetQuery(con, sprintf("SELECT distinct(wp.fk_wimpgrid) from wimpgrid_params as wp, wimpgrid_xlsx as wx where wp.fk_wimpgrid = wx.id and wx.fk_paciente = %d", user_data$selected_user_id))
        if (nrow(id_wx) > 0) {
            for (i in 1:nrow(id_wx)) {
                id <- id_wx[i, 1]
                query_wp <- sprintf("DELETE FROM wimpgrid_params where fk_wimpgrid = %d", id)
                DBI::dbExecute(con, query_wp)
            }
        }
        
        queryWimp <- sprintf("DELETE FROM wimpgrid_xlsx where fk_paciente = %d", user_data$selected_user_id)
        DBI::dbExecute(con, queryWimp)

        # borrar tabla intermedia
        # cambiar luego los ids
        query1 <- sprintf("DELETE FROM psicologo_paciente WHERE fk_paciente = %d", user_data$selected_user_id)
        DBI::dbExecute(con, query1)
        # borrar el paciente
        query2 <- sprintf("DELETE FROM paciente WHERE id = %d", user_data$selected_user_id)
        DBI::dbExecute(con, query2)

        DBI::dbDisconnect(con)
        user_data$selected_user_id <- NULL
        session$userData$id_paciente <- NULL
        shinyjs::disable("borrarPaciente")
        shinyjs::disable("simulacionesDisponibles")
        shinyjs::disable("editarPaciente")
        shinyjs::disable("importarGridPaciente")
        
        renderizarTabla()
        shinyjs::hide("patientSimulations")
        shinyjs::hide("import-page")
        shinyjs::hide("form-page")
        shinyjs::hide("excel-page")


    })
    
    observeEvent(input$nombre, {
        if(input$nombre != ""){
            shinyjs::enable("guardarAddPatient")
        }
        else{
            shinyjs::disable("guardarAddPatient")
        }
        
    })

    observeEvent(input$guardarAddPatient,  {
        con <- establishDBConnection()
        nombre <- input$nombre
        edad <- input$edad
        genero <- input$genero
        diagnostico <- input$diagnostico
        anotaciones <- input$anotaciones
        fecha_registro <- format(Sys.time(), format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Madrid")
        fk_psicologo <- 1 # de momento 
        
        if (is.numeric(edad) && edad >= 0 && edad <= 120) {
            # Insertar los datos en la base de datos
            query <- sprintf("INSERT INTO paciente (nombre, edad, genero, diagnostico, anotaciones, fecha_registro) VALUES ('%s', %d, '%s', '%s', '%s', '%s')",
                            nombre, edad, genero, diagnostico, anotaciones, fecha_registro)
            DBI::dbExecute(con, query)

            query_id_paciente <- sprintf("SELECT id FROM paciente WHERE nombre = '%s' and anotaciones = '%s' and fecha_registro = '%s'", nombre, anotaciones, fecha_registro)
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
            updateTextInput(session, "diagnostico", value = "")
            updateTextInput(session, "anotaciones", value = "")

            renderizarTabla()
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

    output$paciente_simulacion_header <- renderText({
        paste(icon = icon("universal-access"), nombrePaciente())
    })

    output$paciente_activo <- renderText({
        paste("<b class='patient-active-name'>", nombrePaciente(), "</b>")
    })

    output$simulation_active_rg <- renderText({
        paste("<p class='desccustom-date'>📅", repgrid_fecha_seleccionada(), "</p>")
    })

    output$simulation_active_wg <- renderText({
        paste("<p class='desccustom-date'>📅", wimpgrid_fecha_seleccionada(), "</p>")
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
