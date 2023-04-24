library(shiny)
library(shinyjs)
library(shiny.router)
<<<<<<< HEAD
library(shinydashboard)
library(OpenRepGrid)
library(toastui)
library(DT)

=======
library(bs4Dash)
library(fresh)
>>>>>>> design

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
# SERVERS
source("Servers/home_page_server_observers.R")
source("Servers/another_page_server_observers.R")
source("Servers/userHome_page_server.R")
source("Servers/inicio_page_servers.R")
source("Servers/import_servers.R")
source("Servers/import_excel_servers.R")
source("Servers/repgrid_home_servers.R")

<<<<<<< HEAD
menu <- tags$ul(
  tags$li(a(class = "item", href = route_link(""), "Inicio")),
  tags$li(a(class = "item", href = route_link("user_home"), "User")),
  tags$li(a(class = "item", href = route_link("import"), "Import")),
  tags$li(a(class = "item", href = route_link("excel"), "Import excel")),
  tags$li(a(class = "item", href = route_link("repgrid"), "Repgrid home"))
=======
theme <- create_theme(
  bs4dash_status(
    primary = "#095540", danger = "#BF616A", light = "#272c30", success = "#13906d"
  )
>>>>>>> design
)

ui <- dashboardPage(

  freshTheme = theme,
  # menu,
  dashboardHeader(

    tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "customization.css"),

    ),
  title = tags$a(href='https://www.uned.es/', target ="_blank", class = "logocontainer", tags$img(src='LogoUNED.svg',height='56',width='', class = "logoimg"))),
  dashboardSidebar(
    
    sidebarMenu(
      id = "sidebar-principal",
      div(id="incio-page", class = "nav-item incio-page", menuItem("Inicio", href = route_link("/"), icon = icon("home"), newTab = FALSE)),
      div(id="user-page", class = "nav-item user-page" , menuItem("User", href = route_link("user_home"), icon = icon("house-user"), newTab = FALSE)),
      div(id="import-page", class = "nav-item import-page", menuItem("Import", href = route_link("import"), icon = icon("file-arrow-up"), newTab = FALSE)),
      div(id="excel-page", class = "nav-item excel-page", menuItem("Import Excel", href = route_link("excel"), icon = icon("file-excel"), newTab = FALSE))
      
    )
  ),
  dashboardBody(

    # Clase active de selección para la navegación de páginas
    tags$script(src = "activescript.js"),

    # router_ui(router),
    useShinyjs(),
    router_ui(
      route("/home", home_page),
      route("/", inicio_ui),
      route("another", another_page),
      route("user_home", user_home_ui), # Página user.home
      route("import", import_ui),
      route("excel", import_excel_ui),
<<<<<<< HEAD
      route("repgrid", repgrid_home_ui)
=======
      page_404 = page404(shiny::tags$div(h1("Error 404",class = "pagetitlecustom"),img(src='LogoUNED_error404.svg',height='300',width='', class = "logoimg404"), h3("Página no encontrada.", class = "pagesubtitlecustom",status = 'danger'), column(12, class="d-flex mb-4 justify-content-center", actionButton("volver_a_inicio", "Volver a Inicio", status = 'danger', icon = icon("arrow-left"), class = "mt-3"))))
>>>>>>> design
    )
  )
)
server <- function(input, output, session) {

   observeEvent(input$volver_a_inicio, {
    runjs("window.location.href = '/#!/';")
  })
  
  router_server()

  home_server(input, output, session)
  inicio_server(input, output, session)
  another_server(input, output, session)
  userHome_server(input, output, session)
  import_server(input, output, session)
  import_excel_server(input,output,session)
  repgrid_home_server(input,output,session)
}


shinyApp(ui, server)
