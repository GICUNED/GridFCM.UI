patient_server <- function(input, output, session){
    rol <- session$userData$rol
    id_psicologo <- session$userData$id_psicologo
    if(!is.null(rol)){
        if(rol == "usuario_demo"){
            shinyjs::disable("addPatient")
        }
    }
    
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
        # if rol gratis entonces limitamos el output de la query a 2
        limit_output <- FALSE
        if(!is.null(rol)){
            if(rol == "usuario_gratis"){
                con <- establishDBConnection()
                query <- sprintf("SELECT COUNT(DISTINCT p.id) as num FROM paciente as p, psicologo_paciente as pp 
                                    WHERE pp.fk_paciente = p.id and pp.fk_psicologo = %d", id_psicologo) # de momento
                num <- DBI::dbGetQuery(con, query)
                DBI::dbDisconnect(con)
                if(num$num >= 2){
                    shinyjs::disable("addPatient")
                }
                else{
                    shinyjs::enable("addPatient")
                }
                limit_output <- TRUE
            }
        }

        output$user_table <- renderDT({
            con <- establishDBConnection()
            query <- sprintf("SELECT p.nombre, p.edad, p.genero, p.fecha_registro, p.diagnostico, p.anotaciones FROM paciente as p, psicologo_paciente as pp 
                                WHERE pp.fk_paciente = p.id and pp.fk_psicologo = %d", session$userData$id_psicologo) # de momento
            if(limit_output){
                query = paste(query, " LIMIT 2")
            }
            users <- DBI::dbGetQuery(con, query)
            DBI::dbDisconnect(con)
            # Convertir género en factor
            users$genero <- as.factor(users$genero)
            
            # Convertir fecha_registro a POSIXct y formatear
            fecha_hora <- as.POSIXct(users$fecha_registro, origin = "1970-01-01")
            users$fecha_registro <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
            user_data$users <- users # variable reactiva
            df <- data.frame(n=users$nombre, e=users$edad, g=users$genero, f=users$fecha_registro, d=users$diagnostico, a=users$anotaciones)
            DT::datatable(df, selection = 'single', rownames = FALSE,
                options = list(order = list(3, 'asc')),
                colnames = c(i18n$t("Nombre"), i18n$t("Edad"), i18n$t("Género"), i18n$t("Fecha de Registro"), i18n$t("Problema"), i18n$t("Anotaciones")))
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

    if(!is.null(id_psicologo)){
        renderizarTabla()
    }
    
    shinyjs::onclick("addPatient",  {
        shinyjs::show("patientForm")
    })
    # observeEvent(input$addPatient, {
    #     message("presiono boton")
    #     shinyjs::show("patientForm")
    # })

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
            shinyjs::enable("importarGridPaciente")
            #ocultar simulaciones por si se habían desplegado
            delay(200, shinyjs::show("patientIndicator"))
            shinyjs::hide("simulaciones_rep")
            shinyjs::hide("simulaciones_wimp")
            shinyjs::hide("patientSimulations")
            shinyjs::hide("import-page")
            shinyjs::hide("form-page")
            shinyjs::hide("excel-page")
            # Obtén el ID del usuario de la fila seleccionada
            users <- user_data$users
            date <- users[selected_row, 4]
            name <- users[selected_row, 1]
            age <- as.integer(users[selected_row, 2])
            con <- establishDBConnection()
            query <- sprintf("SELECT id from PACIENTE WHERE edad=%d and nombre='%s' and fecha_registro='%s'", age, name, date)
            selected_user_id <- as.integer(DBI::dbGetQuery(con, query))
            user_data$selected_user_id <- selected_user_id # reactiva
            pacientename <- DBI::dbGetQuery(con, sprintf("SELECT nombre from paciente WHERE id = %d", user_data$selected_user_id))
            nombrePaciente(pacientename)
            DBI::dbDisconnect(con)
            if(rol != "usuario_demo"){
                shinyjs::enable("borrarPaciente")
                shinyjs::enable("simulacionesDisponibles")
                shinyjs::enable("editarPaciente")
                shinyjs::show("simulaciones_wimp")
                shinyjs::show("patientSimulations")
                shinyjs::show("simulaciones_rep")
            }

            cargar_fechas_wimpgrid()
            cargar_fechas()
            message(paste("id del paciente: ", selected_user_id))     
            message(paste("nombre: ", name))
            session$userData$id_paciente <- selected_user_id   
            
        } else {
            shinyjs::hide("simulationIndicatorRG")
            shinyjs::hide("simulationIndicatorWG")
            shinyjs::hide("patientIndicator")
        }
    })

    observeEvent(input$tabSimulaciones, {
        runjs("
        $('#patientSimulations')[0].scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
        ")

    })

    cargar_fechas <- function(){
        numero_aleatorio <- sample(1:1000, 1)
        con <- establishDBConnection()
        query <- sprintf("SELECT DISTINCT fecha_registro, comentarios FROM repgrid_xlsx WHERE fk_paciente=%d", user_data$selected_user_id)
        repgridDB <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        if(!is.null(repgridDB)){
            fecha_hora <- repgridDB$fecha_registro#as.POSIXct(repgridDB$fecha_registro, origin = "1970-01-01", tz = "Europe/Madrid")
            fechasRep <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
            repgrid_data_DB$fechas <- fechasRep
            delay(200, shinyjs::show("simulationIndicatorRG"))
            df <- data.frame(Fechas = repgrid_data_DB$fechas, Anotaciones = repgridDB$comentarios)
            output$simulaciones_rep <- renderDT({
                data_rep <- df %>%
                    mutate(
                        actionable = glue(
                            '<button id="custom_btn_abrir" onclick="Shiny.onInputChange(\'button_id_abrir\', {row_number()+numero_aleatorio})">Abrir</button>',
                            '<button id="custom_btn_borrar" onclick="Shiny.onInputChange(\'button_id_borrar\', {row_number()+numero_aleatorio})"></button>'
                        )
                    )
                datatable(
                    data_rep,
                    selection = "single",
                    rownames = FALSE,
                    escape = FALSE,
                    options = list(
                        order = list(0, 'asc'),
                        columnDefs = list(list(width = '125px', targets = ncol(data_rep) - 1 ))
                    ),
                    
                    colnames = c(i18n$t("Fecha"), i18n$t("Anotaciones"), "")
                )
            })

            runjs("
                $('#patientSimulations')[0].scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
                ")
            
        }
    }

    cargar_fechas_wimpgrid <- function(){
        numero_aleatorio <- sample(1:1000, 1)
        con <- establishDBConnection()
        query <- sprintf("SELECT DISTINCT wimpgrid_xlsx.fecha_registro, wimpgrid_params.comentarios 
                 FROM wimpgrid_xlsx
                 LEFT JOIN wimpgrid_params
                 ON wimpgrid_xlsx.id = wimpgrid_params.fk_wimpgrid
                 WHERE wimpgrid_xlsx.fk_paciente = %d", user_data$selected_user_id)

        wimpgridDB <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        
        if(!is.null(wimpgridDB)){
            fecha_hora <- wimpgridDB$fecha_registro
            fechasWimp <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
            wimpgrid_data_DB$fechas <- fechasWimp
            anotaciones <- wimpgridDB$comentarios 

            delay(200, shinyjs::show("simulationIndicatorWG"))
            
            output$simulaciones_wimp <- renderDT({
                df <- data.frame(Registered = fechasWimp, Annotations = anotaciones)
                data_wimp <- df %>%
                    mutate(
                        actionable = glue(
                            '<button id="custom_btn_abrir" onclick="Shiny.onInputChange(\'button_id_abrir_w\', {row_number()+numero_aleatorio})">Abrir</button>',
                            '<button id="custom_btn_borrar" onclick="Shiny.onInputChange(\'button_id_borrar_w\', {row_number()+numero_aleatorio})"></button>'
                        )
                    )
                datatable(
                    data_wimp,
                    selection = "single",
                    rownames = FALSE,
                    escape = FALSE,
                    options = list(
                        order = list(0, 'asc'),
                        columnDefs = list(list(width = '125px', targets = ncol(data_wimp) - 1))
                    ),
                    colnames = c(i18n$t("Fecha"), i18n$t("Anotaciones"), "")
                )
            })

            runjs("
                $('#patientSimulations')[0].scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
                ")
        }
    }

    observeEvent(input$simulaciones_rep_rows_selected, {
        selected_row <- input$simulaciones_rep_rows_selected
        proxy <- dataTableProxy("simulaciones_wimp")

        if (!is.null(selected_row)) {
            proxy %>% selectRows(NULL) # deselecciono la fila wimpgrid
            wimpgrid_fecha_seleccionada(NULL) # reseteo la fecha wimpgrid
            #shinyjs::enable("cargarSimulacion")
            #shinyjs::enable("borrarSimulacion")
            # hacer consulta para obtener el txt de repgrid aqui con la fecha seleccionada
            fechas <- repgrid_data_DB$fechas
            fecha <- fechas[selected_row]
            message(fecha)
            session$userData$fecha_repgrid <- fecha
            repgrid_fecha_seleccionada(fecha)
        }
    })

    # gestion de las filas seleccionadas en la tabla de simulaciones repgrid
    abrir_repgrid <- function(){
        tryCatch({
            if(!is.null(repgrid_fecha_seleccionada())){
                id_paciente <- user_data$selected_user_id
                ruta_destino <- tempfile(fileext = ".xlsx")
                id <- decodificar_BD_excel('repgrid_xlsx', ruta_destino, id_paciente, session$userData$fecha_repgrid)
                session$userData$id_repgrid <- id
                
                datos_repgrid <- OpenRepGrid::importExcel(ruta_destino)
                
                excel_repgrid <- read.xlsx(ruta_destino)
                file.remove(ruta_destino)
                # convertir nums a formato numerico y no texto como estaba importado
                columnas_a_convertir <- 2:(ncol(excel_repgrid) - 1)
                # Utiliza lapply para aplicar la conversión a las columnas seleccionadas
                excel_repgrid[, columnas_a_convertir] <- lapply(excel_repgrid[, columnas_a_convertir], as.numeric)
                
                # constructos
                constructos_izq <- excel_repgrid[1:nrow(excel_repgrid), 1]
                constructos_der <- excel_repgrid[1:nrow(excel_repgrid), ncol(excel_repgrid)]
                session$userData$constructos_izq_rep <- constructos_izq
                session$userData$constructos_der_rep <- constructos_der
                session$userData$datos_to_table <- excel_repgrid
                num_columnas <- ncol(session$userData$datos_to_table)
                session$userData$num_col_repgrid <- num_columnas
                num_rows <- nrow(session$userData$datos_to_table)
                session$userData$num_row_repgrid <- num_rows
                # escala
                nombres_columnas <- colnames(excel_repgrid)
                min <- as.numeric(nombres_columnas[1])
                max <- as.numeric(nombres_columnas[length(nombres_columnas)])
                session$userData$repgrid_min <- min
                session$userData$repgrid_max <- max

                session$userData$datos_repgrid <- alignByIdeal(datos_repgrid, ncol(datos_repgrid))
                #repgrid_fecha_seleccionada(NULL)
                if (!is.null(datos_repgrid)) {
                    # Solo archivo RepGrid cargado, navegar a RepGrid Home
                    session$userData$id_paciente <- user_data$selected_user_id
                    repgrid_home_server(input,output,session)

                    runjs("
                    setTimeout(function () {
                        window.location.href = '/#!/repgrid';
                        window.scrollTo(0,0);
                    }, 200);
                    ")

                    runjs("
                    $('#controls-panel-rg').removeClass('anim-fade-out');
                    $('#controls-panel-rg').addClass('anim-fade-in');

                    $('.graphics-rg').removeClass('mw-100');
                    $('.graphics-rg').removeClass('flex-bs-100');
                    ")

                    shinyjs::show("controls-panel-rg")
                } 
            }
        },
        error = function(e) {
            # runjs("window.location.href = '/#!/repgrid';")
            message(paste("error: ", e))
            showModal(modalDialog(
                title = i18n$t("Esta simulación se guardó con errores. Bórrela y vuelva a crearla."),
                footer = tagList(
                    modalButton("OK"),
                )
            ))
        })
        
        proxy <- dataTableProxy("user_table")
        proxy %>% selectRows(NULL)
        #shinyjs::hide("patientSimulations")
    }
    
    observeEvent(input$simulaciones_wimp_rows_selected, {
        selected_row <- input$simulaciones_wimp_rows_selected
        proxy <- dataTableProxy("simulaciones_rep")
        if (!is.null(selected_row)) {
            proxy %>% selectRows(NULL) # deselecciono la fila repgrid
            repgrid_fecha_seleccionada(NULL) # reseteo la fecha repgrid el boton cargar
            #shinyjs::enable("cargarSimulacion")
            #shinyjs::enable("borrarSimulacion")
            fechas <- wimpgrid_data_DB$fechas
            fecha <- fechas[selected_row]
            message(fecha)
            session$userData$fecha_wimpgrid <- fecha
            wimpgrid_fecha_seleccionada(fecha)
      
        }
    })

    # gestion de las filas seleccionadas en la tabla de simulaciones wimpgrid
    abrir_wimpgrid <- function(){
        tryCatch({
            if(!is.null(wimpgrid_fecha_seleccionada())){
                id_paciente <- user_data$selected_user_id
                ruta_destino <- tempfile(fileext = ".xlsx")
                id <- decodificar_BD_excel('wimpgrid_xlsx', ruta_destino, id_paciente, session$userData$fecha_wimpgrid)
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
                    runjs("setTimeout(function () {
                    window.location.href = '/#!/wimpgrid';
                    window.scrollTo(0,0);
                    }, 200);

                    ")

                    runjs("
                    $('#controls-panel-vis').removeClass('anim-fade-out');
                    $('#controls-panel-vis').addClass('anim-fade-in');

                    $('#controls-panel-lab').removeClass('anim-fade-out');
                    $('#controls-panel-lab').addClass('anim-fade-in');

                    $('.graphics-vis').removeClass('mw-100');
                    $('.graphics-vis').removeClass('flex-bs-100');

                    $('.graphics-lab').removeClass('mw-100');
                    $('.graphics-lab').removeClass('flex-bs-100');
                    ")
                
                    shinyjs::show("controls-panel-vis")
                    shinyjs::show("controls-panel-lab")
                }   
            }
        },
        error = function(e) {
            # runjs("window.location.href = '/#!/repgrid';")
            message(paste("error: ", e))
            showModal(modalDialog(
                title = i18n$t("Esta simulación se guardó con errores. Bórrela y vuélvela a crear."),
                footer = tagList(
                    modalButton("OK"),
                )
            ))
        })
        proxy <- dataTableProxy("user_table")
        proxy %>% selectRows(NULL)
        #shinyjs::hide("patientSimulations")
        
    }

    cerrar_rejilla <- function(id_paciente, fecha_repgrid, fecha_wimpgrid){
        con <- establishDBConnection()
        if(!is.null(fecha_repgrid) && !is.null(session$userData$id_repgrid)){
            query <- sprintf("SELECT distinct(id) from repgrid_xlsx where fecha_registro='%s' and fk_paciente=%d", fecha_repgrid, id_paciente) 
            id <- DBI::dbGetQuery(con, query)
            if(session$userData$id_repgrid == id){
                show("repgrid_home_warn")
                show("repgrid_warning")
                hide("rg-data-content")
                hide("rg-analysis-content")
            }  
        }

        if(!is.null(fecha_wimpgrid) && !is.null(session$userData$id_wimpgrid)){
            query <- sprintf("SELECT distinct(id) from wimpgrid_xlsx where fecha_registro='%s' and fk_paciente=%d", fecha_wimpgrid, id_paciente) 
            id <- DBI::dbGetQuery(con, query)$id
            if(session$userData$id_wimpgrid == id){
                show("id_warn")
                show("vis_warn")
                show("lab_warn")
                hide("wg-data-content")
                hide("wg-vis-content")
                hide("wg-lab-content")
            }
        }

        DBI::dbDisconnect(con)
    }

    borrarSimulacion <- function(){
        nombrepaciente <- nombrePaciente()
        showModal(modalDialog(
            title = i18n$t("Confirmar borrado"),
            sprintf(i18n$t("¿Está seguro de que quiere eliminar esta simulación de %s? Esto no se puede deshacer."), nombrepaciente),
            footer = tagList(
            modalButton(i18n$t("Cancelar")),
            actionButton("confirmarBorradoSimulacion", i18n$t("Confirmar"), status ="danger", icon = icon("trash-can"))
            )
        ))
    }

    observeEvent(input$confirmarBorradoSimulacion, {
        removeModal()  # Cierra la ventana modal de confirmación
        
        # Proceso de borrado de la simulación
        id_paciente <- user_data$selected_user_id
        fecha_rep <- repgrid_fecha_seleccionada()
        fecha_wimp <- wimpgrid_fecha_seleccionada()
        
        if (!is.null(fecha_rep) || !is.null(fecha_wimp)) {
            con <- establishDBConnection()
            if (!is.null(fecha_rep)) {
                cerrar_rejilla(id_paciente, fecha_rep, NULL)
                query <- sprintf("DELETE FROM repgrid_xlsx where fecha_registro = '%s' and fk_paciente = %d", fecha_rep, id_paciente)
                DBI::dbExecute(con, query)
                cargar_fechas()
            }
            if (!is.null(fecha_wimp)) {
                cerrar_rejilla(id_paciente, NULL, fecha_wimp)
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
            #shinyjs::disable("borrarSimulacion")           
        }
    })

    observeEvent(input$button_id_abrir, {
        abrir_repgrid()
    })

    observeEvent(input$button_id_abrir_w, {
        abrir_wimpgrid()
    })

    observeEvent(input$button_id_borrar, {
        borrarSimulacion()
    })

    observeEvent(input$button_id_borrar_w, {
        borrarSimulacion()
    })

    observeEvent(input$importarGridPaciente, {
        tryCatch({
            shinyjs::hide("patientSimulations")
            shinyjs::show("import-page")
            shinyjs::show("form-page")
            shinyjs::show("excel-page")
            session$userData$id_paciente <- user_data$selected_user_id
            proxy <- dataTableProxy("user_table")
            proxy %>% selectRows(NULL)
            session$userData$rol <- rol
            import_excel_server(input, output, session)
            form_server(input, output, session)
            
            runjs("
                setTimeout(function () {
                    window.location.href = '/#!/import';
                    window.scrollTo(0,0);
                }, 10);
            ")
        },
        error = function(e) {
            message("error ", e)
            session$reload()
        })
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
            shinyjs::hide("editForm")
            
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
                    actionButton("confirmarBorrado", i18n$t("Confirmar"), status ="danger", icon = icon("trash-can"))
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
        con <- establishDBConnection()
        if(!is.null(session$userData$id_wimpgrid)){
            show("id_warn")
            show("vis_warn")
            show("lab_warn")
            hide("wg-data-content")
            hide("wg-vis-content")
            hide("wg-lab-content")
        }
        if(!is.null(session$userData$id_repgrid)){
            show("repgrid_home_warn")
            show("repgrid_warning")
            hide("rg-data-content")
            hide("rg-analysis-content")
        }
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
        shinyjs::hide("patientIndicator")



    })
    
    observeEvent(input$nombre, {
        if(input$nombre != ""){
            shinyjs::enable("guardarAddPatient")
        }
        else{
            shinyjs::disable("guardarAddPatient")
        }
        
    })

    shinyjs::onclick("guardarAddPatient",  {
        con <- establishDBConnection()
        nombre <- input$nombre
        edad <- input$edad
        genero <- input$genero
        diagnostico <- input$diagnostico
        anotaciones <- input$anotaciones
        fecha_registro <- format(Sys.time(), format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Madrid")
        fk_psicologo <- session$userData$id_psicologo # de momento 
        message("nombre paciente...... ", nombre)
        message(class(nombre))
        message(typeof(nombre))
        # Validaciones
        if (is.null(nombre) || nombre == "") {
            message("El nombre del paciente está vacío")
            showNotification("El nombre del paciente no puede estar vacío", type = "error")
            return()
        }
        
        if (is.null(edad) || !is.numeric(edad) || edad < 0 || edad > 120) {
            message("La edad del paciente no es válida")
            showNotification("La edad del paciente debe ser un número entre 0 y 120", type = "error")
            return()
        }
        
        if (is.null(genero) || genero == "") {
            message("El género del paciente está vacío")
            showNotification("El género del paciente no puede estar vacío", type = "error")
            return()
        }
        
        if (is.null(diagnostico) || diagnostico == "") {
            message("El diagnóstico del paciente está vacío")
        }
        
        if (is.null(anotaciones)) {
            anotaciones <- "" # Si las anotaciones están vacías, asignar una cadena vacía
        }
        tryCatch({
            # Insertar los datos en la base de datos
            message("000")
            query <- sprintf("INSERT INTO paciente (nombre, edad, genero, diagnostico, anotaciones, fecha_registro) VALUES ('%s', %d, '%s', '%s', '%s', '%s')",
                            nombre, edad, genero, diagnostico, anotaciones, fecha_registro)
            DBI::dbExecute(con, query)
            message("111")
            query_id_paciente <- sprintf("SELECT id FROM paciente WHERE nombre = '%s' and anotaciones = '%s' and fecha_registro = '%s'", nombre, anotaciones, fecha_registro)
            id_paciente <- DBI::dbGetQuery(con, query_id_paciente)
            id_paciente <- as.integer(id_paciente)
            id_psicologo <- session$userData$id_psicologo # de momento

            query2 <- sprintf("INSERT INTO psicologo_paciente (fk_psicologo, fk_paciente) VALUES (%d, %d)", id_psicologo, id_paciente)
            DBI::dbExecute(con, query2)
            DBI::dbDisconnect(con)
            message("222")
            # Vaciar los campos del formulario
            updateTextInput(session, "nombre", value = "")
            updateNumericInput(session, "edad", value = 0)
            updateSelectInput(session, "genero", selected = "")
            updateTextInput(session, "diagnostico", value = "")
            updateTextInput(session, "anotaciones", value = "")
            message("333")
            renderizarTabla()
            shinyjs::hide("patientForm")
        }, error = function(e) {
            message("Error al insertar en la base de datos: ", e$message)
            showNotification("Error al guardar los datos del paciente", type = "error")
        })
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
