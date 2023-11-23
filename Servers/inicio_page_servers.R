inicio_server <- function(input, output, session) {

  #httr::set_config(config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
  keycloak_client_id <- "gridfcm"
  domain <- Sys.getenv("DOMAIN")
  ruta_app <- sprintf("https://%s/", domain)
  make_authorization_url <- function() {
    
    url_template <- "http://%s/keycloak/realms/Gridfcm/protocol/openid-connect/auth?client_id=%s&redirect_uri=%s&response_type=code&scope=%s"
    sprintf(url_template,
      domain,
      utils::URLencode(keycloak_client_id, reserved = TRUE, repeated = TRUE),
      utils::URLencode(ruta_app, reserved = TRUE, repeated = TRUE),
      utils::URLencode("openid roles", reserved = TRUE, repeated = TRUE)
    )
  }

  observeEvent(input$ingresar, {
    link <- make_authorization_url()
    message(link)
    runjs(paste0("window.location.href = '", link, "';"))
  })

  isValidEmail <- function(x) {
    grepl("\\<[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\>", as.character(x), ignore.case=TRUE)
  }

  observeEvent(input$invitado, {
    showModal(modalDialog(
          title = i18n$t("Acceso modo invitado"),
          textInput("email_invitado", i18n$t("Introduzca su e-mail"), value=""),
          box(
            icon = icon("book"),
            width = 12,
            collapsed = TRUE,
            title = i18n$t("Aviso legal"),
            div(
              id = "aviso_legal",
              # Título
              h3(strong(
                "Aviso Legal - Uso del Correo Electrónico para Fines Comerciales"
              )),
              # Párrafo introductorio
              p(
                "Este Aviso Legal regula el uso de su dirección de correo electrónico proporcionada al acceder y utilizar la aplicación web (en adelante, 'la Aplicación') propiedad de UNED (en adelante, 'el Titular'). Por favor, lea atentamente este aviso antes de continuar utilizando la Aplicación."
              ),
              # Párrafos de contenido
              strong(
                "Consentimiento"
              ),
              p(
                "Al utilizar la Aplicación, usted acepta y consiente expresamente que su dirección de correo electrónico proporcionada será utilizada por el Titular con fines comerciales. Esto implica que el Titular podrá enviarle comunicaciones, información de productos, promociones y otras comunicaciones comerciales relacionadas con sus servicios y productos a la dirección de correo electrónico proporcionada."
              ),
              strong(
                "Obligación de Proporcionar el Correo Electrónico"
              ),
              p(
                "El Titular requiere que proporcione su dirección de correo electrónico como condición necesaria para acceder y utilizar la Aplicación. Sin la provisión de esta información, no se le permitirá acceder a la Aplicación."
              ),
              strong(
                "Derecho a Retirar el Consentimiento"
              ),
              p(
                "Usted tiene el derecho de retirar su consentimiento en cualquier momento. Puede hacerlo siguiendo las instrucciones proporcionadas en las comunicaciones comerciales que reciba o poniéndose en contacto con el Titular utilizando los datos de contacto proporcionados en la Aplicación."
              ),
              strong(
                "Uso Responsable del Correo Electrónico"
              ),
              p(
                "El Titular se compromete a utilizar su dirección de correo electrónico de acuerdo con la legislación vigente en materia de protección de datos y privacidad. Su dirección de correo electrónico no será compartida con terceros sin su consentimiento previo."
              ),
              strong(
                "Seguridad de Datos"
              ),
              p(
                "El Titular toma medidas de seguridad razonables para proteger la información proporcionada, incluyendo su dirección de correo electrónico. Sin embargo, no se puede garantizar la seguridad absoluta en la transmisión de datos por Internet. Usted reconoce y acepta que la transmisión de datos por Internet siempre conlleva riesgos."
              ),
              strong(
                "Modificaciones del Aviso Legal"
              ),
              p(
                "El Titular se reserva el derecho de modificar este Aviso Legal en cualquier momento. Las modificaciones entrarán en vigor inmediatamente después de su publicación en la Aplicación. Se le notificará cualquier cambio importante en la forma en que se utiliza su dirección de correo electrónico."
              ),
              strong(
                "Contacto"
              ),
              p(
                "Si tiene alguna pregunta o inquietud relacionada con este Aviso Legal o el uso de su dirección de correo electrónico, puede ponerse en contacto con el Titular a través de los datos de contacto proporcionados en la Aplicación o dejando un comentario en la página de sugerencias."
              ),
              # Párrafo final
              p(
                "Al proporcionar su dirección de correo electrónico y continuar utilizando la Aplicación, usted reconoce y acepta los términos y condiciones establecidos en este Aviso Legal."
              )
            )
          ),
          fade = TRUE,
          footer = tagList(
            modalButton("Cancelar"),
            actionButton("entrar_invitado", i18n$t("Aceptar condiciones"), status= "success", class = "btn-success")
          )
      ))
  })

  observeEvent(input$entrar_invitado, {
    email <- input$email_invitado
    if(!isValidEmail(email)){
      updateTextInput(session, "email_invitado", value = "")
      showNotification(
        ui = sprintf("El email introducido (%s), no existe. Introduzca uno válido", email),
        type = "error",
        duration = 5
      ) 
    }
    else{
      removeModal()
      showNotification(
        ui = sprintf("Bienvenido a la PsychLab, %s", email),
        type = "message",
        duration = 5
      ) 
      shinyjs::hide("welcome_box")
      shinyjs::show("patient-page")
      shinyjs::show("repgrid-page")
      shinyjs::show("wimpgrid-page")
      con <- establishDBConnection()
      # meto el usuario demo en la tabla de usuarios demo para almacenar su email y enviar publi luego
      DBI::dbExecute(con, sprintf("INSERT INTO usuario_demo(email) VALUES('%s')", email))

      # pillo el psicologo/usuario de prueba para poder utilizar la aplicacion
      id <- DBI::dbGetQuery(con, "SELECT id, rol FROM psicologo WHERE email='prueba@uned.com';")
      session$userData$rol <- id$rol
      session$userData$id_psicologo <- as.integer(id$id)
      patient_server(input, output, session)
      DBI::dbDisconnect(con)
    }
  })

  runjs("
  $(document).on('mousemove', function(e) {
    var xPos = e.pageX;
    var yPos = e.pageY;
   
    $('#psychlabmove').css({
      'top': yPos/-100,
      'left': xPos/-100
    });
  });
  ")


  output$psychlabmove <- renderImage({
    
      return(list(
        src = "www/IconUNED_light.svg",
        contentType = "image/svg+xml",
        alt = "IconPsychLab"
      ))

  }, deleteFile = FALSE)

}
