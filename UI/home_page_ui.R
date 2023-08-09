home_page <-  div(
    titlePanel("Home page"),
    p("This is the home page!"),
    uiOutput("power_of_input"),
    actionButton("go_to_another", "Go to another page"), # Agregar botón aquí
    tags$li(a(class = "item", href = route_link("another"), "Another page")),
    sliderInput("int", "Choose integer:", -10, 10, 1, 1)
    )