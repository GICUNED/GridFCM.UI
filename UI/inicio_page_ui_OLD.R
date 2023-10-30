inicio_ui <- fluidPage( 
  shiny.i18n::usei18n(i18n),
  
  div(class = "custom-margins",

  h2(i18n$t("Inicia sesión para continuar"), class = "pagetitlecustom mb-4"),
        fluidRow(
          column(7,
          box(
            id = "login_box",
            title = i18n$t("Inicio de sesión"),
            icon = icon("right-to-bracket"),
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            div(class="mb-2", textInput("usuario", i18n$t("Nombre de usuario"), placeholder = "Introduce usuario")),
            div(class="mb-2", passwordInput("contrasena", i18n$t("Contraseña"), placeholder = '■ ■ ■ ■ ■ ■ ■ ■')),

            column(12, class="d-flex justify-content-center mb-2 mt-2", actionButton("ingresar", i18n$t("Acceder"), status = 'primary', icon = icon("arrow-up"),)),
            column(12, class="d-flex justify-content-center", actionButton("invitado", i18n$t("Sesión de invitado"), icon = icon("user")))

          )),
          column(5,
          #tags$ul(tags$li(a(class = "item", href = route_link("user_home"), "user home")))
          box(
            title = i18n$t("Información"),
            icon = icon("circle-info"),
            status = "success",
            solidHeader = TRUE,
            width = 12,
            p(i18n$t("Aquí se agregará más información sobre la aplicación y el método que se utiliza."))
          )
          )    
    )
  ))