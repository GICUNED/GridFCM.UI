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

    shinyjs::onclick("metricas", {
        shinyjs::toggle("iframeContainer")
    })

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
            shinyjs::show("metricas")
        }
        else{
            shinyjs::hide("admin_btn")
            shinyjs::hide("metricas")
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
                    output$suscripcion_activa <- renderUI({
                        HTML(paste("<strong>", i18n$t("Suscripciones Activadas"), ":</strong>", length(datos[datos$activa,c("activa")])))
                    })
                    # shinyjs::show("admin_btn")
                }else{
                    output$suscripcion_activa <- renderUI({
                        HTML(paste("<strong>", i18n$t("Suscripciones de Organización Activadas"), ":</strong>", length(datos[datos$activa,c("activa")])))
                    })
                }
            }
            
            

            datos_activos = datos[datos$activa,]
            fechas_text <- ""
            for(i in 1:nrow(datos_activos)) {       # for-loop over rows
                fechas_text <- HTML(paste(fechas_text, "\n", paste("<strong>", i18n$t("Periodo Suscripción "), i, "</strong>", ": ", datos_activos[i,c("fecha_inicio")], "<i class='fa-solid fa-right-long'></i>", datos_activos[i,c("fecha_fin")], "<br>")))
            } 

            output$fechas_suscripcion <- renderUI({
                fechas_text
            })
            
        }else{
            output$suscripcion_activa <- renderUI({
                HTML(paste("<strong>", i18n$t("Periodo Suscripción: "), "</strong>", i18n$t("Desactivadsa")))
            })

            datos_no_activos <- datos[!datos$activa,]
            datos_no_activos <- tail(datos_no_activos, n=1)
            output$fechas_suscripcion <- renderUI({
                HTML(paste("<strong>", i18n$t("Periodo Suscripción: "), "</strong>", datos_no_activos$fecha_inicio, "<strong>", " -> ", "</strong>", datos_no_activos$fecha_fin))
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
            output$suscripcion_activa <- renderUI({
                HTML(paste("<strong>", i18n$t("Licencia Activada"), "</strong>"))
            })
        }else{
            output$suscripcion_activa <- renderUI({
                HTML(paste("<strong>", i18n$t("Sin Licencia"), "</strong>"))
            })
            shinyjs::hide("fechas_suscripcion")
        }
    }

    output$tabla_usuario_demo <- renderDT({
        con <- establishDBConnection()
        users <- DBI::dbGetQuery(con, "SELECT DISTINCT email, fecha_registro FROM usuario_demo")
        DBI::dbDisconnect(con)
        DT::datatable(users, colnames = c(i18n$t("Email"), i18n$t("Fecha Registro")))
    })

    output$tabla_usuario_registrados <- renderDT({
        con <- establishDBConnection()
        users <- DBI::dbGetQuery(con, "SELECT DISTINCT email, nombre, username, rol, colectivo, fecha_registro FROM psicologo")
        DBI::dbDisconnect(con)
        DT::datatable(
            users,
            colnames = c(i18n$t("Email"), i18n$t("Nombre"), i18n$t("Nombre Usuario"), i18n$t("Rol"), i18n$t("Colectivo"), i18n$t("Fecha Registro"))
        )
    })
    
    temporal <- NULL  # Defino temporal en un alcance superior
    output$exportar_usuarios <- downloadHandler(
        filename = function() {
            fecha <- gsub(" ", "_", Sys.Date())
            nombre_temporal <- paste("Usuarios_demo", "_", fecha,  ".xlsx", sep="", collapse="")
            message(nombre_temporal)
            temporal <- file.path(tempdir(), nombre_temporal)
            # traemos los emails de la bd
            con <- establishDBConnection()
            query <- sprintf("select email, fecha_registro from usuario_demo")
            users <- DBI::dbGetQuery(con, query)
            DBI::dbDisconnect(con)
            users$fecha_registro <- as.Date(users$fecha_registro, format = "%Y-%m-%d %H:%M:%S")
            my_dataframe = data.frame(users)
            names(my_dataframe) <- c(i18n$t("Email"), i18n$t("Fecha Registro"))
            write.xlsx(my_dataframe, temporal)
            return(nombre_temporal)
        },
        content = function(file) {
            fecha <- gsub(" ", "_", Sys.Date())
            nombre_temporal <- paste("Usuarios_demo", "_", fecha,  ".xlsx", sep="", collapse="")
            temporal <- file.path(tempdir(), nombre_temporal)
            file.copy(temporal, file)
            file.remove(temporal)  # Elimina el archivo temporal después de descargarlo
        }
    )

    temporal2 <- NULL  # Defino temporal en un alcance superior
    output$exportar_usuarios_registrados <- downloadHandler(
        filename = function() {
            fecha <- gsub(" ", "_", Sys.Date())
            nombre_temporal <- paste("Usuarios_registrados", "_", fecha,  ".xlsx", sep="", collapse="")
            message(nombre_temporal)
            temporal2 <- file.path(tempdir(), nombre_temporal)
            # traemos los emails de la bd
            con <- establishDBConnection()
            query <- sprintf("SELECT DISTINCT email, nombre, username, rol, colectivo, fecha_registro FROM psicologo")
            users <- DBI::dbGetQuery(con, query)
            users$fecha_registro <- as.Date(users$fecha_registro, format = "%Y-%m-%d %H:%M:%S")
            DBI::dbDisconnect(con)
            my_dataframe = data.frame(users)
            names(my_dataframe) <- c(i18n$t("Email"), i18n$t("Nombre"), i18n$t("Nombre Usuario"), i18n$t("Rol"), i18n$t("Colectivo"), i18n$t("Fecha Registro"))
            write.xlsx(my_dataframe, temporal2)
            return(nombre_temporal)
        },
        content = function(file) {
            fecha <- gsub(" ", "_", Sys.Date())
            nombre_temporal <- paste("Usuarios_registrados", "_", fecha,  ".xlsx", sep="", collapse="")
            temporal2 <- file.path(tempdir(), nombre_temporal)
            file.copy(temporal2, file)
            file.remove(temporal2)  # Elimina el archivo temporal después de descargarlo
        }
    )
}