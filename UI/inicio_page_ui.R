inicio_ui <-  div(
    tags$head(
      tags$style(HTML("
        /* estilos CSS personalizados */
        .skin-blue .main-header .navbar {
          background-color: #005440;
        }
        .skin-blue .main-header .logo {
          background-color: #45CE98;
          color: #0A0A0A;
        }
        /* Personalizar el color del cuadro de inicio de sesión */
        #login_box.box.box-primary {
          border-top-color: #45CE98;
          background-color: #BFE9D8;
        }
        #login_box.box.box-primary > h3,
        #login_box.box.box-primary > p {
          color: #0A0A0A;
        }
      "))
    ),
    tabItems(
      tabItem(
        tabName = "inicio",
        fluidRow(
          box(
            id = "login_box",
            title = "Inicio de sesión",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            textInput("usuario", "Nombre de usuario"),
            passwordInput("contrasena", "Contraseña"),
            actionButton("ingresar", "Ingresar")
          ),
          box(
            id = "guest_box",
            title = "Modo invitado",
            status = "warning",
            solidHeader = TRUE,
            width = 6,
            actionButton("invitado", "Ingresar como invitado")
          ),
          #tags$ul(tags$li(a(class = "item", href = route_link("user_home"), "user home")))
        ),
        fluidRow(
          box(
            title = "Sobre la aplicación",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            p("Aquí se agregará más información sobre la aplicación y el método que se utiliza.")
          )
        )
      )
    ),
  )