patient_ui <- fluidPage(

  fluidRow(class = ("flex-container-titles"),
    h2(i18n$t("Pacientes"), class = "pt pagetitlecustom"),
  ),

  fluidRow(class = ("flex-container-subtitle"),
    p(i18n$t("Esta página te permite..."), class = "desccustom"),
    actionButton("addPatient", i18n$t("Añadir paciente"), status = 'info', icon = icon("person-circle-plus")),
  ),

  shinyjs::useShinyjs(),
  shiny.i18n::usei18n(i18n),

  #Tabla que muestra los usuarios

  fluidRow(
    column(12, class = "p-3",
      tableOutput("user_table")
  )),

  #Formulario para añadir paciente
  shinyjs::hidden(
    fluidRow(id = "patientForm",
        div(class="patient-backdrop"),
        div(class="patient-form-container anim-fade-in",
            div(class="flex-container-resp-col",
              div(class="card-title border-divider-sm",
              icon("circle-xmark", id = "new-patient-cancel", class="fa-solid exit-patients"),
              span(i18n$t("Nuevo Paciente")),
              ),

              textInput("nombre", i18n$t("Nombre:")),
              div(class="d-flex w-100",
                column(6, class = "w-50 p-0 pr-2", numericInput("edad", i18n$t("Edad:"), value = 0)),
                column(6, class = "w-50 p-0", selectInput("genero", i18n$t("Género:"), c("hombre", "mujer", "no definido"))),
              ),
              textAreaInput("anotaciones", i18n$t("Anotaciones:"), placeholder = "Comentarios relativos al paciente"),
              actionButton("guardarAddPatient", i18n$t("Guardar"), status = 'success', icon = icon("save"))
            )
        )
      )
  )
)
