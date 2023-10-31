options(shiny.autoreload = TRUE)
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinydashboard)
library(slickR)
library(shinybusy)
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
library(glue)
library(httr)
library(cookies)
knitr::knit_hooks$set(webgl = hook_webgl)



source("global.R")
# GRID
source("R/GraphFunctions.R")
source("R/HideFunctions.R")
source("R/ImportFunctions.R")
source("R/IndicesSummary.R")
source("R/PCSDindicesFunctions.R")
source("R/SimulationFunctions.R")
source("R/WimpIndicesFunctions.R")
source("R/visnetworks.R")

# UIsource("UI/userHome_ui.R")
source("UI/inicio_page_ui.R")
source("UI/import_ui.R")
source("UI/import_excel_ui.R")
source("UI/repgrid_home_ui.R")
source("UI/repgrid_analysis_ui.R")
source("UI/repgrid_ui.R")
source("UI/wimpgrid_analysis_ui.R")
source("UI/form_ui.R")
source("UI/patient_ui.R")
source("UI/suggestion_ui.R")
# SERVERS
source("Servers/userHome_page_server.R")
source("Servers/inicio_page_servers.R")
source("Servers/import_servers.R")
source("Servers/import_excel_servers.R")
source("Servers/repgrid_home_servers.R")
source("Servers/repgrid_analysis_server.R")
source("Servers/repgrid_server.R")
source("Servers/wimpgrid_analysis_server.R")
source("Servers/form_server.R")
source("Servers/patient_server.R")
source("Servers/suggestion_server.R")


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
  class = "item", href = route_link("patient"), "Patient"
)),
tags$li(a(
  class = "item", href = route_link("import"), "Import"
)),
tags$li(a(
  class = "item", href = route_link("excel"), "Import excel"
)),
tags$li(a(
  class = "item", href = route_link("form"), "Form"
)),
tags$li(a(
  class = "item", href = route_link("suggestion"), "Suggestion"
)),
tags$li(a(
  class = "item", href = route_link("repgrid"), "Repgrid home"
)),
tags$li(a(
  class = "item", href = route_link("wimpgrid"), "Wimpgrid analysis"
)))

theme <- create_theme(
  bs4dash_status(
    primary = "#095540",
    danger = "#BF616A",
    secondary = "#272c30",
    success = "#13906d",
    warning = "#cb9b0b",
    info = "#90214a"
  )
)

