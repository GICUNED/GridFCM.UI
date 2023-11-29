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



  #Homepage with carousel

  inicio_ui <- add_cookie_handlers(
  fluidPage(class ="custom-margins",

    useShinyjs(),
    shiny.i18n::usei18n(i18n),

    fluidRow( class = ("flex-container-titles mt-2 custom-margins-sm"),

      imageOutput("psychlabmove", width = "fit-content", height = "100px"),
      h1(i18n$t("La herramienta de exploración psicológica avanzada"), class = "pagetitlecustom mb-4"),
      p(i18n$t("Descubre de qué es capaz PsychLab. Prueba la técnica de rejilla para obtener muestras homogéneas de análisis del mundo de significados."), class = "desccustom"),
    ),

    fluidRow( class="mt-4", 
              
      slickR(slick_list(
          tags$div(class = "slidecontainer",
            tags$img(
              src = "Images/sesgos.jpg",
              height = 400
            ),
            fluidRow( class = ("slidecontent flex-container-sm mt-2"),

            column(12,
              box( class="shadow",
                id = "welcome_box",
                title = i18n$t("¡Bienvenido/a!"),
                icon = icon("smile"),
                status = "secondary",
                collapsible = FALSE,
                solidHeader = FALSE,
                width = 12,
                actionButton("ingresar", status = "primary", i18n$t("Iniciar Sesión"), icon = icon("right-to-bracket")),
                actionButton("invitado", i18n$t("Sesión de invitado"), icon = icon("user"))

            )),
          ),
            align = "center"
          ),
          tags$div(class = "slidecontainer",
            tags$img(
              src = "Images/head.jpg",
              height = 400
            ),
            fluidRow(class = ("flex-container-xl mt-2 slidecontent-2 bg-blurry rounded-lg p-4 pt-2 shadow"),
                icon("flask"),
                h3(i18n$t("Análisis de Rejilla"), class = "pagetitlecustom mb-2"),
              
              div(class = ("button-container mt-2"),
                actionButton("ingresar", status ="primary", class="btn-herramienta", i18n$t("RepGrid"), icon = icon("magnifying-glass-chart")),
                actionButton("invitado", status ="warning", class="btn-herramienta", i18n$t("WimpGrid"), icon = icon("border-none"))
              )
            ),
            align = "center"
          ),
          tags$div(class = "slidecontainer",
            tags$img(
              src = "Images/head.jpg",
              height = 400
            ),
            align = "center"
          )
        )) + settings(autoplay = TRUE, autoplaySpeed = 1000, pauseOnHover=TRUE, dots = TRUE)          
    )
  )
)


)

  