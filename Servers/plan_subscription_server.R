plan_subscription_server <- function(input, output, session){
    rol <- session$userData$rol
    id_psicologo <- session$userData$id_psicologo

    token <- reactiveVal(NULL)

    domain <- Sys.getenv("DOMAIN")
    keycloak_client_id <- "gridfcm"
    keycloak_client_secret <- Sys.getenv("KEYCLOAK_CLIENT_SECRET")
    rol_ilimitado <- '{"id": "c70eddee-5dd0-49ed-8a02-20eeff11d751","name": "usuario_ilimitado"}'
    rol_ilimitado <- jsonlite::fromJSON(rol_ilimitado)
    

    # funcion que devuelve el token para acceder a la api de admin
    obtener_token_admin_api <- function(params){
        token_url <- sprintf("https://%s/keycloak/realms/Gridfcm/protocol/openid-connect/token", domain)
        params <- list(
            client_id = keycloak_client_id,
            client_secret = keycloak_client_secret,
            grant_type = "client_credentials"
        )
        resp <- httr::POST(url = token_url, add_headers("Content-Type" = "application/x-www-form-urlencoded"), body = params, encode="form")
        respuesta <- (httr::content(resp, "text"))
        token_data <- jsonlite::fromJSON(respuesta)
        #token
        admin_token <- token_data$access_token
        return(admin_token)
    }

    # funcion que devuelve el user_id pasandole como param el email
    obtener_user_id <- function(email, admin_token){
        user_url <- sprintf("https://%s/keycloak/admin/realms/Gridfcm/users?email=%s&exact=%s", domain, email, "true")

        resp <- httr::GET(url = user_url, add_headers("Authorization" = paste("Bearer", admin_token, sep = " ")))
        user_data <- (httr::content(resp, "text"))
        if(!is.null(user_data) && user_data != ""){
            user_data <- jsonlite::fromJSON(user_data)
            if(is.null(user_data$error)){
                message("no error")
                user_id <- user_data$id
            }else{
                message("error")
                user_id <- NULL
            }
        }else{
            user_id <- NULL
        }
        return(user_id)
    }
    


    # cuando creemos los roles, si el usuario no tiene rol de coordinador de org
    # le ocultamos la tabla
    if(!is.null(rol)){
        if(rol != "usuario_coordinador_organizacion" && rol != "usuario_administrador"){
            shinyjs::hide("panel-gestion-licencias")
        }else{
            shinyjs::show("panel-gestion-licencias")
        }
    }
    # else{
    #     shinyjs::hide("panel-gestion-licencias")
    # }
    
    # reactive variables
    subscription_data <- reactiveValues(subscriptions = NULL, selected_subscription_id = NULL)
    licencias_data <- reactiveValues(psicologos = NULL, selected_licencia_psicologo_id=NULL, selected_licencia_psicologo_email=NULL)
    # subscriptionID <- reactiveVal()

    shinyjs::hide("gestion-licencias")

    renderizarTabla <- function(){
        output$subscription_table <- renderDT({
            con <- establishDBConnection()
            query <- sprintf("SELECT id, fecha_inicio, fecha_fin, licencias_contratadas, licencias_disponibles FROM SUSCRIPCION
                                WHERE fk_psicologo=%d AND activa", id_psicologo)
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
                options = list(order = list(1, 'desc')),
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

    # boton añadir participante
    shinyjs::onclick("darLicencia",  {
        shinyjs::show("participantForm")
    })
    # observeEvent(input$darLicencia, {
    #     shinyjs::show("participantForm")
        
    # })

    runjs("
        $('#darLicencia').on('click', function (){
            $('#participantForm').addClass('anim-fade-in');
            $('#participantForm').removeClass('anim-fade-out');}
        );
    ")


    runjs("
    $('#new-participant-cancel').on('click', function (){
        $('#participantForm').removeClass('anim-fade-in');
        $('#participantForm').addClass('anim-fade-out'); }
    );
    ")

    shinyjs::onevent("click", "new-participant-cancel", {
        
        delay(100, shinyjs::hide("participantForm"))
        
    }, add = TRUE)



    if(!is.null(id_psicologo)){
        renderizarTabla()
    }



    # gestion de las filas seleccionadas en la tabla suscripciones
    observeEvent(input$subscription_table_rows_selected, {
        selected_row <- input$subscription_table_rows_selected
        message(input$subscription_table_rows_selected)
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
            }else{
                shinyjs::hide("gestion-licencias")
                shinyjs::hide("licencias_table")
            }

            cargar_licencias()
            # cargar_fechas()

            # session$userData$id_paciente <- selected_user_id   
            
        } else {
            shinyjs::disable("darLicencia")
            shinyjs::hide("licencias_table")
            # shinyjs::hide("simulaciones_wimp")
            shinyjs::hide("gestion-licencias")
            # shinyjs::hide("simulationIndicatorRG")
            # shinyjs::hide("simulationIndicatorWG")
            # shinyjs::hide("patientIndicator")

        }
    })

    output$suscripcion_licencia_header <- renderText({
        paste(icon = icon("universal-access"), "Sucripción ", subscription_data$selected_subscription_id)
    })

    # cargar_licencias <- function(){
    #     output$licencias_table <- renderDT({
    #         numero_aleatorio <- sample(1:1000, 1)
    #         con <- establishDBConnection()
    #         query <- sprintf("SELECT p.id,p.nombre, p.email, p.username FROM LICENCIA l INNER JOIN PSICOLOGO p on p.id=l.fk_psicologo WHERE fk_suscripcion=%d", subscription_data$selected_subscription_id)
    #         licenciasDB <- DBI::dbGetQuery(con, query)
    #         DBI::dbDisconnect(con)
    #         if(!is.null(licenciasDB)){
    #             licencias_data$psicologos <- licenciasDB$id
    #             df <- data.frame(Nombre = licenciasDB$nombre, Email = licenciasDB$email, Usuario=licenciasDB$username)
    #             data_rep <- df %>%
    #                 mutate(
    #                     actionable = glue(
    #                         '<button id="revocar_acceso_modal" onclick="Shiny.onInputChange(\'button_id_revocar_acceso\', {row_number()+numero_aleatorio})">Revocar Acceso</button>',
    #                     )
    #                 )
    #             DT::datatable(
    #                 data_rep,
    #                 selection = "single",
    #                 rownames = FALSE,
    #                 escape = FALSE,
    #                 options = list(
    #                     order = list(0, 'asc'),
    #                     columnDefs = list(list(width = '125px', targets = ncol(data_rep) - 1 ))
    #                 ),
                    
    #                 colnames = c(i18n$t("Nombre"), i18n$t("Email"), i18n$t("Usuario"), "")
    #             )
    #         }
    #     })
    # }

    cargar_licencias <- function(){
        output$licencias_table <- renderDT({
            numero_aleatorio <- sample(1:1000, 1)
            con <- establishDBConnection()
            query <- sprintf("SELECT p.id,p.nombre, p.email, p.username FROM LICENCIA l INNER JOIN PSICOLOGO p on p.id=l.fk_psicologo WHERE fk_suscripcion=%d", subscription_data$selected_subscription_id)
            licenciasDB <- DBI::dbGetQuery(con, query)
            DBI::dbDisconnect(con)
            if(!is.null(licenciasDB)){
                licencias_data$psicologos <- licenciasDB$id
                df <- data.frame(Nombre = licenciasDB$nombre, Email = licenciasDB$email, Usuario=licenciasDB$username)

                custom_button_revocar_accesso <- function(tbl){
                    function(i){
                        sprintf(
                        '<button id="revocar_acceso_modal_%s_%d" type="button" onclick="%s">Revocar Accesso</button>', 
                        tbl, i, "Shiny.setInputValue('button_id_revocar_acceso', this.id, {priority: 'event'});")
                    }
                }

                data_df <- cbind(df, 
                            button = sapply(1:nrow(df), custom_button_revocar_accesso("tbl1")), 
                            stringsAsFactors = FALSE)


                # data_rep <- df %>%
                #     mutate(
                #         actionable = glue(
                #             '<button id="revocar_acceso_modal" onclick="Shiny.onInputChange(\'button_id_revocar_acceso\', {row_number()+numero_aleatorio})">Revocar Acceso</button>',
                #         )
                #     )
                DT::datatable(
                    data_df,
                    selection = "single",
                    rownames = FALSE,
                    escape = FALSE,
                    options = list(
                        order = list(0, 'asc'),
                        columnDefs = list(list(width = '125px', targets = ncol(data_df) - 1 ))
                    ),
                    
                    colnames = c(i18n$t("Nombre"), i18n$t("Email"), i18n$t("Usuario"), "")
                )
            }
        })
    }

    observeEvent(input$licencias_table_rows_selected, {
        selected_row <- input$licencias_table_rows_selected
        
        if (!is.null(selected_row)) {
            # hacer consulta para obtener el txt de repgrid aqui con la fecha seleccionada
            licencia_psicologo_id_seleccionada = licencias_data$psicologos[selected_row]
            # session$userData$fecha_repgrid <- fecha
            licencias_data$selected_licencia_psicologo_id = licencia_psicologo_id_seleccionada
        }
    })


    # revocarAcceso <- function(){
    #     showModal(modalDialog(
    #         title = i18n$t("Confirmar Acción"),
    #         sprintf(i18n$t("¿Está seguro de que quiere quitar de la suscripción %d la licencia al usuario %s. La licencia quedará disponible de nuevo y se podrá reasignar a otro usuario."), subscription_data$selected_subscription_id,licencias_data$selected_licencia_psicologo_id),
    #         easyClose = TRUE,
    #         footer = tagList(
    #             modalButton(i18n$t("Cancelar")),
    #             actionButton("confirmarRevocarAcceso", i18n$t("Confirmar"), class = "btn-danger")
    #         )
    #     ))
    # }


    # shinyjs::onclick("confirmarRevocarAcceso",  {
    #     shinyjs::show("participantForm")
    # })

    observeEvent(input$confirmarRevocarAcceso, {
        removeModal()  # Cierra la ventana modal de confirmación
        
        # Proceso de revocar acceso a la licencia al usuario dado
        ## esto es el id del psicologo que se ha seleccionado en la tabla licencias
        id_licencia_psicologo <- licencias_data$selected_licencia_psicologo_id
        id_suscripcion <- subscription_data$selected_subscription_id


        
        if (!is.null(id_psicologo) && !is.null(id_suscripcion) && !is.null(id_licencia_psicologo)) {
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
                
                # quitamos de licencias todos los posibles registros de la suscripcion dada, que estén relacionados con el psicologo dado
                query <- sprintf("DELETE FROM LICENCIA where fk_suscripcion = '%d' and fk_psicologo = %d", id_suscripcion, id_licencia_psicologo)
                DBI::dbExecute(con, query)

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

                query <- sprintf("UPDATE SUSCRIPCION set licencias_disponibles=%d where id = %d", licencias_disponibles, id_suscripcion)
                DBI::dbExecute(con, query)

                ## ponemos el rol gratis a la tabla psicologo (quiza no se use ese campo para nada)
                query <- sprintf("UPDATE PSICOLOGO set rol='%s' where id = %d", "usuario_gratis", id_licencia_psicologo)
                DBI::dbExecute(con, query)

                renderizarTabla()

                selected_row <- input$subscription_table_rows_selected
                # select the subscription again
                proxy <- dataTableProxy("subscription_table")
                if (!is.null(selected_row)) {
                    proxy %>% selectRows(selected_row)
                }

                cargar_licencias()
                
                # ahora borramos en keycloak el usuario ilimitado
                ## primero, sacamos el token para acceder a la api de admin
                admin_token <- obtener_token_admin_api()

                ## segundo, sacamos el email del usuario, para ser usado para sacar el user_id
                query <- sprintf("SELECT email from PSICOLOGO WHERE id = %d", id_licencia_psicologo)
                datos <- DBI::dbGetQuery(con, query)
                if(length(datos$email)>0){
                    email_licencia_psicologo <- datos$email
                }else{
                    email_licencia_psicologo <- NULL
                }

                DBI::dbDisconnect(con)
                if(!is.null(email_licencia_psicologo) && email_licencia_psicologo!=""){
                    ## ahora necesitamos el user id del usuario al que quitar el rol ilimitado
                    user_id <- obtener_user_id(email_licencia_psicologo, admin_token)
                }else{
                    user_id <- NULL
                }

                if(!is.null(user_id) && user_id!=""){
                    rol_url <- sprintf("https://%s/keycloak/admin/realms/Gridfcm/users/%s/role-mappings/realm", domain, user_id)

                    request_body <- data.frame(
                        id = c(rol_ilimitado$id),name = c(rol_ilimitado$name)
                    )
                    request_body_json <- toJSON(request_body, auto_unbox = TRUE)
                    resp <- httr::DELETE(url = rol_url, add_headers("Content-Type" = "application/json","Authorization" = paste("Bearer", admin_token, sep = " ")), body = request_body_json, encode="json")
                    roles <- (httr::content(resp, "text"))
                    if(!is.null(roles) && roles != ""){
                        roles <- jsonlite::fromJSON(roles)
                        if(is.null(roles$error)){
                            message("no error")
                        }else{
                            message("error")
                        }
                    }
                }

                
            }
      
        }
    })

    # shinyjs::onclick("button_id_revocar_acceso",  {
    #     message("entro a mostrar modal")
    #     shinyshowModal(modalDialog(
    #         title = i18n$t("Confirmar Acción"),
    #         sprintf(i18n$t("¿Está seguro de que quiere quitar de la suscripción %d la licencia al usuario %s. La licencia quedará disponible de nuevo y se podrá reasignar a otro usuario."), subscription_data$selected_subscription_id,licencias_data$selected_licencia_psicologo_id),
    #         fade = TRUE,
    #         footer = tagList(
    #             modalButton(i18n$t("Cancelar")),
    #             actionButton("confirmarRevocarAcceso", i18n$t("Confirmar"), class = "btn-danger")
    #         )
    #     ))
    # })
    observeEvent(input[["button_id_revocar_acceso"]], {
        message("entro a mostrar modal")
        showModal(modalDialog(
            title = i18n$t("Confirmar Acción"),
            sprintf(i18n$t("¿Está seguro de que quiere quitar de la suscripción %d la licencia al usuario %s. La licencia quedará disponible de nuevo y se podrá reasignar a otro usuario."), subscription_data$selected_subscription_id,licencias_data$selected_licencia_psicologo_id),
            footer = tagList(
                modalButton(i18n$t("Cancelar")),
                actionButton("confirmarRevocarAcceso", i18n$t("Confirmar"), class = "btn-danger")
            )
        ))
    })


    observeEvent(input$email_participant, {
        if(input$email_participant != ""){
            shinyjs::enable("guardarAddParticipant")
        }
        else{
            shinyjs::disable("guardarAddParticipant")
        }
        
    })

    shinyjs::onclick("guardarAddParticipant",  {
        isValidEmail <- function(x) {
            grepl("\\<[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\>", as.character(x), ignore.case=TRUE)
        }
        if(isValidEmail(input$email_participant)){
            # correo valido
            # aqui checkeamos si el email existe en la bd
            con <- establishDBConnection()
            id <- as.integer(DBI::dbGetQuery(con, sprintf("SELECT id FROM psicologo WHERE email='%s'", input$email_participant)))
            if(!is.na(id)){
                # comprobar si el usuario ya tiene licencia activa
                ## para esto, primero vemos si tiene alguna licencia
                query <- sprintf("select l.id from licencia l inner join psicologo p on l.fk_psicologo = p.id where p.email='%s'", input$email_participant)
                datos <- DBI::dbGetQuery(con, query)
                if(length(datos$id) == 0){
                    # no tiene licencia, comprobar si tiene una suscripcion individual
                    query <- sprintf("select s.id from suscripcion s inner join psicologo p on s.fk_psicologo = p.id where p.email='%s'", input$email_participant)
                    datos <- DBI::dbGetQuery(con, query)
                    if(length(datos$id) == 0){
                        # no tiene suscripcion
                        output$email_text <- renderText({
                            "Un usuario ya está registrado con este email. Confirma la adjudicación de la licencia a dicho usuario."
                        })
                        shinyjs::disable("email_participant")
                        shinyjs::hide("guardarAddParticipant")
                        shinyjs::show("segundo_paso")
                        shinyjs::enable("confirmAddParticipant")
                    }else{
                        # tiene suscripcion
                        output$email_text <- renderText({
                            "Este usuario ya tiene una suscripción."
                        })
                        shinyjs::enable("email_participant")
                        shinyjs::show("guardarAddParticipant")
                        shinyjs::hide("segundo_paso")
                        shinyjs::disable("confirmAddParticipant")
                    }
                }else{
                    # tiene licencia
                    output$email_text <- renderText({
                        "Este usuario ya tiene una licencia activa."
                    })
                    shinyjs::enable("email_participant")
                    shinyjs::show("guardarAddParticipant")
                    shinyjs::hide("segundo_paso")
                    shinyjs::disable("confirmAddParticipant")
                }
                
            }else{
                output$email_text <- renderText({
                    "El email introducido no está asociado a ningún usuario registrado. Por favor, registre al usuario en la web antes de asignarle la licencia."
                })
                shinyjs::enable("email_participant")
                shinyjs::show("guardarAddParticipant")
                shinyjs::hide("segundo_paso")
                shinyjs::disable("confirmAddParticipant")
            }
            DBI::dbDisconnect(con)
            
        }else{
            output$email_text <- renderText({
                "El email introducido no es valido. Introduzca un email correcto, i.e: user@example.com"
            })
            shinyjs::enable("email_participant")
            shinyjs::show("guardarAddParticipant")
            shinyjs::hide("segundo_paso")
            shinyjs::disable("confirmAddParticipant")
        }
    })

    # observeEvent(get_cookie("token_cookie"), {
    #     message("obtengo la cookie:")
    #     token_res <- get_cookie("token_cookie")
    #     if(token_res != "null"){
    #         message(token_res)
    #         token(token_res)
    #     }

    # })


    shinyjs::onclick("confirmAddParticipant",  {
        id_suscripcion <- subscription_data$selected_subscription_id
        # aqui tenemos que añadir a la tabla licencias al usuario en cuestion
        con <- establishDBConnection()
        # obtenemos el id del psicologo mediante el email proporcionado
        query <- sprintf("select id from psicologo where email='%s'", input$email_participant)
        datos <- DBI::dbGetQuery(con, query)
        if(length(datos$id)==0){
            # problema, porque ha clickado en añadir sin que esté registrado, no deberia pasar 
            message("problema, porque ha clickado en añadir sin que esté registrado, no deberia pasar ")
        }else{
            id_psicologo_por_email <- datos$id[1]
            query <- sprintf("INSERT INTO public.licencia (fk_psicologo, fk_suscripcion) VALUES(%d, %d);", id_psicologo_por_email, id_suscripcion)
            DBI::dbExecute(con, query)

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

            query <- sprintf("UPDATE SUSCRIPCION set licencias_disponibles=%d where id = %d", licencias_disponibles, id_suscripcion)
            DBI::dbExecute(con, query)

            # cerramos el formulario
            delay(100, shinyjs::hide("participantForm"))
            # Vaciar los campos del formulario
            updateTextInput(session, "email_participant", value = "")
            output$email_text <- renderText({
                ""
            })
            shinyjs::enable("email_participant")
            shinyjs::show("guardarAddParticipant")
            shinyjs::hide("segundo_paso")
            shinyjs::disable("confirmAddParticipant")

            selected_row_add <- input$subscription_table_rows_selected
            renderizarTabla()
            # select the subscription again
            proxy_add <- dataTableProxy("subscription_table")
            if (!is.null(selected_row_add)) {
                proxy_add %>% selectRows(selected_row_add)
            }

            cargar_licencias()


            # añadimos el rol de usuario ilimitado
            ## primero añadimos el rol ilimitado a la tabla psicologo (quiza no se use ese campo para nada)
            query <- sprintf("UPDATE PSICOLOGO set rol='%s' where id = %d", "usuario_ilimitado", id_psicologo_por_email)
            DBI::dbExecute(con, query)

            DBI::dbDisconnect(con)

            ## ahora sacamos el token para acceder a la api de admin
            admin_token <- obtener_token_admin_api()

            ## ahora necesitamos el user id del usuario al que añadir el rol ilimitado
            user_id <- obtener_user_id(input$email_participant, admin_token)
            
            ## ahora añadimos el rol ilimitado a keycloak
            if(!is.null(user_id)){
                rol_url <- sprintf("https://%s/keycloak/admin/realms/Gridfcm/users/%s/role-mappings/realm", domain, user_id)
                # rol_url <- sprintf("https://%s/keycloak/admin/realms/Gridfcm/users/%s/role-mappings", domain, user_id)
                # rol_resp <- httr::GET(url = rol_url, add_headers("Content-Type" = "application/json","Authorization" = paste("Bearer", token_data$access_token, sep = " ")))
                # rol_resp <- (httr::content(rol_resp, "text"))
                # message(rol_resp)
                # rol_resp <- jsonlite::fromJSON(rol_resp)

                request_body <- data.frame(
                    id = c(rol_ilimitado$id),name = c(rol_ilimitado$name)
                )
                request_body_json <- toJSON(request_body, auto_unbox = TRUE)
                resp <- httr::POST(url = rol_url, add_headers("Content-Type" = "application/json","Authorization" = paste("Bearer", admin_token, sep = " ")), body = request_body_json, encode="json")
                roles <- (httr::content(resp, "text"))
                if(!is.null(roles) && roles != ""){
                    roles <- jsonlite::fromJSON(roles)
                    if(is.null(roles$error)){
                        message("no error")
                    }else{
                        message("error")
                    }
                }
            }


        }

        
        

    })

    shinyjs::onevent("click", "new-participant-cancel", {
        delay(100, shinyjs::hide("participantForm"))
        # Vaciar los campos del formulario
        updateTextInput(session, "email_participant", value = "")

        output$email_text <- renderText({
            ""
        })
        shinyjs::enable("email_participant")
        shinyjs::show("guardarAddParticipant")
        shinyjs::hide("segundo_paso")
        shinyjs::disable("confirmAddParticipant")

    }, add = TRUE)


}