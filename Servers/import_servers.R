import_server <- function(input, output, session) {
   # agregar código para manejar eventos y actualizar elementos en la página Import
  # Lógica del servidor para la página Import

  observeEvent(input$importar_xlsx, {
    # Navegar a la página de importación de datos desde archivo xlsx
    # route_link("nombre_de_la_pagina_de_importacion_xlsx")
    runjs("window.location.href = '/#!/excel';")
    runjs("
    $('.nav-pills')
      .find('.nav-link')
      .removeClass('active');

    $('#excel-page')
      .find('.nav-link')
      .addClass('active')
      .addClass('sub');
  ")
  })

  observeEvent(input$importar_formulario, {
    #me paso la variable session 


    # Navigates to the "Form" page when the specified input is clicked
    runjs("window.location.href = '/#!/form';")
    # revisar este runjs ???
    runjs("
      $('.nav-pills')
        .find('.nav-link')
        .removeClass('active');

      $('#form-page')
        .find('.nav-link')
        .addClass('active')
        .addClass('sub');
    ")
  })
}