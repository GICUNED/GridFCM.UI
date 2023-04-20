library(shiny)
library(shinyjs)
library(shiny.router)
library(bs4Dash)

source("global.R")
# UI
source("UI/home_page_ui.R")
source("UI/another_page_ui.R")
source("UI/userHome_ui.R")
source("UI/inicio_page_ui.R")
source("UI/import_ui.R")
source("UI/import_excel_ui.R")
# SERVERS
source("Servers/home_page_server_observers.R")
source("Servers/another_page_server_observers.R")
source("Servers/userHome_page_server.R")
source("Servers/inicio_page_servers.R")
source("Servers/import_servers.R")
source("Servers/import_excel_servers.R")

ui <- dashboardPage(
  skin = "black",
  # menu,
  dashboardHeader(
    tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "customization.css"),
  ),
  title = "GridFCM"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Inicio", href = route_link("/"), icon = icon("home"), newTab = FALSE),
      menuItem("User",  href = route_link("user_home"), icon = icon("house-user"), newTab = FALSE),
      menuItem("Import",  href = route_link("import"), icon = icon("file-arrow-up"), newTab = FALSE),
      menuItem("Import Excel",  href = route_link("excel"), icon = icon("file-excel"), newTab = FALSE)
    )
  ),
  dashboardBody(
    # router_ui(router),
    useShinyjs(),
    router_ui(
      route("/home", home_page),
      route("/", inicio_ui),
      route("another", another_page),
      route("user_home", user_home_ui), #Página user.home
      route("import", import_ui),
      route("excel", import_excel_ui)
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
}




shinyApp(ui, server)
