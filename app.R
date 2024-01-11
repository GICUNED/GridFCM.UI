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
# GRID1
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
source("UI/user_page_ui.R")
source("UI/plan_subscription_ui.R")
source("UI/success_payment_ui.R")
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
source("Servers/user_page_server.R")
source("Servers/plan_subscription_server.R")
source("Servers/success_payment_server.R")




#DB
source("DB/establish_con.R")
source("DB/gestion_excel.R")
# source("DB/sync_stripe_db_process_light.R")




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
)),
tags$li(a(
  class = "item", href = route_link("plan"), "Planes"
)),
tags$li(a(
  class = "item", href = route_link("payment"), "Pagos"
)),

)


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
domain <- Sys.getenv("DOMAIN")
# message("domain")
# message(domain)
ruta_app <- sprintf("https://%s/", domain)
keycloak_client_id <- "gridfcm"
keycloak_client_secret <- Sys.getenv("KEYCLOAK_CLIENT_SECRET")
# message("keycloak client secret")
# message(keycloak_client_secret)
# Replace "gridfcm.localhost" with "domain" in all URLs
token_url <- sprintf("https://%s/keycloak/realms/Gridfcm/protocol/openid-connect/token", domain)
info_url <- sprintf("https://%s/keycloak/realms/Gridfcm/protocol/openid-connect/userinfo", domain)
logout_url <- sprintf("https://%s/keycloak/realms/Gridfcm/protocol/openid-connect/logout", domain)


has_auth_code <- function(params) {
  return(!is.null(params$code))
}

# make_authorization_url <- function() {
#   url_template <- "http://%s/keycloak/realms/Gridfcm/protocol/openid-connect/auth?client_id=%s&redirect_uri=%s&response_type=code&scope=%s"
#   sprintf(url_template,
#     domain,
#     utils::URLencode(keycloak_client_id, reserved = TRUE, repeated = TRUE),
#     utils::URLencode(ruta_app, reserved = TRUE, repeated = TRUE),
#     utils::URLencode("openid roles", reserved = TRUE, repeated = TRUE)
#   )
# }

# link <- make_authorization_url()
ui <- add_cookie_handlers(
  dashboardPage(
    title = "PsychLab UNED | GridFCM",
    freshTheme = theme,
    dashboardHeader(
      tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "customization.css")),
      tags$head(tags$link(rel = "icon", type = "image/x-icon", href = 'favicon.png')),
      tags$script(src="https://www.googletagmanager.com/gtag/js?id=G-Y4YW79BBD3"),
      tags$script(src="gtagconnector.js"),
  
      title = tags$a(href='https://www.uned.es/', target ="_blank", class = "logocontainer",
      tags$img(height='56.9',width='', class = "logoimg")),
      div( class ="ml-auto nav-functions-container",
        div(id="patientIndicator", class = "patient-active-label", span(class = "icon-paciente"), htmlOutput("paciente_activo")),
        actionButton("invitado", i18n$t("Sesión de invitado"), icon = icon("user")),
        uiOutput("user_div")
        # div(id="profile", class = "nav-item user-page user-page-btn" , menuItem(textOutput("user_name"), href = route_link("user"), icon = icon("house-user"), newTab = FALSE)),
      )
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
          div(id="plan-page", class = "nav-item plan-page hidden-div", menuItem(i18n$t("Gestión de Suscripción"), href = route_link("plan"), icon = icon("address-card"), newTab = FALSE)),
          #div(class = 'language-selector',selectInput('selected_language',i18n$t("Idioma"), choices = i18n$get_languages(),selected = i18n$get_translation_language())),
          div(class = 'language-selector',radioGroupButtons('selected_language',i18n$t("Idioma"), choices = i18n$get_languages(), selected = i18n$get_translation_language(), width='100%', checkIcon = list())),
          
          actionButton('logout_btn',i18n$t("Cerrar sesión"), icon = icon("right-from-bracket"), status="danger", class="logout-btn", style="display: none;")
        )
      ),


    dashboardBody(
      usei18n(translator = i18n),
      tags$script(async="true", src = "activescript.js"),

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
        route(path = "user",
              ui = user_page_ui),
        route(path = "plan",
              ui = plan_subscription_ui),
        route(path = "payment",
              ui = success_payment_ui),

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
        spin = "hollow-dots",
        color = "#72af9e",
        timeout = 10,
        position = "top-left",
        onstart = TRUE,
        margins = c(10, 10),
      ),

       tags$footer(class="footer-psychlabuned", 
       
         div(class= "financing-info flex-container-mini",
            strong(i18n$t("Financiado por")),
            div(class="financingimg"),
            p(i18n$t("Convocatoria de ayudas a la investigación 2022, Ignacio H. de Larramendi"))
          )
      )
    )
  )
)


