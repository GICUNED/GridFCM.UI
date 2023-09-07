options(shiny.autoreload = TRUE)
library(shiny)
library(shinyjs)
library(shinyWidgets)
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
library(visNetwork)
library(dplyr)
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
source("R/visnetworks.R")


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
source("UI/form_repgrid_ui.R")
source("UI/form_wimpgrid_ui.R")
source("UI/patient_ui.R")

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
source("Servers/form_repgrid_server.R")
source("Servers/form_wimpgrid_server.R")
source("Servers/patient_server.R")

#DB
source("DB/establish_con.R")
source("DB/gestion_excel.R")


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
    success = "#13906d",
    warning = "#cb9b0b",
    info = "#90214a"
  )
)

ui <- dashboardPage(
  freshTheme = theme,
  dashboardHeader(

    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "customization.css"), tags$link(rel = "icon", type = "image/x-icon", href = "www/favicon.png"), tags$title("UNED | GridFCM")),
    title = tags$a(href='https://www.uned.es/', target ="_blank", class = "logocontainer",
    tags$img(height='56.9',width='', class = "logoimg")),
    div(id="user-page", class = "nav-item user-page user-page-btn" , menuItem("User", href = route_link("user_home"), icon = icon("house-user"), newTab = FALSE)),
    div(id="patientIndicator", class = "ml-auto patient-active-label", span(class = "icon-paciente"), htmlOutput("paciente_activo"))
  ),
  

  dashboardSidebar(

    sidebarMenu(
        id = "sidebar-principal",
        div(id="incio-page", class = "nav-item incio-page", menuItem(i18n$t("Inicio"), href = route_link("/"), icon = icon("home"), newTab = FALSE)),
         div(id="patient-page", class = "nav-item patient-page", menuItem(i18n$t("Pacientes"), href = route_link("patient"), icon = icon("users"), newTab = FALSE)),
        div(id="import-page", class = "nav-item import-page", menuItem(i18n$t("Importar"), href = route_link("import"), icon = icon("file-arrow-up"), newTab = FALSE)),
        div(id="excel-page", class = "nav-item excel-page submenu-item", menuItem(i18n$t("Ficheros"), href = route_link("excel"), icon = icon("file-excel"), newTab = FALSE)),
        div(id="form-page", class = "nav-item form-page submenu-item", menuItem(i18n$t("Formularios"), href = route_link("form"), icon = icon("rectangle-list"), newTab = FALSE)),
        div(id="repgrid-page", class = "nav-item repg-page", menuItem("RepGrid", href = route_link("repgrid"), icon = icon("magnifying-glass-chart"), newTab = FALSE)),
        div(id = "wimpgrid-page", class = "nav-item wimpg-page", menuItem("WimpGrid", href = route_link("wimpgrid"), icon = icon("border-none"), newTab = FALSE)),
        #div(class = 'language-selector',selectInput('selected_language',i18n$t("Idioma"), choices = i18n$get_languages(),selected = i18n$get_translation_language())),
        div(class = 'language-selector',radioGroupButtons('selected_language',i18n$t("Idioma"), choices = i18n$get_languages(), selected = i18n$get_translation_language(), width='100%', checkIcon = list()))
      )
    ),



  dashboardBody(
    usei18n(translator = i18n),
    tags$script(src = "activescript.js"),
    useShinyjs(),
    router_ui(
      default = route(path = "/home",
                      ui = home_page),
      route(path = "/",
            ui = inicio_ui),
      route(path = "user_home",
            ui = user_home_ui),
      route(path = "import",
            ui = import_ui),
      route(path = "patient",
            ui = patient_ui),
      route(path = "excel",
            ui = import_excel_ui),
      route(path = "form",
            ui = form_repgrid_ui), # de momento repgrid, luego poder seleccionar que form hacer
      route(path = "repgrid",
            ui = repgrid_ui),
      route(path = "wimpgrid",
            ui = wimpgrid_analysis_ui),
      page_404 = page404(shiny::tags$div(
        h1("Error 404", class = "pagetitlecustom"),
        h3("Página no encontrada.", class = "pagesubtitlecustom", status = 'danger'),
        img(
          src = 'LogoUNED_error404.svg',
          height = '300',
          width = '',
          class = "logoimg404"
        ),

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

  i18n_r <- reactive({
    i18n
  })

  observeEvent(input$volver_a_inicio, {
    runjs("window.location.href = '/#!/';")
  })

  observeEvent(input$selected_language, {
    shiny.i18n::update_lang(input$selected_language)
    i18n_r()$set_translation_language(input$selected_language)

    updateSelectInput(session, "graph_selector_visualizacion",
                      choices = i18n_r()$t(c("autodigrafo", "digrafo del ideal", "índices de Wimp")))



    updateSelectInput(session, "selfdigraph_layout",
                      choices = i18n_r()$t(c("circulo", "rtcirculo","arbol", "graphopt", "mds", "cuadricula")))
    updateSelectInput(session, "selfdigraph_color",
                      choices = i18n_r()$t(c("rojo/verde", "escala de grises")))

    updateSelectInput(session, "idealdigraph_layout",
                      choices = i18n_r()$t(c("circulo", "rtcirculo","arbol", "graphopt", "mds", "cuadricula")))
    updateSelectInput(session, "idealdigraph_color",
                      choices = i18n_r()$t(c("rojo/verde", "escala de grises")))



    updateSelectInput(session, "graph_selector_laboratorio",
                      choices = i18n_r()$t(c("simdigrafo","pcsd", "pcsdindices")))

    updateSelectInput(session, "simdigraph_layout",
                      choices = i18n_r()$t(c("circulo", "rtcirculo","arbol", "graphopt", "mds", "cuadricula")))
    updateSelectInput(session, "simdigraph_color",
                      choices = i18n_r()$t(c("rojo/verde", "escala de grises")))


    updateSelectInput(session, "simdigraph_infer",
                      choices = i18n_r()$t(c("transformacion lineal", "otra opción")))
    updateSelectInput(session, "simdigraph_thr",
                      choices = i18n_r()$t(c("lineal","otra opción")))


    updateSelectInput(session, "pcsd_infer",
                      choices = i18n_r()$t(c("transformacion lineal", "otra opción")))
    updateSelectInput(session, "pcsd_thr",
                      choices = i18n_r()$t(c("lineal", "otra opción")))


    updateSelectInput(session, "pcsdindices_infer",
                      choices = i18n_r()$t(c("transformacion lineal", "transformación sigmoidea", "transformación binaria")))
    updateSelectInput(session, "pcsdindices_thr",
                      choices = i18n_r()$t(c("lineal", "sigmoide", "binario")))

    updateSelectInput(session, "graph_selector",
                      choices = i18n_r()$t(c("Análisis Bidimensional",
                              "Análisis Tridimensional","Análisis por Conglomerados","Índices Cognitivos","Dilemas")))
  })


  router_server()

  home_server(input, output, session)
  inicio_server(input, output, session)
  another_server(input, output, session)
  userHome_server(input, output, session)
  import_server(input, output, session)
  #import_excel_server(input, output, session)
  form_repgrid_server(input, output, session)
  patient_server(input, output, session)
  #form wimp
  repgrid_server(input, output, session)
  repgrid_home_server(input, output, session)
  repgrid_analisis_server(input, output, session)
  wimpgrid_analysis_server(input, output, session)
}





shinyApp(ui, server)
