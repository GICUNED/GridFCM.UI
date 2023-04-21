inicio_ui <-  div(

  h2("Inicia sesión para continuar", class = "pagetitlecustom mb-4 animated bounce"),
        fluidRow(
          column(7, class = "animated bounce",
          box(
            id = "login_box",
            title = "Inicio de sesión",
            icon = icon("right-to-bracket"),
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            textInput("usuario", "Nombre de usuario", placeholder = 'Introduce tu usuario'),
            passwordInput("contrasena", "Contraseña", placeholder = '■ ■ ■ ■ ■ ■ ■ ■'),

            column(12, class="d-flex justify-content-center mb-2", actionButton("ingresar", "Acceder", status = 'primary', icon = icon("arrow-up"),)),
            column(12, class="d-flex justify-content-center", actionButton("invitado", "Sesión de invitado", icon = icon("user")))

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