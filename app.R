library(shiny)
library(shinyjs)
library(shiny.router)
library(shinydashboard)
library(OpenRepGrid)
library(toastui)
library(DT)


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

menu <- tags$ul(
  tags$li(a(class = "item", href = route_link(""), "Inicio")),
  tags$li(a(class = "item", href = route_link("user_home"), "User")),
  tags$li(a(class = "item", href = route_link("import"), "Import")),
  tags$li(a(class = "item", href = route_link("excel"), "Import excel")),
  tags$li(a(class = "item", href = route_link("repgrid"), "Repgrid home"))
)


ui <- dashboardPage(

  # menu,
  
  dashboardHeader(title = "Mi aplicación"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Inicio", tabName = "inicio", icon = icon("home")),
      menu
    )
  ),
  dashboardBody(
    useShinyjs(),
    # router_ui(router),
    router_ui(
      route("/home", home_page),
      route("/", inicio_ui),
      route("another", another_page),
      route("user_home", user_home_ui), # Página user.home
      route("import", import_ui),
      route("excel", import_excel_ui),
      route("repgrid", repgrid_home_ui)
    )
  ),
  
)

server <- function(input, output, session) {
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
