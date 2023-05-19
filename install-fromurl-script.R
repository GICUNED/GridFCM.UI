# Lista de URL de archivos de paquetes para instalar
package_urls <- c(

  "https://github.com/Appsilon/shiny.router/archive/0.3.1.tar.gz",
  "https://github.com/daattali/shinyjs/archive/2.1.0.tar.gz",
  "https://github.com/dmurdoch/rgl/archive/v1.1.3.tar.gz",
  "https://github.com/dreamRs/fresh/archive/v0.2.0.tar.gz",
  "https://github.com/dreamRs/toastui/archive/v0.2.1.tar.gz",
  "https://github.com/haozhu233/kableExtra/archive/a05b9f55fe0b8e8ef1aec7d129c1bb2d60e645da.tar.gz",
  "https://github.com/markheckmann/OpenRepGrid/archive/df9faad3e58001ccc08ca2d1382f5e97f178ea98.tar.gz",
  "https://github.com/RinteRface/bs4Dash/archive/v2.2.1.tar.gz",
  "https://github.com/rstudio/DT/archive/v0.27.tar.gz",
  "https://github.com/rstudio/rmarkdown/archive/v2.21.tar.gz",
  "https://github.com/rstudio/shiny/archive/v1.7.4.tar.gz",
  "https://github.com/rstudio/shinydashboard/archive/v0.7.2.tar.gz",
  "https://github.com/ycphs/openxlsx/archive/83271527bc83cfe7b72c04a23c5de47cd18e1773.tar.gz",
  "https://github.com/yihui/knitr/archive/v1.42.tar.gz",
  "https://github.com/jrowen/rhandsontable/archive/refs/tags/v0.3.8.tar.gz"
)
#devtools::install_github("jrowen/rhandsontable")
#remotes::install_url(https://github.com/markheckmann/OpenRepGrid/archive/refs/tags/v0.0.14.tar.gz)
for (url in package_urls) {
  remotes::install_url(url)
}
