form_server <- function(input, output, session){
    shinyjs::hide("namesForm")
    nombres <- reactiveVal(character(0))
    lista_nombres <- list()
    nombre_seleccionado <- reactiveVal(NULL)

    # Botón añadir 
    observeEvent(input$guardarNombre, {
        if (nchar(input$nombrePaciente) > 0) {
            shinyjs::show("namesForm")
            nombres(c(nombres(), input$nombrePaciente))
            #reactiveVal entre parentesis sin parametros devuelve el valor del objeto
            
            updateTextInput(session, "nombrePaciente", value = "")
        }
        output$lista_nombres <- renderUI({
            if (length(nombres()) > 0) {
                menu_items <- lapply(nombres(), function(nombre) {
                    menuItem(nombre, icon = icon("user"), tabName=nombre)
                })
                sidebarMenu(id="menu_elementos", menu_items)
            } 
        })
    })
    observe(
        if(!is.null(input$menu_elementos)){
            nombre_seleccionado(input$menu_elementos)
            shinyjs::enable("borrarElemento")
        }
        else{
            shinyjs::disable("borrarElemento")
        }
    )
    
    observeEvent(input$borrarElemento, {
        nombre <- nombre_seleccionado()
        if(!is.null(nombre)){
            nombres_lista <- nombres()
            # Eliminar el nombre seleccionado
            nombres_lista <- nombres_lista[nombres_lista != nombre]
            nombres(nombres_lista)
            output$lista_nombres <- renderUI({
                menu_items <- lapply(nombres(), function(nombre) {
                    menuItem(nombre, icon = icon("user"), tabName=nombre)
                })
                sidebarMenu(id="menu_elementos", menu_items)
            })
        }
    })

    
    observeEvent(input$continuar, {
        # cambiar luego esto para que se vaya construyendo el dataframe para luego meterlo en la bd y 
        # posteriormente pasarle el codificar y decodificar....
        lista_nombres <- list(nombres())
        session$userData$repgrid_form$elementos = lista_nombres
        message(session$userData$repgrid_form$elementos)
    })
}