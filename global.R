# global.R

library(shiny)
library(shinyjs)
library(shiny.router)
library(bs4Dash)
library(fresh)

# File with translations
i18n <- Translator$new(translation_json_path = "Traductions/wimpgrid.json")
# Change this to en or comment this line
i18n$set_translation_language("en")

