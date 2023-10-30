inicio_server <- function(input, output, session) {

  observeEvent(input$ingresar, {
    # if (!is.na(input$usuario) && !is.na(input$contrasena) && verificar_login(input$usuario, input$contrasena)) {
    # mensaje("Inicio de sesión exitoso!")
    # route_link("user_home")
    runjs("window.location.href = '/#!/user_home';")
    runjs("
    $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

    $('#user-page')
      .find('.nav-link')
      .addClass('active');
    ")
    # } else {
    #    mensaje("Nombre de usuario o contraseña incorrectos.")
    # }
  })

  observeEvent(input$invitado, {
    # route_link("user_home")
    # tags$ul(tags$li(a(class = "item", href = route_link("user_home"), "u page")))
    runjs("window.location.href = '/#!/import';")
     runjs("
    $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

    $('#import-page')
      .find('.nav-link')
      .addClass('active');
  ")
    
  })
}

verificar_login <- function(usuario, contrasena) {
  nombre_usuario_valido <- "admin"
  contrasena_valida <- "password"
  # lo hara keycloack?
  # return(usuario == nombre_usuario_valido && contrasena == contrasena_valida)
}

