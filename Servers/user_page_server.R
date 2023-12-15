user_page_server <- function(input, output, session){

    rol <- session$userData$rol
    
    message(sprintf("rol user: %s", rol))
    id_psicologo <- session$userData$id_psicologo

    con <- establishDBConnection()
    query <- sprintf("SELECT nombre from PSICOLOGO WHERE id=%d", id_psicologo)
    user_name <- DBI::dbGetQuery(con, query)
    DBI::dbDisconnect(con)

    output$nombre <- renderText({
        paste(user_name,"")
    })

    observeEvent(input$admin_btn,
    runjs("window.open('/keycloak/admin/Gridfcm/console/', '_blank' );")
    )

    con <- establishDBConnection()
    query <- sprintf("SELECT fecha_inicio, fecha_fin, activa from SUSCRIPCION WHERE fk_psicologo=%d", id_psicologo)
    datos <- DBI::dbGetQuery(con, query)
    DBI::dbDisconnect(con)

    fecha_inicio <- datos$fecha_inicio
    fecha_fin <- datos$fecha_fin
    activa <- datos$activa
    datos <- data.frame(fecha_inicio, fecha_fin, activa)

    observeEvent(input$redirect_licencias, {
        # Navigates to the "Form" page when the specified input is clicked
        runjs("window.location.href = '/#!/plan';")
    })

    if(!is.null(rol)){
        if(rol == "usuario_administrador"){
            shinyjs::show("admin_btn")
        }
        else{
            shinyjs::hide("admin_btn")
        }

        if(rol == "usuario_ilimitado"){
            shinyjs::hide("redirect_licencias")
        }else{
            shinyjs::show("redirect_licencias")
        }
    }

    if(length(datos$activa) > 0){ #no funciona con !is.null(datos$activa)
        # Hay una suscripcion o mas para el usuario, comprobar si esta activa
        if(TRUE %in% datos$activa){
            if(!is.null(rol)){
                if(rol != "usuario_coordinador_organizacion" && rol != "usuario_administrador"){
                    output$suscripcion_activa <- renderText({
                        paste("Suscripciones Activadas: ", length(datos[datos$activa,c("activa")]))
                    })
                    # shinyjs::show("admin_btn")
                }else{
                    output$suscripcion_activa <- renderText({
                        paste("Suscripciones de Organización Activadas: ", length(datos[datos$activa,c("activa")]))
                    })
                }
            }
            
            

            datos_activos = datos[datos$activa,]
            fechas_text <- ""
            for(i in 1:nrow(datos_activos)) {       # for-loop over rows
                fechas_text <- paste(fechas_text, "\n", paste("Periodo Suscripcion ", i, ": ", datos_activos[i,c("fecha_inicio")], " hasta ", datos_activos[i,c("fecha_fin")]))
            } 

            output$fechas_suscripcion <- renderText({
                fechas_text
            })
            
        }else{
            output$suscripcion_activa <- renderText({
                paste("Suscripción de Organización: Desactivada")
            })

            datos_no_activos <- datos[!datos$activa,]
            datos_no_activos <- tail(datos_no_activos, n=1)
            output$fechas_suscripcion <- renderText({
                paste("Periodo Suscripcion: ", datos_no_activos$fecha_inicio, " hasta ", datos_no_activos$fecha_fin)
            })
        }
    }else{
        # No hay una suscripcion para el usuario, comprobar si hay alguna licencia asignada a el
        con <- establishDBConnection()
        query <- sprintf("SELECT fk_psicologo from LICENCIA WHERE fk_psicologo=%d", id_psicologo)
        datos <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        
        if(length(datos$fk_psicologo) > 0){
            # hay licencia asignada al usuario
            output$suscripcion_activa <- renderText({
                paste("Licencia Activada")
            })
        }else{
            output$suscripcion_activa <- renderText({
                paste("Sin Licencia")
            })
        }
    }

    
    # if(!is.null(rol)){
    #     if(rol == "usuario_administrador"){
    #         shinyjs::hide("sugerencias_usuarios")
    #         shinyjs::show("sugerencias_admin")
    #         shinyjs::show("usuarios_demo")
    #     }
    #     else{
    #         shinyjs::hide("sugerencias_admin")
    #         shinyjs::show("sugerencias_usuarios")
    #         shinyjs::hide("usuarios_demo")
    #     }
    # }

    # output$tabla_sugerencias <- renderDT({
    #     con <- establishDBConnection()
    #     query <- sprintf("SELECT s.sugerencia as sugerencia, s.fecha as fecha, p.nombre as nombre, p.rol, p.email as email FROM sugerencias as s, psicologo as p 
    #                         where s.fk_psicologo = p.id")
    #     users <- DBI::dbGetQuery(con, query)
    #     DBI::dbDisconnect(con)
    #     # Convertir fecha_registro a POSIXct y formatear
    #     fecha_hora <- as.POSIXct(users$fecha, origin = "1970-01-01")
    #     users$fecha <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
    #     df <- data.frame(n=users$sugerencia, e=users$fecha, g=users$nombre, d=users$rol, f=users$email)
    #     DT::datatable(df, selection = 'single', rownames = FALSE,
    #         options = list(order = list(1, 'asc')),
    #         colnames = c(i18n$t("Sugerencia"), i18n$t("Fecha"), i18n$t("Enviada por"), "Rol", i18n$t("Correo")))
    # })

    # output$tabla_usuario_demo <- renderDT({
    #     con <- establishDBConnection()
    #     users <- DBI::dbGetQuery(con, "SELECT DISTINCT email FROM usuario_demo")
    #     DBI::dbDisconnect(con)
    #     DT::datatable(users)
    # })

    # suggestion_to_db <- function(sugerencia) {
    #     con <- establishDBConnection()

    #     # Obtener la fecha actual en formato legible
    #     fecha_actual <- format(Sys.time(), format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Madrid")
    #     fk_psicologo <- session$userData$id_psicologo

    #     # Crear la consulta SQL utilizando sprintf
    #     query <- sprintf(
    #         "INSERT INTO sugerencias (sugerencia, fk_psicologo, fecha) VALUES ('%s', %d, '%s')",
    #         sugerencia, fk_psicologo, fecha_actual
    #     )

    #     # Ejecutar la consulta SQL
    #     DBI::dbExecute(con, query)

    #     # Cerrar la conexión a la base de datos
    #     DBI::dbDisconnect(con)
    # }


    # observeEvent(input$sugerencia, {
    #     if(input$sugerencia == ""){
    #         shinyjs::disable("send_suggestion")
    #     }
    #     else{
    #         shinyjs::enable("send_suggestion")
    #     }
    # })
    # observeEvent(input$send_suggestion, {
    #     # Aquí puedes agregar el código para manejar la sugerencia
    #     # Por ejemplo, puedes guardarla en una base de datos o mostrar un mensaje de confirmación
    #     sugerencia <- input$sugerencia
        
         
    #     updateTextAreaInput(session, "sugerencia", value="")

    #     suggestion_to_db(sugerencia)
    #     # En este ejemplo, simplemente mostraremos un mensaje de confirmación en la salida
    #     showNotification(
    #         ui = i18n$t("Su sugerencia ha sido enviada correctamente. Muchas gracias!"),
    #         type = "message",
    #         duration = 7
    #     )
    # })
}