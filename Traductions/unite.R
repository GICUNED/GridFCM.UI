# Cargar la biblioteca
library(jsonlite)
library(readr)
# Listar todos los archivos json en el directorio
json_files <- list.files(path = "./Traductions", pattern = "*.json", full.names = TRUE)
print(json_files)
# Leer todos los archivos json y almacenarlos en una lista
json_list <- lapply(json_files, fromJSON)

# Unir todos los json en uno
merged_json <- Reduce(function(x, y) {
  list(
    languages = union(x$languages, y$languages),
    translation = c(x$translation, y$translation)
  )
}, json_list)

# Escribir el json unido a un archivo
toJSON(merged_json, pretty = TRUE, auto_unbox = TRUE) %>% 
  write_lines("./Traductions/merged.json")
