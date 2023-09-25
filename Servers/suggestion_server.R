suggestion_server <- function(input, output, session){

    suggestion_to_db <- function(sugerencia) {
        con <- establishDBConnection()

        # Obtener la fecha actual en formato legible
        fecha_actual <- format(Sys.time(), format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Madrid")
        fk_psicologo <- 1 # de momento

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