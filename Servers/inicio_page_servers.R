inicio_server <- function(input, output, session) {

  observeEvent(input$ingresar, {
    link <- make_authorization_url()
    message(link)
    runjs(paste0("window.location.href = '", link, "';"))
  })

  observeEvent(input$invitado, {
    shinyjs::hide("welcome_box")
    shinyjs::show("patient-page")
    shinyjs::show("repgrid-page")
    shinyjs::show("wimpgrid-page")
    con <- establishDBConnection()
    id <- DBI::dbGetQuery(con, "SELECT id, rol FROM psicologo WHERE email='prueba@uned.com';")
    session$userData$rol <- id$rol
    session$userData$id_psicologo <- as.integer(id$id)
    patient_server(input, output, session)
    DBI::dbDisconnect(con)
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
