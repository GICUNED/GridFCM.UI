suggestion_server <- function(input, output, session){
    rol <- session$userData$rol
    if(!is.null(rol)){
        if(rol == "usuario_administrador"){
            shinyjs::hide("sugerencias_usuarios")
            shinyjs::show("sugerencias_admin")
            shinyjs::show("usuarios_demo")
        }
        else{
            shinyjs::hide("sugerencias_admin")
            shinyjs::show("sugerencias_usuarios")
            shinyjs::hide("usuarios_demo")
        }
    }

    output$tabla_sugerencias <- renderDT({
        con <- establishDBConnection()
        query <- sprintf("SELECT s.sugerencia as sugerencia, s.fecha as fecha, p.nombre as nombre, p.rol, p.email as email FROM sugerencias as s, psicologo as p 
                            where s.fk_psicologo = p.id")
        users <- DBI::dbGetQuery(con, query)
        DBI::dbDisconnect(con)
        # Convertir fecha_registro a POSIXct y formatear
        fecha_hora <- as.POSIXct(users$fecha, origin = "1970-01-01")
        users$fecha <- format(fecha_hora, format = "%Y-%m-%d %H:%M:%S")
        df <- data.frame(n=users$sugerencia, e=users$fecha, g=users$nombre, d=users$rol, f=users$email)
        DT::datatable(df, selection = 'single', rownames = FALSE,
            options = list(order = list(1, 'asc')),
            colnames = c(i18n$t("Sugerencia"), i18n$t("Fecha"), i18n$t("Enviada por"), "Rol", i18n$t("Correo")))
    })

    output$tabla_usuario_demo <- renderDT({
        con <- establishDBConnection()
        users <- DBI::dbGetQuery(con, "SELECT DISTINCT email FROM usuario_demo")
        DBI::dbDisconnect(con)
        DT::datatable(users)
    })

    suggestion_to_db <- function(sugerencia) {
        con <- establishDBConnection()

        # Obtener la fecha actual en formato legible
        fecha_actual <- format(Sys.time(), format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Madrid")
        fk_psicologo <- session$userData$id_psicologo

        # Crear la consulta SQL utilizando sprintf
        query <- sprintf(
            "INSERT INTO sugerencias (sugerencia, fk_psicologo, fecha) VALUES ('%s', %d, '%s')",
            sugerencia, fk_psicologo, fecha_actual
        )

        # Ejecutar la consulta SQL
        DBI::dbExecute(con, query)

        # Cerrar la conexión a la base de datos
        DBI::dbDisconnect(con)
    }


    observeEvent(input$sugerencia, {
        if(input$sugerencia == ""){
            shinyjs::disable("send_suggestion")
        }
        else{
            shinyjs::enable("send_suggestion")
        }
    })
    observeEvent(input$send_suggestion, {
        # Aquí puedes agregar el código para manejar la sugerencia
        # Por ejemplo, puedes guardarla en una base de datos o mostrar un mensaje de confirmación
        sugerencia <- input$sugerencia
        
         
        updateTextAreaInput(session, "sugerencia", value="")

        suggestion_to_db(sugerencia)
        # En este ejemplo, simplemente mostraremos un mensaje de confirmación en la salida
        showNotification(
            ui = i18n$t("Su sugerencia ha sido enviada correctamente. Muchas gracias!"),
            type = "message",
            duration = 7
        )
    })
}