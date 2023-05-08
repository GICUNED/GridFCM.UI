# Lista de paquetes para instalar
packages <- c(
  "shiny",
  "shinyjs",
  "shiny.router",
  "shinydashboard",
  "toastui",
  "DT",
  "openxlsx",
  "bs4Dash",
  "fresh",
  "rgl",
  "knitr",
  "kableExtra",
  "installr"
)
library(installr)
install.Rtools()

# Instalar paquetes que no están instalados
new_packages <- packages[!packages %in% installed.packages()[, "Package"]]
if (length(new_packages) > 0) {
  install.packages(new_packages)
}
install.packages("OpenRepGrid_0.1.12.tar.gz", repos = NULL, type = "source")