httr::set_config(config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
ruta_app <- "https://gridfcm.localhost/"
keycloak_client_id <- "gridfcm"
keycloak_client_secret <- Sys.getenv("KEYCLOAK_CLIENT_SECRET")
token_url <- "https://gridfcm.localhost/keycloak/realms/Gridfcm/protocol/openid-connect/token"
info_url <- "https://gridfcm.localhost/keycloak/realms/Gridfcm/protocol/openid-connect/userinfo"
logout_url <- "https://gridfcm.localhost/keycloak/realms/Gridfcm/protocol/openid-connect/logout"

has_auth_code <- function(params) {
  return(!is.null(params$code))
}

make_authorization_url <- function() {
  url_template <- "http://gridfcm.localhost/keycloak/realms/Gridfcm/protocol/openid-connect/auth?client_id=%s&redirect_uri=%s&response_type=code&scope=%s"
  sprintf(url_template,
    utils::URLencode(keycloak_client_id, reserved = TRUE, repeated = TRUE),
    utils::URLencode(ruta_app, reserved = TRUE, repeated = TRUE),
    utils::URLencode("openid roles", reserved = TRUE, repeated = TRUE)
  )
}

link <- make_authorization_url()

ui <- add_cookie_handlers(
  dashboardPage(
    title = "PsychLab UNED | GridFCM",
    freshTheme = theme,
    dashboardHeader(
      tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "customization.css")),
      tags$head(tags$link(rel = "icon", type = "image/x-icon", href = 'favicon.png')),
      title = tags$a(href='https://www.uned.es/', target ="_blank", class = "logocontainer",
      tags$img(height='56.9',width='', class = "logoimg")),
      div(id="user-page", class = "nav-item user-page user-page-btn" , menuItem(textOutput("user_name"), href = link, icon = icon("house-user"), newTab = FALSE)),
      div(id="patientIndicator", class = "ml-auto patient-active-label", span(class = "icon-paciente"), htmlOutput("paciente_activo"))
    ),

    dashboardSidebar(
      sidebarMenu(
          id = "sidebar_principal",
          div(id="incio-page", class = "nav-item incio-page", menuItem(i18n$t("Inicio"), href = route_link("/"), icon = icon("home"), newTab = FALSE)),
          div(id="patient-page", class = "nav-item patient-page hidden-div", menuItem(i18n$t("Pacientes"), href = route_link("patient"), icon = icon("users"), newTab = FALSE)),
          div(id="import-page", class = "nav-item import-page", menuItem(i18n$t("Importar"), href = route_link("import"), icon = icon("file-arrow-up"), newTab = FALSE)),
          div(id="excel-page", class = "nav-item excel-page submenu-item", menuItem(i18n$t("Ficheros"), href = route_link("excel"), icon = icon("file-excel"), newTab = FALSE)),
          div(id="form-page", class = "nav-item form-page submenu-item", menuItem(i18n$t("Formularios"), href = route_link("form"), icon = icon("rectangle-list"), newTab = FALSE)),
          div(id="repgrid-page", class = "nav-item repg-page hidden-div", menuItem("RepGrid", href = route_link("repgrid"), icon = icon("magnifying-glass-chart"), newTab = FALSE)),
          div(id = "wimpgrid-page", class = "nav-item wimpg-page hidden-div", menuItem("WimpGrid", href = route_link("wimpgrid"), icon = icon("border-none"), newTab = FALSE)),
          div(id="suggestion-page", class = "nav-item suggestion-page hidden-div", menuItem(i18n$t("Sugerencias"), href = route_link("suggestion"), icon = icon("comments"), newTab = FALSE)),
          #div(class = 'language-selector',selectInput('selected_language',i18n$t("Idioma"), choices = i18n$get_languages(),selected = i18n$get_translation_language())),
          div(class = 'language-selector',radioGroupButtons('selected_language',i18n$t("Idioma"), choices = i18n$get_languages(), selected = i18n$get_translation_language(), width='100%', checkIcon = list())),
          actionButton('logout_btn',i18n$t("Cerrar sesión"), width='100%', status="danger", style="display: none;")
        )
      ),


    dashboardBody(
      usei18n(translator = i18n),
      tags$script(src = "activescript.js"),
      useShinyjs(),

      router_ui(
        default = 
        route(path = "/",
              ui = inicio_ui),
        route(path = "import",
              ui = import_ui),
        route(path = "patient",
              ui = patient_ui),
        route(path = "excel",
              ui = import_excel_ui),
        route(path = "form",
              ui = form_ui), 
        route(path = "repgrid",
              ui = repgrid_ui),
        route(path = "wimpgrid",
              ui = wimpgrid_analysis_ui),
        route(path = "suggestion",
              ui = suggestion_ui),

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
      ),

      add_busy_spinner(
        spin = "double-bounce",
        color = "#13906d",
        timeout = 100,
        position = "top-left",
        onstart = TRUE,
        margins = c(8, 10),
        height = "40px",
        width = "40px"
      )

      #add_busy_spinner(
        #spin = "fading-circle",
        #color = "#13906d",
        #timeout = 100,
        #position = "full-page",
        #onstart = TRUE,
        #margins = c(8, 10),
        #height = "50px",
        #width = "50px"
      #)

    )
  )
)

obtener_id_psicologo <- function(info){

}

gestionar_rol <- function(roles){
  # obtengo el maximo rol posible a nivel de funcionalidades
  usuario_ilimitado <- FALSE
  usuario_gratis <- FALSE
  for(i in roles){
    if(i == "usuario_ilimitado"){usuario_ilimitado <- TRUE}
    if(i == "usuario_gratis"){usuario_gratis <- TRUE}
  }
  if(usuario_gratis || usuario_ilimitado){
    shinyjs::show("suggestion-page")
    shinyjs::show("patient-page")
    shinyjs::show("repgrid-page")
    shinyjs::show("wimpgrid-page")
    shinyjs::hide("welcome_box")
    if(usuario_gratis && !usuario_ilimitado){
      return("usuario_gratis")
    }
    else{
      if(usuario_ilimitado){
        return("usuario_ilimitado")
      }
    }
  }
  else{
    return("default-roles-gridfcm")
  }
}

