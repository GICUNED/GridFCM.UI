suggestion_ui <- fluidPage(
    useShinyjs(),

    titlePanel(i18n$t("Sugerencias")),
  
    # Cuadro de texto grande
    textAreaInput("sugerencia", i18n$t("Escriba su sugerencia aquí:"), rows = 10),
    
    # Botón de enviar
    actionButton("send_suggestion", i18n$t("Enviar"), disable= TRUE),

    
)