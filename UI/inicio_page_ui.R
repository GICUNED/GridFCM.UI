inicio_ui <-  div(

  h2("Bienvenido a la página de inicio del usuario", class = "pagetitlecustom"),
        fluidRow(
          column(7,
          box(
            id = "login_box",
            title = "Inicio de sesión",
            icon = icon("right-to-bracket"),
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            textInput("usuario", "Nombre de usuario", placeholder = 'Introduce tu usuario'),
            passwordInput("contrasena", "Contraseña", placeholder = '■ ■ ■ ■ ■ ■ ■ ■'),

            column(12, actionButton("ingresar", "Acceder", status = 'primary')),
            column(12, actionButton("invitado", "Acceder como invitado"))

          )),
          column(5,
          #tags$ul(tags$li(a(class = "item", href = route_link("user_home"), "user home")))
          box(
            title = "Información",
            icon = icon("circle-info"),
            status = "success",
            solidHeader = TRUE,
            width = 12,
            p("Aquí se agregará más información sobre la aplicación y el método que se utiliza.")
          ))    
    )
  )