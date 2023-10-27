inicio_server <- function(input, output, session) {

  # shinyjs::addClass(selector = "body", class = "sidebar-collapse")

  observeEvent(input$ingresar, {
    # if (!is.na(input$usuario) && !is.na(input$contrasena) && verificar_login(input$usuario, input$contrasena)) {
    # mensaje("Inicio de sesión exitoso!")
    # route_link("user_home")
    runjs("window.location.href = '/#!/user_home';")
  })

  observeEvent(input$invitado, {
    # route_link("user_home")
    # tags$ul(tags$li(a(class = "item", href = route_link("user_home"), "u page")))
    runjs("window.location.href = '/#!/patient';")
    
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