gestionar_rol <- function(roles){
  # obtengo el maximo rol posible a nivel de funcionalidades
  usuario_ilimitado <- FALSE
  usuario_gratis <- FALSE
  usuario_admin <- FALSE
  usuario_coordinador_organizacion <- FALSE
  for(i in roles){
    if(i == "usuario_ilimitado"){usuario_ilimitado <- TRUE}
    if(i == "usuario_gratis"){usuario_gratis <- TRUE}
    if(i == "usuario_administrador"){usuario_admin <- TRUE}
    if(i == "usuario_coordinador_organizacion"){usuario_coordinador_organizacion <- TRUE}
  }
  if(usuario_gratis || usuario_ilimitado || usuario_admin || usuario_coordinador_organizacion){
    shinyjs::show("suggestion-page")
    shinyjs::show("patient-page")
    shinyjs::show("repgrid-page")
    shinyjs::show("wimpgrid-page")
    
    # si el usuario es ilimitado se la ocultamos
    if(usuario_ilimitado){
      shinyjs::hide("plan-page")
    }else{
      shinyjs::show("plan-page")
    }

    shinyjs::hide("welcome_box")
    if (usuario_admin) {
      return("usuario_administrador")
    } else if (usuario_gratis && !usuario_ilimitado && !usuario_coordinador_organizacion) {
      return("usuario_gratis")
    } else if (usuario_ilimitado && !usuario_coordinador_organizacion) {
      return("usuario_ilimitado")
    }else if(usuario_coordinador_organizacion) {
      return("usuario_coordinador_organizacion")
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
  nuevo <- FALSE
  message("rol:", rol)
  if(is.null(name)){
    name <- "default"
  }
  mail <- info$email
  user <- info$preferred_username
  id <- as.integer(DBI::dbGetQuery(con, sprintf("SELECT id FROM psicologo WHERE email='%s'", mail)))
  if(is.na(id)){
    # si entro aquí es la primera vez que inicia sesión y se mete en postgre
    nuevo <- TRUE
    message("entro en insert ")
    query <- sprintf("INSERT INTO psicologo(nombre, username, email) VALUES ('%s', '%s', '%s')", name, user, mail)
    DBI::dbExecute(con, query)
    id <- as.integer(DBI::dbGetQuery(con, sprintf("SELECT id from psicologo where username='%s' and email='%s'", user, mail)))
  }
  DBI::dbDisconnect(con)

  return(list(id=id, nuevo=nuevo))
}




obtener_token <- function(params){
  code <- params$code
  message("code")
  message(code)
  params <- list(
    client_id = keycloak_client_id,
    client_secret = keycloak_client_secret,
    redirect_uri = ruta_app,
    code = code,
    grant_type = "authorization_code"
  )
  message(add_headers("Content-Type" = "application/x-www-form-urlencoded"))
  resp <- httr::POST(url = token_url, add_headers("Content-Type" = "application/x-www-form-urlencoded"), body = params, encode="form")
  respuesta <- (httr::content(resp, "text"))
  token_data <- jsonlite::fromJSON(respuesta)
  return(token_data)
}


obtener_token_refrescado <- function(refresh){
  params <- list(
    client_id = keycloak_client_id,
    client_secret = keycloak_client_secret,
    redirect_uri = ruta_app,
    refresh_token = refresh,
    scope = "openid",
    grant_type = "refresh_token"
  )
  refresh_resp <- httr::POST(url = token_url, add_headers("Content-Type" = "application/x-www-form-urlencoded"), body = params, encode="form")
  refresh_respuesta <- (httr::content(refresh_resp, "text"))
  return(refresh_respuesta)
}

server <- function(input, output, session) {
  user_name <- reactiveVal(NULL)
  psicologo <- reactiveVal(NULL)

  shinyjs::hide("patientIndicator")


  message("entro en server")
  params <- parseQueryString(isolate(session$clientData$url_search))

  observeEvent(get_cookie("token_cookie"), {
    message("obtengo la cookie:")
    token <- get_cookie("token_cookie")
    if(token != "null"){
      con <- establishDBConnection()
      usuario <- DBI::dbGetQuery(con, sprintf("SELECT nombre, id, token, refresh_token FROM psicologo WHERE token='%s'", token)) # de momento
      message(usuario$nombre, ", id: ", usuario$id)
      psicologo(usuario)
      DBI::dbDisconnect(con)
    }
    else{
      psicologo(NULL)
    }
  })

  modal_colectivo <- function(){
    showModal(modalDialog(
      box(width = 12,
        icon=icon("face-smile-wink"),
        collapsible=FALSE,
        title = i18n$t("¡Bienvenido/a a PsychLab! Completa tu registro."),
        p(class="mb-1", i18n$t("Selecciona el colectivo al que pertenece")),
        radioButtons("col", "",
                    choices = c("Investigador", "Profesional", "Alumno", "Institución", "Otro")),
        
        conditionalPanel(
          condition = "input.col == 'Investigador'",
          textInput("especificar_investigador", i18n$t("Especificar Investigador"))
        ),
        conditionalPanel(
          condition = "input.col == 'Profesional'",
          textInput("especificar_profesional", i18n$t("Especificar Profesional"))
        ),
        conditionalPanel(
          condition = "input.col == 'Otro'",
          textInput("especificar_otro", i18n$t("Especificar Otro"))
        )
      ),
      footer = tagList(
        actionButton("confirmar_colectivo", i18n$t("Confirmar"), status="success")
      )
    ))
  }

  shinyjs::onclick("confirmar_colectivo", {
    removeModal()
    con <- establishDBConnection()
    user <- psicologo()
    separador <- ": "
    if(!is.null(user) && length(user$id) != 0) {
      colectivo_seleccionado <- input$col
      especificar_valor <- switch(
        colectivo_seleccionado,
        "Investigador" = input$especificar_investigador,
        "Profesional" =  input$especificar_profesional,
        "Otro" = input$especificar_otro,
        ""
      )
      if(especificar_valor == ""){
        separador <- ""
      }
      query <- sprintf("UPDATE PSICOLOGO SET colectivo='%s' WHERE id=%d", paste0(colectivo_seleccionado, separador, especificar_valor), user$id)
      DBI::dbExecute(con, query)
    }
    DBI::dbDisconnect(con)
  })

observeEvent(input$invitado, {
    showModal(modalDialog(
          title = i18n$t("Acceso modo invitado"),
          textInput("email_invitado", i18n$t("Introduzca su e-mail"), value=""),
          box(
            icon = icon("book"),
            width = 12,
            collapsed = TRUE,
            title = i18n$t("Aviso legal"),
            div(
              id = "aviso_legal",
              # Título
              h3(strong(
                "Aviso Legal - Uso del Correo Electrónico para Fines Comerciales"
              )),
              # Párrafo introductorio
              p(
                "Este Aviso Legal regula el uso de su dirección de correo electrónico proporcionada al acceder y utilizar la aplicación web (en adelante, 'la Aplicación') propiedad de UNED (en adelante, 'el Titular'). Por favor, lea atentamente este aviso antes de continuar utilizando la Aplicación."
              ),
              # Párrafos de contenido
              strong(
                "Consentimiento"
              ),
              p(
                "Al utilizar la Aplicación, usted acepta y consiente expresamente que su dirección de correo electrónico proporcionada será utilizada por el Titular con fines comerciales. Esto implica que el Titular podrá enviarle comunicaciones, información de productos, promociones y otras comunicaciones comerciales relacionadas con sus servicios y productos a la dirección de correo electrónico proporcionada."
              ),
              strong(
                "Obligación de Proporcionar el Correo Electrónico"
              ),
              p(
                "El Titular requiere que proporcione su dirección de correo electrónico como condición necesaria para acceder y utilizar la Aplicación. Sin la provisión de esta información, no se le permitirá acceder a la Aplicación."
              ),
              strong(
                "Derecho a Retirar el Consentimiento"
              ),
              p(
                "Usted tiene el derecho de retirar su consentimiento en cualquier momento. Puede hacerlo siguiendo las instrucciones proporcionadas en las comunicaciones comerciales que reciba o poniéndose en contacto con el Titular utilizando los datos de contacto proporcionados en la Aplicación."
              ),
              strong(
                "Uso Responsable del Correo Electrónico"
              ),
              p(
                "El Titular se compromete a utilizar su dirección de correo electrónico de acuerdo con la legislación vigente en materia de protección de datos y privacidad. Su dirección de correo electrónico no será compartida con terceros sin su consentimiento previo."
              ),
              strong(
                "Seguridad de Datos"
              ),
              p(
                "El Titular toma medidas de seguridad razonables para proteger la información proporcionada, incluyendo su dirección de correo electrónico. Sin embargo, no se puede garantizar la seguridad absoluta en la transmisión de datos por Internet. Usted reconoce y acepta que la transmisión de datos por Internet siempre conlleva riesgos."
              ),
              strong(
                "Modificaciones del Aviso Legal"
              ),
              p(
                "El Titular se reserva el derecho de modificar este Aviso Legal en cualquier momento. Las modificaciones entrarán en vigor inmediatamente después de su publicación en la Aplicación. Se le notificará cualquier cambio importante en la forma en que se utiliza su dirección de correo electrónico."
              ),
              strong(
                "Contacto"
              ),
              p(
                "Si tiene alguna pregunta o inquietud relacionada con este Aviso Legal o el uso de su dirección de correo electrónico, puede ponerse en contacto con el Titular a través de los datos de contacto proporcionados en la Aplicación o dejando un comentario en la página de sugerencias."
              ),
              # Párrafo final
              p(
                "Al proporcionar su dirección de correo electrónico y continuar utilizando la Aplicación, usted reconoce y acepta los términos y condiciones establecidos en este Aviso Legal."
              )
            )
          ),
          fade = TRUE,
          footer = tagList(
            modalButton("Cancelar"),
            actionButton("entrar_invitado", i18n$t("Aceptar condiciones"), status= "success", class = "btn-success")
          )
      ))
  })

  isValidEmail <- function(x) {
    grepl("\\<[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\>", as.character(x), ignore.case=TRUE)
  }
  
  observeEvent(input$entrar_invitado, {
    email <- input$email_invitado
    if(!isValidEmail(email)){
      updateTextInput(session, "email_invitado", value = "")
      showNotification(
        ui = sprintf("El email introducido (%s), no existe. Introduzca uno válido", email),
        type = "error",
        duration = 5
      ) 
    }
    else{
      removeModal()
      showNotification(
        ui = sprintf("Bienvenido a la PsychLab, %s", email),
        type = "message",
        duration = 5
      ) 
      shinyjs::hide("invitado")
      shinyjs::show("patient-page")
      shinyjs::show("repgrid-page")
      shinyjs::show("wimpgrid-page")
      con <- establishDBConnection()
      # meto el usuario demo en la tabla de usuarios demo para almacenar su email y enviar publi luego
      DBI::dbExecute(con, sprintf("INSERT INTO usuario_demo(email) VALUES('%s')", email))

      # pillo el psicologo/usuario de prueba para poder utilizar la aplicacion
      id <- DBI::dbGetQuery(con, "SELECT id, rol FROM psicologo WHERE email='prueba@uned.com';")
      session$userData$rol <- id$rol
      session$userData$id_psicologo <- as.integer(id$id)
      patient_server(input, output, session)
      DBI::dbDisconnect(con)
    }
  })

  observe({
    user <- psicologo()
    con <- establishDBConnection()
    # importante el or este por si inicia la misma sesion desde otro navegador o dispositivo
    if(is.null(user) || length(user$id) == 0) { 
      # limitar funciones
      if(!has_auth_code(params)){
        message("no ha iniciado sesion")
      }
      else{
        # token y refresh token del usuario
        message("entro en obtener tokens")
        token_data <- obtener_token(params)
        if(is.null(token_data$error)){
          message("entro sin error token")
          # Acceder al access_token
          GLOBAL_TOKEN <- token_data$access_token
          # session$global_token <- GLOBAL_TOKEN
          set_cookie(cookie_name = "token_cookie", cookie_value = GLOBAL_TOKEN)
          GLOBAL_REFRESH_TOKEN <- token_data$refresh_token
          # info general del usuario
          resp_info <- httr::GET(url = info_url, add_headers("Authorization" = paste("Bearer", GLOBAL_TOKEN, sep = " ")))
          creado <- crear_usuario(resp_info)
          id <- creado$id
          if(creado$nuevo){
            modal_colectivo()
          }
          info_for_email <- (httr::content(resp_info, "text"))
          info_for_email <- jsonlite::fromJSON(info_for_email)
          if(!is.null(info_for_email$email) && info_for_email$email!= ""){
            session$userData$email_user <- info_for_email$email
          }

          # llamar a la funcion de refrescar con stripe (si entra aqui, despues deberia entrar a ultima palabra no?) (quiza solo hay que meterla alli)
          ## asi podemos ver si el rol coincide con la suscripcion que se tenga
          ## y metemos el rol actualizado en la variable session
          
          session$userData$id_psicologo <- id
          patient_server(input, output, session)
          suggestion_server(input, output, session)
          user_page_server(input, output, session)
          plan_subscription_server(input, output, session)
          # success_payment_server(input, output, session)
          query <- sprintf("UPDATE PSICOLOGO SET token = '%s' WHERE id=%d", GLOBAL_TOKEN, id) # de momento 1 
          DBI::dbExecute(con, query)
          query2 <- sprintf("UPDATE PSICOLOGO SET refresh_token = '%s' WHERE id=%d", GLOBAL_REFRESH_TOKEN, id) # de momento 1
          DBI::dbExecute(con, query2)
          message("Token obtenido e insertado en la bd")
          shinyjs::show("logout_btn")
          user_name(user$nombre)
        }
        else{
          message("error token")
          message(token_data$error)
          user_name(NULL)
        }
      }
    }
    else{
      user_name(user$nombre)
      resp_info <- httr::GET(url = info_url, add_headers("Authorization" = paste("Bearer", user$token, sep = " ")))
      message("respuesta del get info user")
      message(resp_info)
      error <- httr::http_status(resp_info)
      message("status ", error)
      texto <- paste(error, collapse = " ")
      palabras <- strsplit(texto, " ")[[1]]
      # Seleccionar la última palabra
      ultima_palabra <- palabras[length(palabras)]
      if(ultima_palabra != "OK"){
        message("caducado, intentando refrescar token")
        refresh_respuesta <- obtener_token_refrescado(user$refresh_token)
        message("mensaje refresh token")
        message(refresh_respuesta)
        refresh_token_data <- jsonlite::fromJSON(refresh_respuesta, simplifyVector = FALSE)
        # Acceder al access_token
        if(!is.null(refresh_token_data$error)){
          message("Imposible refrescar el token")
          DBI::dbExecute(con, sprintf("update psicologo set token=NULL, refresh_token=NULL where id=%d", user$id))
          set_cookie(cookie_name = "token_cookie", cookie_value = "null")
          shinyjs::hide("logout_btn")
          shinyjs::show("invitado")
          user_name(NULL)
          runjs("window.location.href = '/#!/';")
          session$reload()
        }
        else{
          r <- refresh_token_data$access_token
          message(paste("añado ", user$token))
          session$userData$user_token <- r
          set_cookie(cookie_name = "token_cookie", cookie_value = GLOBAL_TOKEN)
          DBI::dbExecute(con, sprintf("update psicologo set token='%s' where id=%d", r, user$id))
          message("token actualizado")
          shinyjs::show("logout_btn")
          shinyjs::hide("invitado")

        }
        

      }
      if(ultima_palabra == "OK"){
        message("token válido....")
        shinyjs::show("logout_btn")
        shinyjs::hide("invitado")
        # token válido, gestionar permisos?
        info <- (httr::content(resp_info, "text"))
        info <- jsonlite::fromJSON(info)
        rol <- gestionar_rol(info$roles)
        
        if(!is.null(info$email) && info$email!= ""){
          session$userData$email_user <- info$email
          # llamar a la funcion de refrescar con stripe
          ## asi podemos ver si el rol coincide con la suscripcion que se tenga
          ## y metemos el rol actualizado en la variable session
          # syncStripeDBProcessLight()
          # syncStripeDBProcess()
        }





        session$userData$rol <- rol
        session$userData$id_psicologo <- user$id
        patient_server(input, output, session)
        suggestion_server(input, output, session)
        user_page_server(input, output, session)
        plan_subscription_server(input, output, session)
        # success_payment_server(input, output, session)
        
        message("rol> ", rol)
        DBI::dbExecute(con, sprintf("update psicologo set rol='%s' where id=%d", rol, user$id)) # de momento 1
      }
    }
    DBI::dbDisconnect(con)
  })


  observe({
    message(paste("email from user", session$userData$email_user))
  })

  observeEvent(input$logout_btn, {
    user <- psicologo()
    con <- establishDBConnection()
    token <- DBI::dbGetQuery(con, sprintf("SELECT token FROM psicologo WHERE id=%d", user$id)) 
    refresh_token <- DBI::dbGetQuery(con, sprintf("SELECT refresh_token FROM psicologo WHERE id=%d", user$id)) 
    params <- list(
      client_id = keycloak_client_id,
      refresh_token = refresh_token,
      client_secret = keycloak_client_secret,
      redirect_uri = ruta_app
    )
    resp <- httr::POST(url = logout_url, add_headers("Content-Type" = "application/x-www-form-urlencoded", "Authorization" = paste("Bearer", token, sep = " ")), 
                      body = params, encode="form")
    message(resp)
    DBI::dbExecute(con, sprintf("update psicologo set token=NULL, refresh_token=NULL where id=%d", user$id)) # de momento 1
    user_name(NULL)
    set_cookie(cookie_name = "token_cookie", cookie_value = "null")
    psicologo(NULL)
    runjs("window.location.href = '/#!/';")
    session$reload()
    DBI::dbDisconnect(con)
  })
  

  make_authorization_url <- function() {
    url_template <- "http://%s/keycloak/realms/Gridfcm/protocol/openid-connect/auth?client_id=%s&redirect_uri=%s&response_type=code&scope=%s"
    sprintf(url_template,
      domain,
      utils::URLencode(keycloak_client_id, reserved = TRUE, repeated = TRUE),
      utils::URLencode(ruta_app, reserved = TRUE, repeated = TRUE),
      utils::URLencode("openid roles", reserved = TRUE, repeated = TRUE)
    )
  }
  




  link <- make_authorization_url()
  
  
  observe(
    if(is.null(user_name())){
      output$user_name <- renderText(i18n$t("Iniciar Sesión"))
      output$user_div <- renderUI({
        div(id="profile", class = "nav-item user-page user-page-btn" , menuItem(textOutput("user_name"), href = link, icon = icon("right-to-bracket"), newTab = FALSE))
      })
    }
    else{
      message(user_name())
      output$user_name <- renderText(user_name())
      output$user_div <- renderUI({
        div(id="profile", class = "nav-item user-page user-page-btn" , menuItem(textOutput("user_name"), href = route_link("user"), icon = icon("house-user"), newTab = FALSE))
      })
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
  #form_server(input, output, session)
  #patient_server(input, output, session)
  repgrid_server(input, output, session)
  repgrid_home_server(input, output, session)
  repgrid_analisis_server(input, output, session)
  wimpgrid_analysis_server(input, output, session)
  #suggestion_server(input, output, session)
  #user_page_server(input, output, session)
}

shinyApp(ui, server)


