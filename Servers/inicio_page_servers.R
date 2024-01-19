inicio_server <- function(input, output, session) {

  #httr::set_config(config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
  keycloak_client_id <- "gridfcm"
  domain <- Sys.getenv("DOMAIN")
  ruta_app <- sprintf("https://%s/", domain)
  
  make_authorization_url <- function() {
    
    url_template <- "http://%s/keycloak/realms/Gridfcm/protocol/openid-connect/auth?client_id=%s&redirect_uri=%s&response_type=code&scope=%s"
    sprintf(url_template,
      domain,
      utils::URLencode(keycloak_client_id, reserved = TRUE, repeated = TRUE),
      utils::URLencode(ruta_app, reserved = TRUE, repeated = TRUE),
      utils::URLencode("openid roles", reserved = TRUE, repeated = TRUE)
    )
  }

  observeEvent(input$ingresar, {
    link <- make_authorization_url()
    message(link)
    runjs(paste0("window.location.href = '", link, "';"))
  })

  isValidEmail <- function(x) {
    grepl("\\<[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\>", as.character(x), ignore.case=TRUE)
  }

  observe({
        i18n$set_translation_language(input$selected_language)
  })

  output$dynamic_iframe_home <- renderUI({
        iframe_src <- switch(input$selected_language,
            "es" = "https://blogs.uned.es/gicuned/psychlab-home",
            "en" = "https://blogs.uned.es/gicuned/psychlab-home-en",
            NULL
        )
        if (!is.null(iframe_src)) {
            tags$iframe(src = iframe_src, class = "home-iframe")
        }
    })
}
