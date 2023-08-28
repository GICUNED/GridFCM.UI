form_repgrid_server <- function(input, output, session){
    shinyjs::hide("namesForm")
    nombres <- reactiveVal(character(0))
    lista_nombres <- list()
    observeEvent(input$guardarNombre, {
        if (nchar(input$nombrePaciente) > 0) {
            nombres(c(nombres(), input$nombrePaciente))
            #reactiveVal entre parentesis sin parametros devuelve el valor del objeto
            lista_nombres <- list(nombres())
            session$userData$repgrid_form$elementos = lista_nombres
            updateTextInput(session, "nombrePaciente", value = "")
        }
    })
    
    output$lista_nombres <- renderUI({
        if (length(nombres()) > 0) {
            shinyjs::show("namesForm")
            menu_items <- lapply(nombres(), function(nombre) {
                menuItem(nombre, icon = icon("user"))
            })
            sidebarMenu(menu_items)
            
        } else {
            NULL
        }
    })
    
    onevent("click", "continuar",{
        
        message(session$userData$repgrid_form$elementos)
    })
}