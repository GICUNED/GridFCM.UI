
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
    
   
    renderizarTabla <- function(){
        output$user_table <- renderDT({
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
            DT::datatable(users, selection = 'single', rownames = FALSE)
        })
        }

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
           

            #ocultar simulaciones por si se habían desplegado
        
            shinyjs::hide("simulaciones_rep")
            shinyjs::hide("simulaciones_wimp")
            shinyjs::hide("patientSimulations")
            # Obtén el ID del usuario de la fila seleccionada
            users <- user_data$users
            selected_user_id <- users[selected_row, "id"]
            user_data$selected_user_id <- selected_user_id # reactiva
            
            con <- establishDBConnection()
            pacientename <- DBI::dbGetQuery(con, sprintf("SELECT nombre from paciente WHERE id = %d", user_data$selected_user_id))
            nombrePaciente(pacientename)
            DBI::dbDisconnect(con)

            # Ahora puedes utilizar selected_user_id para realizar acciones específicas
            # relacionadas con el usuario seleccionado, como mostrar detalles adicionales,
            # eliminar el usuario de la base de datos, etc.
            
            # Por ejemplo, imprimir el ID del usuario en la consola
            message(paste("id del paciente: ", selected_user_id))

           
            
            #  pacientename <- DBI::dbGetQuery(con, sprintf("SELECT nombre from paciente WHERE id = %d", user_data$selected_user_id))
            #  nombrePaciente(pacientename)
            
            
        } else {
                shinyjs::hide("simulationIndicatorRG")
                shinyjs::hide("simulationIndicatorWG")
                shinyjs::hide("patientIndicator")
        }
    })

    
    # gestion de las filas seleccionadas en la tabla de simulaciones repgrid
    observeEvent(input$simulaciones_rep_rows_selected, {
        selected_row <- input$simulaciones_rep_rows_selected
        proxy <- dataTableProxy("simulaciones_wimp")

        if (!is.null(selected_row)) {
            proxy %>% selectRows(NULL) # deselecciono la fila wimpgrid
            wimpgrid_fecha_seleccionada(NULL) # reseteo la fecha wimpgrid
            shinyjs::enable("borrarSimulacion")
            shinyjs::enable("cargarSimulacion")
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
            shinyjs::enable("borrarSimulacion")
            shinyjs::enable("cargarSimulacion")
            fechas <- wimpgrid_data_DB$fechas
            fecha <- fechas[selected_row]
            session$userData$fecha_wimpgrid <- fecha
            wimpgrid_fecha_seleccionada(fecha)
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
                datatable(data.frame(Fecha = repgrid_data_DB$fechas), selection = 'single', options = list(order = list(1, 'asc')))
            })
        }
    }

    cargar_fechas_wimpgrid <- function(){
        con <- establishDBConnection()
        query <- sprintf("SELECT distinct(fecha_registro) FROM wimpgrid_xlsx WHERE fk_paciente=%d", user_data$selected_user_id)
        wimpgridDB <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        
        if(!is.null(wimpgridDB)){
            fecha_hora <- wimpgridDB$fecha_registro#as.POSIXct(repgridDB$fecha_registro, origin = "1970-01-01", tz = "Europe/Madrid")
            fechasWimp <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
            wimpgrid_data_DB$fechas <- fechasWimp

            delay(200, shinyjs::show("simulationIndicatorWG"))
            
            output$simulaciones_wimp <- renderDT({
                datatable(data.frame(Fecha = wimpgrid_data_DB$fechas), selection = 'single', options = list(order = list(1, 'asc')))
            })
        }
    }

    observeEvent(input$simulacionesDisponibles, {

        cargar_fechas_wimpgrid()
        cargar_fechas()

        runjs(
            "$( document ).ready(function() {
                  setTimeout(function() {
                    window.scrollTo(0,document.body.scrollHeight);
                }, 200)
            })"
        )

        shinyjs::show("simulaciones_wimp")
        shinyjs::show("patientSimulations")
        shinyjs::show("simulaciones_rep")
        delay(200, shinyjs::show("patientIndicator"))

        observeEvent(input$tabSimulaciones, {

            runjs(
            "$( document ).ready(function() {
                  setTimeout(function() {
                    window.scrollTo(0,document.body.scrollHeight);
                }, 200)
            })"
        )
            
        })

       
        
    })

    observeEvent(input$borrarSimulacion, {
        nombrepaciente <- nombrePaciente()
        showModal(modalDialog(
            title = "Confirmar borrado",
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
        }
    })
    
    # Editar simulaciones repgrid. Guardar los datos
    # boton de cargar simulacion seleccionada
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
        }
    })


    observeEvent(input$importarGridPaciente, {
        shinyjs::hide("patientSimulations")
        session$userData$id_paciente <- user_data$selected_user_id
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

        renderizarTabla()
        shinyjs::hide("patientSimulations")
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
        pacientename <- nombrePaciente()
        paste(icon = icon("universal-access"), "<b class='patient-active-name'>", pacientename, "</b>")
    })

    output$paciente_activo <- renderText({
        pacientename <- nombrePaciente()
        paste("<b class='patient-active-nav'>", pacientename, "</b>")
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
