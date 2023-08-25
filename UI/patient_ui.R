patient_ui <- fluidPage(
  shinyjs::useShinyjs(),
  shiny.i18n::usei18n(i18n),


  fluidRow(class = ("flex-container-titles"),
    h2(i18n$t("Pacientes"), class = "pt pagetitlecustom"),
  ),

  fluidRow(class = ("flex-container-subtitle"),
    p(i18n$t("En esta página..."), class = "desccustom"),
    actionButton("addPatient", i18n$t("Añadir paciente"), status = 'info', icon = icon("person-circle-plus")),
  ),
  
  #Tabla que muestra los usuarios

  fluidRow(
    column(12, class = "p-3",
      tableOutput("user_table")
  )),
  actionButton("editarPaciente", "Editar"),
  actionButton("borrarPaciente", "Borrar"),

  #Formulario para añadir paciente
  shinyjs::hidden(
    div(id = "patientForm", class="patient-form-container anim-fade-in",
        div(class="flex-container-resp-col",
          div(class="card-title",
          icon("circle-xmark", id = "new-patient-cancel", class="fa-solid exit-patients"),
          span(i18n$t("Nuevo Paciente")),
          ),

          textInput("nombre", i18n$t("Nombre:")),
          div(class="d-flex w-100",
            column(6, class = "p-0 pr-2", numericInput("edad", i18n$t("Edad:"), value = 0)),
            column(6, class = "p-0", selectInput("genero", i18n$t("Género:"), c("Hombre", "Mujer", "Sin definir"))),
          ),
          textAreaInput("anotaciones", i18n$t("Anotaciones:")),
          actionButton("guardarAddPatient", i18n$t("Guardar"), status = 'success', icon = icon("save"))
        )
    )
  ),

  shinyjs::hidden(
    div(id = "editForm", class="patient-form-container anim-fade-in",
        div(class="flex-container-resp-col",
          div(class="card-title",
          icon("circle-xmark", id = "edit-patient-cancel", class="fa-solid exit-patients"),
          span(i18n$t("Editar Paciente")),
          ),

          textInput("nombreEdit", i18n$t("Nombre:")),
          div(class="d-flex w-100",
            column(6, class = "p-0 pr-2", numericInput("edadEdit", i18n$t("Edad:"), value = 0)),
            column(6, class = "p-0", selectInput("generoEdit", i18n$t("Género:"), c("Hombre", "Mujer", "Sin definir"))),
          ),
          textAreaInput("anotacionesEdit", i18n$t("Anotaciones:")),
          #En amarillo el boton???
          actionButton("saveEdit", i18n$t("Editar"), status = 'success', icon = icon("save"))
        )
    )
  )


)
