library(jsonlite)

print("hello")
i18n <- Translator$new(translation_json_path = "Traductions/Trad.json")
#i18n <- Translator$new(automatic = TRUE)
i18n$set_translation_language("es")

json_path <- "Traductions/Trad.json"
json_data <- fromJSON(json_path)

# Convertir los datos de traducción en un dataframe
translation_df <- as.data.frame(json_data$translation)
# Crear la función de traducción
translate_word <- function(language, word) {
  # Buscar la palabra en las traducciones
  translation_row <- translation_df[translation_df$es == word, ]
  
  # Si la palabra no se encuentra en las traducciones, devolver NULL
  if (nrow(translation_row) == 0) {
    return(NULL)
  }
  
  return(translation_row[[language]])
}

print(translate_word("en", "Inicio de sesion") ) # Debería devolver "Log inn"