crear_usuario <- function(info){
  con <- establishDBConnection()
  info <- (httr::content(info, "text"))
  info <- jsonlite::fromJSON(info)
  name <- info$name
  rol <- gestionar_rol(info$roles)
  message("rol:", rol)
  if(is.null(name)){
    name <- "default"
  }
  mail <- info$email
  user <- info$preferred_username
  id <- as.integer(DBI::dbGetQuery(con, sprintf("SELECT id FROM psicologo WHERE email='%s'", mail)))
  if(is.na(id)){
    message("entro en insert ")
    query <- sprintf("INSERT INTO psicologo(nombre, username, email) VALUES ('%s', '%s', '%s')", name, user, mail)
    DBI::dbExecute(con, query)
    id <- as.integer(DBI::dbGetQuery(con, sprintf("SELECT id from psicologo where username='%s' and email='%s'", user, mail)))
  }
  DBI::dbDisconnect(con)

  return(id)
}


server <- function(input, output, session) {
  user_name <- reactiveVal(NULL)
  setear_cookie <- reactiveVal(NULL)
  psicologo <- reactiveVal(NULL)

  message("entro en server")
  params <- parseQueryString(isolate(session$clientData$url_search))

  observeEvent(get_cookie("token_cookie"), {
    message("obtengo la cookie:")
    token <- get_cookie("token_cookie")
    con <- establishDBConnection()
    usuario <- DBI::dbGetQuery(con, sprintf("SELECT nombre, id, token, refresh_token FROM psicologo WHERE token='%s'", token)) # de momento
    message(usuario$nombre, ", id: ", usuario$id)
    psicologo(usuario)
    DBI::dbDisconnect(con)
  })

  observe(
    if(!is.null(setear_cookie())){
      if(setear_cookie() == TRUE){
        set_cookie(
          cookie_name = "token_cookie",
          cookie_value = GLOBAL_TOKEN
        )
      }
      else{
        set_cookie(
          cookie_name = "token_cookie",
          cookie_value = NULL
        )
      }
    }
  )

  con <- establishDBConnection()
  if (is.null(psicologo())) {
    # limitar funciones
    if(!has_auth_code(params)){
      message("no ha iniciado sesion")
    }
    else{
      # token y refresh token del usuario
      message("entro en obtener tokens")
      code <- params$code
      params <- list(
        client_id = keycloak_client_id,
        client_secret = keycloak_client_secret,
        redirect_uri = ruta_app,
        code = code,
        grant_type = "authorization_code"
      )
      resp <- httr::POST(url = token_url, add_headers("Content-Type" = "application/x-www-form-urlencoded"), body = params, encode="form")
      respuesta <- (httr::content(resp, "text"))
      token_data <- jsonlite::fromJSON(respuesta)
      if(is.null(token_data$error)){
        # Acceder al access_token
        GLOBAL_TOKEN <- token_data$access_token
        setear_cookie(TRUE)
        GLOBAL_REFRESH_TOKEN <- token_data$refresh_token
        # info general del usuario
        resp_info <- httr::GET(url = info_url, add_headers("Authorization" = paste("Bearer", GLOBAL_TOKEN, sep = " ")))
        id <- crear_usuario(resp_info)
        session$userData$id_psicologo <- id

        query <- sprintf("UPDATE PSICOLOGO SET token = '%s' WHERE id=%d", GLOBAL_TOKEN, id) # de momento 1
        DBI::dbExecute(con, query)
        query2 <- sprintf("UPDATE PSICOLOGO SET refresh_token = '%s' WHERE id=%d", GLOBAL_REFRESH_TOKEN, id) # de momento 1
        DBI::dbExecute(con, query2)
        message("Token obtenido e insertado en la bd")

        
        shinyjs::show("logout_btn")
        #user_name(user$nombre)
      }
      else{
        message(token_data$error)
        user_name(NULL)
      }
    }
  }
  else{
    user <- psicologo()
    user_name(user$nombre)
    resp_info <- httr::GET(url = info_url, add_headers("Authorization" = paste("Bearer", user$token, sep = " ")))
    message("respuesta del get info user")
    message(resp_info)
    error <- httr::http_status(resp_info)
    texto <- paste(error, collapse = " ")
    palabras <- strsplit(texto, " ")[[1]]
    # Seleccionar la última palabra
    ultima_palabra <- palabras[length(palabras)]
    if(ultima_palabra != "OK"){
      message("caducado, intentando refrescar token")
      params <- list(
        client_id = keycloak_client_id,
        client_secret = keycloak_client_secret,
        redirect_uri = ruta_app,
        refresh_token = user$refresh_token,
        scope = "openid",
        grant_type = "refresh_token"
      )
      refresh_resp <- httr::POST(url = token_url, add_headers("Content-Type" = "application/x-www-form-urlencoded"), body = params, encode="form")
      refresh_respuesta <- (httr::content(refresh_resp, "text"))
      message("mensaje refresh token")
      message(refresh_respuesta)
      refresh_token_data <- jsonlite::fromJSON(refresh_respuesta, simplifyVector = FALSE)
      # Acceder al access_token
      if(!is.null(refresh_token_data$error)){
        message("Imposible refrescar el token")
        DBI::dbExecute(con, sprintf("update psicologo set token=NULL, refresh_token=NULL where id=%d", user$id)) # de momento 1
        setear_cookie(FALSE)
        shinyjs::hide("logout_btn")
        user_name(NULL)
        runjs("window.location.href = '/#!/';")
        session$reload()
      }
      else{
        r <- refresh_token_data$access_token
        DBI::dbExecute(con, sprintf("update psicologo set token='%s' where id=%d", r, user$id))
        message("token actualizado")
        shinyjs::show("logout_btn")
      }
      
    }
    if(ultima_palabra == "OK"){
      message("token válido....")
      shinyjs::show("logout_btn")
      # token válido, gestionar permisos?
      info <- (httr::content(resp_info, "text"))
      info <- jsonlite::fromJSON(info)
      rol <- gestionar_rol(info$roles)
      session$userData$rol <- rol
      message("rol> ", rol)
      DBI::dbExecute(con, sprintf("update psicologo set rol='%s' where id=%d", rol, user$id)) # de momento 1
    }
  }
  DBI::dbDisconnect(con)

  shinyjs::onclick("logout_btn", {
    user <- psicologo()
    con <- establishDBConnection()
    token <- DBI::dbGetQuery(con, sprintf("SELECT token FROM psicologo WHERE id=%d", user$id)) # de momento 1
    refresh_token <- DBI::dbGetQuery(con, sprintf("SELECT refresh_token FROM psicologo WHERE id=%d", user$id)) # de momento 1
    params <- list(
      client_id = keycloak_client_id, 
      refresh_token = refresh_token,
      client_secret = keycloak_client_secret,
      redirect_uri = ruta_app
    )
    setear_cookie(FALSE)
    resp <- httr::POST(url = logout_url, add_headers("Content-Type" = "application/x-www-form-urlencoded", "Authorization" = paste("Bearer", token, sep = " ")), 
                      body = params, encode="form")
    message(resp)
    DBI::dbExecute(con, sprintf("update psicologo set token=NULL, refresh_token=NULL where id=%d", user$id)) # de momento 1
    user_name(NULL)
    runjs("window.location.href = '/#!/';")
    session$reload()
    DBI::dbDisconnect(con)
  })

  observe(
    if(is.null(user_name())){
      output$user_name <- renderText(i18n$t("Log in"))
    }
    else{
      output$user_name <- renderText(user_name())
    }
  )

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
  inicio_server(input, output, session)
  userHome_server(input, output, session)
  import_server(input, output, session)
  #import_excel_server(input, output, session)
  form_server(input, output, session)
  patient_server(input, output, session)
  repgrid_server(input, output, session)
  repgrid_home_server(input, output, session)
  repgrid_analisis_server(input, output, session)
  wimpgrid_analysis_server(input, output, session)
  suggestion_server(input, output, session)
}

shinyApp(ui, server)

