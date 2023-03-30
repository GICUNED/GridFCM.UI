another_page <- div(
    titlePanel("Another page"),
    p("This is the anotuher page!"),
    textInput("another_input", "Type something:"),
    verbatimTextOutput("another_output"),
    actionButton("go_to_home", "Go to Home page"), # Agregar botón aquí
    tags$li(a(class = "item", href = route_link("/"), "home page"))
  )
