library(shiny)
library(shinyjs)
library(shinydashboard)
library(OpenRepGrid)
library(toastui)
library(DT)
library(openxlsx)
library(bs4Dash)
library(fresh)
library(rgl)
library(knitr)
library(kableExtra)
library(rhandsontable)
library(igraph)
library(plotly)
library(stats)
library(shiny.router)
library(shiny.i18n)
knitr::knit_hooks$set(webgl = hook_webgl)



source("global.R")


#GRID
source("R/GraphFunctions.R")
source("R/HideFunctions.R")
source("R/ImportFunctions.R")
source("R/IndicesSummary.R")
source("R/PCSDindicesFunctions.R")
source("R/SimulationFunctions.R")
source("R/WimpIndicesFunctions.R")
# UI
source("UI/home_page_ui.R")
source("UI/another_page_ui.R")
source("UI/userHome_ui.R")
source("UI/inicio_page_ui.R")
source("UI/import_ui.R")
source("UI/import_excel_ui.R")
source("UI/repgrid_home_ui.R")
source("UI/repgrid_analysis_ui.R")
source("UI/repgrid_ui.R")
source("UI/wimpgrid_analysis_ui.R")

# SERVERS
source("Servers/home_page_server_observers.R")
source("Servers/another_page_server_observers.R")
source("Servers/userHome_page_server.R")
source("Servers/inicio_page_servers.R")
source("Servers/import_servers.R")
source("Servers/import_excel_servers.R")
source("Servers/repgrid_home_servers.R")
source("Servers/repgrid_analysis_server.R")
source("Servers/repgrid_server.R")
source("Servers/wimpgrid_analysis_server.R")



menu <- tags$ul(tags$li(a(
  class = "item", href = route_link(""), "Inicio"
)),
tags$li(a(
  class = "item", href = route_link("user_home"), "User"
)),
tags$li(a(
  class = "item", href = route_link("import"), "Import"
)),
tags$li(a(
  class = "item", href = route_link("excel"), "Import excel"
)),
tags$li(a(
  class = "item", href = route_link("repgrid"), "Repgrid home"
)),
tags$li(a(
  class = "item",
  href = route_link("wimpgrid"),
  "Wimpgrid analysis"
)))


theme <- create_theme(
  bs4dash_status(
    primary = "#095540",
    danger = "#BF616A",
    light = "#272c30",
    success = "#13906d"
  )
)



ui <- dashboardPage(
  freshTheme = theme,
  dashboardHeader(

    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "customization.css")),
    tags$li(style = "padding: 10px; list-style:none;",div(class = 'language-selector',selectInput('selected_language',"Idioma", choices = i18n$get_languages(),selected = i18n$get_key_translation()))),
    title = tags$a(href='https://www.uned.es/', target ="_blank", class = "logocontainer", tags$img(src='LogoUNED.svg',height='56',width='', class = "logoimg"))
  ),
  
  
  dashboardSidebar(
    
    sidebarMenu(
        id = "sidebar-principal",
        div(id="incio-page", class = "nav-item incio-page", menuItem("Inicio", href = route_link("/"), icon = icon("home"), newTab = FALSE)),
        div(id="user-page", class = "nav-item user-page" , menuItem("User", href = route_link("user_home"), icon = icon("house-user"), newTab = FALSE)),
        div(id="import-page", class = "nav-item import-page", menuItem("Import", href = route_link("import"), icon = icon("file-arrow-up"), newTab = FALSE)),
        div(id="excel-page", class = "nav-item excel-page submenu-item", menuItem("Files", href = route_link("excel"), icon = icon("file-excel"), newTab = FALSE)),
        div(id="form-page", class = "nav-item excel-page submenu-item", menuItem("Form", href = route_link("excel"), icon = icon("rectangle-list"), newTab = FALSE)),
        div(id="repgrid-page", class = "nav-item excel-page", menuItem("Repgrid", href = route_link("repgrid"), icon = icon("magnifying-glass-chart"), newTab = FALSE)),
        div(id = "wimpgrid-page", class = "nav-item excel-page", menuItem("Wimpgrid", href = route_link("wimpgrid"), icon = icon("chart-column"), newTab = FALSE))
      )
    ),
      
  dashboardBody(
    #usei18n(translator = i18n),
    tags$script(src = "activescript.js"),
    useShinyjs(),
    router_ui(
      default = route(path = "/home",
                      ui = home_page),
      route(path = "/",
            ui = inicio_ui),
      route(path = "another",
            ui = another_page),
      route(path = "user_home",
            ui = user_home_ui),
      route(path = "import",
            ui = import_ui),
      route(path = "excel",
            ui = import_excel_ui),
      route(path = "repgrid",
            ui = repgrid_ui),
      route(path = "wimpgrid",
            ui = wimpgrid_analysis_ui),
      page_404 = page404(shiny::tags$div(
        h1("Error 404", class = "pagetitlecustom"),
        img(
          src = 'LogoUNED_error404.svg',
          height = '300',
          width = '',
          class = "logoimg404"
        ),
        h3("Página no encontrada.", class = "pagesubtitlecustom", status = 'danger'),
        column(
          12,
          class = "d-flex mb-4 justify-content-center",
          actionButton(
            "volver_a_inicio",
            "Volver a Inicio",
            status = 'danger',
            icon = icon("arrow-left"),
            class = "mt-3"
          )
        )
      ))
    )
  ),
)

server <- function(input, output, session) {
  observeEvent(input$volver_a_inicio, {
    runjs("window.location.href = '/#!/';")
  })

  observeEvent(input$selected_language, {
    # This print is just for demonstration
    print(paste("Language change!", input$selected_language))
    # Here is where we update language in session
    shiny.i18n::update_lang(input$selected_language)
    #i18n$set_translation_language(shiny::getDefaultReactiveDomain()input$selected_language)

  })

  router_server()

  home_server(input, output, session)
  inicio_server(input, output, session)
  another_server(input, output, session)
  userHome_server(input, output, session)
  import_server(input, output, session)
  import_excel_server(input, output, session)
  repgrid_server(input, output, session)
  repgrid_home_server(input, output, session)
  repgrid_analisis_server(input, output, session)
  wimpgrid_analysis_server(input, output, session)
}





shinyApp(ui, server)
