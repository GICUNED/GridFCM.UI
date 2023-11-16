plan_subscription_server <- function(input, output, session){
    rol <- session$userData$rol
    id_psicologo <- session$userData$id_psicologo

    # cuando creemos los roles, si el usuario no tiene rol de coordinador de org
    # le ocultamos la tabla
    if(!is.null(rol)){
        # if(rol != "usuario_administrador_org"){
        #     shinyjs::hide("panel-gestion-licencias")
        # }
    }
    
    # reactive variables
    subscription_data <- reactiveValues(subscriptions = NULL, selected_subscription_id = NULL)
    licencias_data <- reactiveValues(psicologos = NULL, selected_licencia_psicologo_id=NULL, selected_licencia_psicologo_email=NULL)
    # subscriptionID <- reactiveVal()

    shinyjs::hide("gestion-licencias")

    renderizarTabla <- function(){
        output$subscription_table <- renderDT({
            con <- establishDBConnection()
            query <- sprintf("SELECT id, fecha_inicio, fecha_fin, licencias_contratadas, licencias_disponibles FROM SUSCRIPCION
                                WHERE fk_psicologo=%d AND activa", id_psicologo) # de momento
            subscriptions <- DBI::dbGetQuery(con, query)
            DBI::dbDisconnect(con)
            
            # Convertir fechas a POSIXct y formatear
            fecha_inicio <- as.POSIXct(subscriptions$fecha_inicio, origin = "1970-01-01")
            subscriptions$fecha_inicio <- format(fecha_inicio, format = "%Y-%m-%d %H:%M:%S")
            fecha_fin <- as.POSIXct(subscriptions$fecha_fin, origin = "1970-01-01")
            subscriptions$fecha_fin <- format(fecha_fin, format = "%Y-%m-%d %H:%M:%S")

            subscription_data$subscriptions <- subscriptions # variable reactiva
            df <- data.frame(n=subscriptions$id, e=subscriptions$fecha_inicio, g=subscriptions$fecha_fin, f=subscriptions$licencias_contratadas, d=subscriptions$licencias_disponibles)
            DT::datatable(df, selection = 'single', rownames = FALSE,
                options = list(order = list(3, 'asc')),
                colnames = c(i18n$t("ID"), i18n$t("Fecha de Inicio"), i18n$t("Fecha de Vencimiento"), i18n$t("Licencias Contratadas"), i18n$t("Licencias Disponibles"))
            )
        })
        ## Not necessary in principle
        # if(!is.null(rol)){
        #     if(rol == "usuario_gratis"){
        #         con <- establishDBConnection()
        #         query <- sprintf("SELECT COUNT(DISTINCT p.id) as num FROM paciente as p, psicologo_paciente as pp 
        #                             WHERE pp.fk_paciente = p.id and pp.fk_psicologo = %d", id_psicologo) # de momento
        #         num <- DBI::dbGetQuery(con, query)
        #         DBI::dbDisconnect(con)
        #         if(num$num >= 2){
        #             shinyjs::disable("addPatient")
        #         }
        #         else{
        #             shinyjs::enable("addPatient")
        #         }
        #     }
        # }
    }




    if(!is.null(id_psicologo)){
        renderizarTabla()
    }



    # gestion de las filas seleccionadas en la tabla suscripciones
    observeEvent(input$subscription_table_rows_selected, {
        selected_row <- input$subscription_table_rows_selected
    
        if (!is.null(selected_row)) {
            shinyjs::enable("darLicencia")
            # #ocultar simulaciones por si se habían desplegado
            shinyjs::hide("licencias_table")
            # shinyjs::hide("simulaciones_wimp")
            shinyjs::hide("gestion-licencias")
            # shinyjs::hide("import-page")
            # shinyjs::hide("form-page")
            # shinyjs::hide("excel-page")

            # Obtén el ID del usuario de la fila seleccionada
            subscriptions <- subscription_data$subscriptions
            subscription_id <- subscriptions[selected_row, 1]
            
            subscription_data$selected_subscription_id <- subscription_id # reactiva
            # subscriptionID(subscription_id)

            if(rol != "usuario_demo"){
            #     shinyjs::enable("borrarPaciente")
            #     shinyjs::enable("simulacionesDisponibles")
            #     shinyjs::enable("editarPaciente")
            #     shinyjs::show("simulaciones_wimp")
                shinyjs::show("gestion-licencias")
                shinyjs::show("licencias_table")
            }

            cargar_licencias()
            # cargar_fechas()

            # session$userData$id_paciente <- selected_user_id   
            
        } else {
            shinyjs::disable("darLicencia")
            # shinyjs::hide("simulationIndicatorRG")
            # shinyjs::hide("simulationIndicatorWG")
            # shinyjs::hide("patientIndicator")

            message("")
        }
    })

    output$suscripcion_licencia_header <- renderText({
        paste(icon = icon("universal-access"), "Sucripción ", subscription_data$selected_subscription_id)
    })

    cargar_licencias <- function(){
        numero_aleatorio <- sample(1:1000, 1)
        con <- establishDBConnection()
        query <- sprintf("SELECT p.id,p.nombre, p.email, p.username FROM LICENCIA l INNER JOIN PSICOLOGO p on p.id=l.fk_psicologo WHERE fk_suscripcion=%d", subscription_data$selected_subscription_id)
        licenciasDB <- DBI::dbGetQuery(con, query)
        message(licenciasDB)
        DBI::dbDisconnect(con)
        if(!is.null(licenciasDB)){
            licencias_data$psicologos <- licenciasDB$id
            df <- data.frame(Nombre = licenciasDB$nombre, Email = licenciasDB$email, Usuario=licenciasDB$username)
            output$licencias_table <- renderDT({
                data_rep <- df %>%
                    mutate(
                        actionable = glue(
                            '<button id="custom_btn_abrir" onclick="Shiny.onInputChange(\'button_id_revocar_acceso\', {row_number()})">Revocar Acceso</button>',
                        )
                    )
                DT::datatable(
                    data_rep,
                    selection = "single",
                    rownames = FALSE,
                    escape = FALSE,
                    options = list(
                        order = list(0, 'asc'),
                        columnDefs = list(list(width = '125px', targets = ncol(data_rep) - 1 ))
                    ),
                    
                    colnames = c(i18n$t("Nombre"), i18n$t("Email"), i18n$t("Usuario"), "")
                )
            })
        }
    }

    observeEvent(input$licencias_table_rows_selected, {
        selected_row <- input$licencias_table_rows_selected
        
        if (!is.null(selected_row)) {
            # hacer consulta para obtener el txt de repgrid aqui con la fecha seleccionada
            licencia_psicologo_id_seleccionada = licencias_data$psicologos[selected_row]
            message(paste("licencia_psicolog_id seleccionada: ", licencia_psicologo_id_seleccionada))
            # session$userData$fecha_repgrid <- fecha
            licencias_data$selected_licencia_psicologo_id = licencia_psicologo_id_seleccionada
        }
    })


    revocarAcceso <- function(){
        showModal(modalDialog(
            title = i18n$t("Confirmar Acción"),
            sprintf(i18n$t("¿Está seguro de que quiere quitar de la suscripción %d la licencia al usuario %s. La licencia quedará disponible de nuevo y se podrá reasignar a otro usuario."), subscription_data$selected_subscription_id,licencias_data$selected_licencia_psicologo_id),
            easyClose = TRUE,
            footer = tagList(
                modalButton(i18n$t("Cancelar")),
                actionButton("confirmarRevocarAcceso", i18n$t("Confirmar"), class = "btn-danger")
            )
        ))
    }



    observeEvent(input$confirmarRevocarAcceso, {
        removeModal()  # Cierra la ventana modal de confirmación
        
        # Proceso de revocar acceso a la licencia al usuario dado
        id_licencia_psicologo <- licencias_data$selected_licencia_psicologo_id
        id_suscripcion <- subscription_data$selected_subscription_id
        message(id_suscripcion)
        if (!is.null(id_psicologo) && !is.null(id_suscripcion)) {
            # check si el psicologo administrador se está intentando quitar a si mismo la licencia (no es posible)
            if(id_psicologo == id_licencia_psicologo){
                showModal(modalDialog(
                    title = i18n$t("No es posible revocar el acceso."),
                    i18n$t("Usted debe tener siempre una licencia asignada bajo alguna suscripción. No es posible hacer esta acción."),
                    easyClose = TRUE,
                    footer = tagList(
                        modalButton(i18n$t("Cerrar"))
                    )
                ))
            }else{
                # procedemos a revocar acceso
                con <- establishDBConnection()
                
                # quitamos de licencias todos los posibles registros de la suscripcion dada que estén relacionados con el psicologo dado
                # query <- sprintf("DELETE FROM LICENCIA where fk_suscripcion = '%d' and fk_psicologo = %d", id_suscripcion, id_licencia_psicologo)
                # DBI::dbExecute(con, query)

                # recalculamos de nuevo las licencias disponibles para la suscripcion dada
                query <- sprintf("SELECT licencias_contratadas from SUSCRIPCION WHERE activa AND id = %d", id_suscripcion)
                datos <- DBI::dbGetQuery(con, query)
                licencias_contratadas <- 0
                if(length(datos$licencias_contratadas)>0){
                    licencias_contratadas <- datos$licencias_contratadas
                }

                query <- sprintf("SELECT COUNT(DISTINCT (fk_psicologo, fk_suscripcion)) as count from LICENCIA WHERE fk_suscripcion = %d", id_suscripcion)
                datos <- DBI::dbGetQuery(con, query)
                licencias_usadas <- 0
                if(length(datos$count)>0){
                    licencias_usadas <- datos$count
                }

                licencias_disponibles <- as.integer(licencias_contratadas - licencias_usadas)
                message(licencias_disponibles)

                query <- sprintf("UPDATE SUSCRIPCION set licencias_disponibles=%d where id = %d", licencias_disponibles, id_suscripcion)
                DBI::dbExecute(con, query)

                cargar_licencias()
                
               
                DBI::dbDisconnect(con)
            }
            # con <- establishDBConnection()
            # if (!is.null(fecha_rep)) {
            #     query <- sprintf("DELETE FROM repgrid_xlsx where fecha_registro = '%s' and fk_paciente = %d", fecha_rep, id_paciente)
            #     DBI::dbExecute(con, query)
            #     cargar_fechas()
            # }
            # if (!is.null(fecha_wimp)) {
            #     id_wx <- as.integer(DBI::dbGetQuery(con, sprintf("SELECT distinct(wp.fk_wimpgrid) from wimpgrid_params as wp, wimpgrid_xlsx as wx where wp.fk_wimpgrid = wx.id and wx.fk_paciente = %d and wx.fecha_registro = '%s'", 
            #                                         user_data$selected_user_id, fecha_wimp)))
            #     if (!is.na(id_wx)) {
            #         query_wp <- sprintf("DELETE FROM wimpgrid_params where fk_wimpgrid = %d", id_wx)
            #         DBI::dbExecute(con, query_wp)
            #     }
            #     query <- sprintf("DELETE FROM wimpgrid_xlsx where fecha_registro = '%s' and fk_paciente = %d", fecha_wimp, id_paciente)
            #     DBI::dbExecute(con, query)
            #     cargar_fechas_wimpgrid()
            # }
            # DBI::dbDisconnect(con)
            #shinyjs::disable("borrarSimulacion")           
        }
    })

    observeEvent(input$button_id_revocar_acceso, {
        revocarAcceso()
    })

    


}