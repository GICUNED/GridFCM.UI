success_payment_server <- function(input, output, session, new_rol_from_payments){
    rol <- session$userData$rol
    id_psicologo <- session$userData$id_psicologo

    # copiado de plans_subscription_server
    domain <- Sys.getenv("DOMAIN")
    keycloak_client_id <- "gridfcm"
    keycloak_client_secret <- Sys.getenv("KEYCLOAK_CLIENT_SECRET")
    rol_ilimitado <- '{"id": "c70eddee-5dd0-49ed-8a02-20eeff11d751","name": "usuario_ilimitado"}'
    rol_ilimitado <- jsonlite::fromJSON(rol_ilimitado)

    rol_coordinador <- '{"id": "fcaf869c-dce6-493b-90e9-33a47f027a6c","name": "usuario_coordinador_organizacion"}'
    rol_coordinador <- jsonlite::fromJSON(rol_coordinador)
    

    # (copiada de plan_subscription_server) funcion que devuelve el token para acceder a la api de admin
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

    # (copiada de plan_subscription_server) funcion que devuelve el user_id pasandole como param el email
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



    # aqui se debe comprobar que el pago se efectuo correctamente
    ## con el checkout session id, usamos la api de stripe para ver si el pago esta hecho
    # checkout_session_id <- paste(get_query_param(field="session_id", session =session), sep = "", collapse=", ")
    checkout_session_id <- reactive({
        paste(get_query_param(field="session_id", session =session), sep = "", collapse=", ")
    })

    observe({
        message(checkout_session_id())

        if(!is.null(checkout_session_id()) && checkout_session_id()!=""){
            message("estoy en payments")
            checkout_url <- sprintf("https://api.stripe.com/v1/checkout/sessions/%s", checkout_session_id())
            
            stripe_sk = Sys.getenv("STRIPE_SK")
            resp <- httr::GET(url = checkout_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
            checkout_session <- (httr::content(resp, "text"))
            checkout_session <- jsonlite::fromJSON(checkout_session)
            
            if(!is.null(checkout_session$payment_status) && !is.null(checkout_session$invoice)){
                message(checkout_session$payment_status)

                if(checkout_session$payment_status=="paid"){
                    pago_correcto <- TRUE
                }else{
                    pago_correcto <- FALSE
                }

                fecha_pago <- as.POSIXct(checkout_session$created, format="%H:%M:%S")

                if(pago_correcto){
                    ## primero de todo obtenemos el invoice y llamamos a la api de stripe para obtener informacion del invoice
                    invoice_url = sprintf("https://api.stripe.com/v1/invoices/%s", checkout_session$invoice)
                    resp <- httr::GET(url = invoice_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
                    invoice <- (httr::content(resp, "text"))
                    invoice <- jsonlite::fromJSON(invoice)

                    if(!is.null(invoice$subscription) && invoice$subscription != ""){
                        ## obtenemos la suscripcion desde el invoice, y llamamos a la api de stripe para obtener informacion de la suscripcion
                        subscription_id <- invoice$subscription
                        subscription_url = sprintf("https://api.stripe.com/v1/subscriptions/%s", subscription_id)
                        resp <- httr::GET(url = subscription_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
                        subscription_data <- (httr::content(resp, "text"))
                        subscription_data <- jsonlite::fromJSON(subscription_data)

                        ## ahora obtenemos la cantidad, status, periodo comienzo y finalizacion, producto comprado (individual u organizacional, se puede saber si la qty es >1 o =1)
                        fecha_inicio <- as.POSIXct(subscription_data$current_period_start, format="%H:%M:%S")
                        fecha_fin <- as.POSIXct(subscription_data$current_period_end, format="%H:%M:%S")
                        cantidad <- subscription_data$quantity
                        status <- subscription_data$status

                        if(cantidad>1){
                            organizacion <- "true"
                        }else{
                            organizacion <- "false"
                        }

                        if(status=="active"){
                            activa <- "true"
                        }else{
                            activa <- "false"
                        }


                        
                        ## checkear si ya tenemos metida la suscripcion en la base de datos, usando el subscription_id
                        con <- establishDBConnection()

                        query <- sprintf("SELECT id, activa from SUSCRIPCION WHERE id_stripe_suscripcion = '%s'", subscription_id)
                        datos <- DBI::dbGetQuery(con, query)

                        if(length(datos$id)==0){
                            ## no está metida, asi que la metemos, junto a licencia si se da el caso. tambien damos permisos ilimitado/coordinador_organizacion al usuario
                            message("no esta metida")
                            ### metemos a la tabla suscripcion un registro con los datos la suscripcion comprada
                            query <- sprintf("INSERT INTO suscripcion
                            (fecha_inicio, fecha_fin, licencias_contratadas, licencias_disponibles, organizacion, activa, id_stripe_suscripcion, fk_psicologo)
                            VALUES('%s', '%s', %d, %d, %s, %s, '%s', %d);", fecha_inicio, fecha_fin, cantidad, cantidad-1, organizacion, activa, subscription_id, id_psicologo)
                            DBI::dbExecute(con, query)

                            query <- sprintf("SELECT id from SUSCRIPCION WHERE id_stripe_suscripcion = '%s'", subscription_id)
                            datos <- DBI::dbGetQuery(con, query)

                            # id de la suscripcion en nuestra tabla SUSCRIPCION
                            id_suscripcion_serial <- datos$id

                            # para hacer cambios en keycloak, necesitamos el user_id (copiado de plans_subcription_server)
                            ## primero, sacamos el token para acceder a la api de admin
                            admin_token <- obtener_token_admin_api()
                            ## segundo, sacamos el email del usuario, para ser usado para sacar el user_id
                            query <- sprintf("SELECT email from PSICOLOGO WHERE id = %d", id_psicologo)
                            datos <- DBI::dbGetQuery(con, query)
                            if(length(datos$email)>0){
                                email_psicologo <- datos$email
                            }else{
                                email_psicologo <- NULL
                            }
                            if(!is.null(email_psicologo) && email_psicologo!=""){
                                ## ahora necesitamos el user id del usuario al que quitar el rol ilimitado
                                user_id <- obtener_user_id(email_psicologo, admin_token)
                            }else{
                                user_id <- NULL
                            }


                            if(organizacion){
                                # metemos en licencia un registro con el id del usuario en cuestion y de la suscripcion
                                query <- sprintf("INSERT INTO licencia (fk_psicologo, fk_suscripcion) VALUES(%d, %d);", id_psicologo, id_suscripcion_serial)
                                DBI::dbExecute(con, query)

                                # ponemos rol coordinador al usuario en PSICOLOGO
                                query <- sprintf("UPDATE PSICOLOGO set rol='%s' where id = %d", "usuario_coordinador_organizacion", id_psicologo)
                                DBI::dbExecute(con, query)
                                # ponemos rol coordinador al usuario en keycloak
                                if(!is.null(user_id) && user_id!=""){
                                    rol_url <- sprintf("https://%s/keycloak/admin/realms/Gridfcm/users/%s/role-mappings/realm", domain, user_id)
                                    request_body <- data.frame(
                                        id = c(rol_coordinador$id),name = c(rol_coordinador$name)
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

                                # needed to reload session so that new rol is captured
                                session$reload()

                                

                            }else{
                                # no hace falta meter mas a SUSCRIPCION, habrá solamente un registro en SUSCRIPCION para los usuarios que obtengan el plan individual
                                # ponemos rol ilimitado al usuario en PSICOLOGO
                                query <- sprintf("UPDATE PSICOLOGO set rol='%s' where id = %d", "usuario_ilimitado", id_psicologo)
                                DBI::dbExecute(con, query)
                                # ponemos rol ilimitado al usuario en keycloak
                                if(!is.null(user_id) && user_id!=""){
                                    rol_url <- sprintf("https://%s/keycloak/admin/realms/Gridfcm/users/%s/role-mappings/realm", domain, user_id)
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
                                # needed to reload session so that new rol is captured
                                session$reload()


                            }

                            # output$confirmacionPago <- renderText({
                            #     sprintf("Suscripción activada. Pago realizado correctamente con fecha: %s", fecha_pago )
                            # })
                            # delay(100, shinyjs::show("redirectLicencias"))

                            output$confirmacionPago <- renderText({
                                sprintf("Refrescando página ...")
                            })


                        }else{
                            # está metida ya
                            message("ya metida")
                            if(datos$activa){
                                # avisamos al usuario de que el pago se realizó correctamente tal dia y que su licencia ya está activa
                                output$confirmacionPago <- renderUI({
                                     HTML(sprintf("<strong>Suscripción activa.</strong> Pago realizado correctamente con fecha: %s", fecha_pago ))
                                })
                                # if(rol == "usuario_coordinador_organizacion"){
                                #     output$redirection <- renderUI({
                                #         fluidRow( class = "flex-container-titles",
                                #             div(id="redirectLicencias", class = "nav-item payments-page hidden-div", menuItem(i18n$t("Ir a Gestión de Suscripción"), href = route_link("plan"), newTab = FALSE))
                                #         )
                                #     })
                                # }else if (rol == "usuario_ilimitado") {
                                #    output$redirection <- renderUI({
                                #         fluidRow( class = "flex-container-titles",
                                #             div(id="redirectLicencias", class = "nav-item payments-page hidden-div", menuItem(i18n$t("Ir a Panel de Usuario"), href = route_link("user"), newTab = FALSE))
                                #         )
                                #     })
                                # }
                                
                                # delay(100, shinyjs::show("redirectLicencias"))
                                
                            }else{
                                if(status=="active"){
                                    # cambiamos el campo active a true
                                    message("active")
                                    query <- sprintf("UPDATE SUSCRIPCION set activa=%s WHERE id_stripe_suscripcion = '%s'", "true", subscription_id)
                                    DBI::dbExecute(con, query)

                                    output$confirmacionPago <- renderUI({
                                        HTML(sprintf("<strong>Suscripción activa.</strong> Pago realizado correctamente con fecha: %s", fecha_pago ))
                                    })
                                    # delay(100, shinyjs::show("redirectLicencias"))

                                }else{
                                    # avisamos al usuario de que el pago se realizó correctamente tal dia y que su licencia ya no está activa
                                    message("not active")
                                    output$confirmacionPago <- renderUI({
                                        HTML(sprintf("<strong>Suscripción no activa.</strong> Pago realizado correctamente con fecha: %s", fecha_pago ))
                                    })
                                    # delay(100, shinyjs::show("redirectLicencias"))

                                }
                                

                            }
                            if(rol == "usuario_coordinador_organizacion" || rol == "usuario_administrador"){
                                output$redirection <- renderUI({
                                    fluidRow( class = "flex-container-titles",
                                        div(id="redirectLicencias", class = "nav-item payments-page hidden-div", menuItem(i18n$t("Ir a Gestión de Suscripción"), href = route_link("plan"), newTab = FALSE))
                                    )
                                })
                            }else if (rol == "usuario_ilimitado") {
                                output$redirection <- renderUI({
                                    fluidRow( class = "flex-container-titles",
                                        div(id="redirectLicencias", class = "nav-item payments-page hidden-div", menuItem(i18n$t("Ir a Panel de Usuario"), href = route_link("user"), newTab = FALSE))
                                    )
                                })
                            }
                            
                            delay(100, shinyjs::show("redirectLicencias"))

                        }

                        


                        DBI::dbDisconnect(con)
                    }
                    
                    # output$confirmacionPago <- renderText({
                    #     sprintf("Pago Realizado correctamente con fecha: %s", fecha_pago )

                    # })
                    # delay(100, shinyjs::show("redirectLicencias"))

                    
                }else{
                    output$confirmacionPago <- renderUI({
                        HTML(sprintf("<strong>Pago no recibido.</strong>  Motivo: %s", checkout_session$payment_status))

                    })
                    delay(100, shinyjs::show("redirectLicencias"))

                }

            }else{
                output$confirmacionPago <- renderText({
                    "Pago no Realizado. Redirigir a la pagina de planes"
                })
                delay(100, shinyjs::show("redirectLicencias"))

            }
        }else{
            message("estoy en payments else")
            output$confirmacionPago <- renderText({
                "No deberia estar aquí. Redirigir a la pagina de planes"
            })
            delay(100, shinyjs::show("redirectLicencias"))

        }
    })

    


    


}