
print("hello")
i18n <- Translator$new(translation_json_path = "Traductions/Trad.json")
#i18n <- Translator$new(automatic = TRUE)
i18n$set_translation_language("es")
