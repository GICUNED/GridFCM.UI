patient_ui <- fluidPage(
  shinyjs::useShinyjs(),
  shiny.i18n::usei18n(i18n),


  fluidRow(class = ("flex-container-xl"),
    h2(i18n$t("Pacientes"), class = "pt pagetitlecustom"),
    p(i18n$t("Esta página te permite..."), class = "desccustom"),
  ),

  fluidRow( class="custom-margins mt-2",
    column(12, class = ("button-container mb-2"),
      actionButton(class="mr-auto", "addPatient", i18n$t("Añadir paciente"), status = 'info', icon = icon("person-circle-plus")),
      actionButton("editarPaciente", i18n$t("Editar"), icon = icon("pen-to-square")),
      actionButton("borrarPaciente", i18n$t("Borrar"), status ="danger", icon = icon("trash-can")),
    ),
    column(12, class = "patients-table p-3 bg-white rounded-lg",
        DTOutput("user_table")
    ),
  ),
  
  div(
    actionButton("simulacionesRepgrid", i18n$t("Simulaciones Repgrid")),
    actionButton("simulacionesWimpgrid", i18n$t("Simulaciones Wimpgrid")),
    actionButton("importarGridPaciente", i18n$t("Nueva rejilla"))
  ),

  # Listado de simulaciones repgrid
  DTOutput("simulaciones_rep"),
  
  # Boton para editar la simulacion repgrid
  actionButton("editarSimulacionRepgrid", i18n$t("Cargar simulación seleccionada")),

 
  DTOutput("simulaciones_wimp"),
 


  #Formulario para añadir paciente
  shinyjs::hidden(
    fluidRow(id = "patientForm",
        div(class="patient-backdrop"),
        div(class="patient-form-container",
            div(class="flex-container-resp-col",
              div(class="card-title border-divider-sm",
              icon("circle-xmark", id = "new-patient-cancel", class="fa-solid exit-patients"),
              span(i18n$t("Nuevo paciente")),
              ),

          textInput("nombre", i18n$t("Nombre:")),
          div(class="d-flex w-100",
            column(6, class = "w-50 p-0 pr-2", numericInput("edad", i18n$t("Edad:"), value = 0)),
            column(6, class = "w-50 p-0", selectInput("genero", i18n$t("Género:"), c("Hombre", "Mujer", "Sin definir"))),
          ),
          textAreaInput("anotaciones", i18n$t("Anotaciones:"), placeholder = "Comentarios relativos al paciente"),
          actionButton("guardarAddPatient", i18n$t("Guardar"), status = 'success', icon = icon("save"))
        )
    )
  ),

  shinyjs::hidden(
    fluidRow(id = "editForm",
    div(class="patient-backdrop"),
    div(class="patient-form-container",
        div(class="flex-container-resp-col",
          div(class="card-title",
          icon("circle-xmark", id = "edit-patient-cancel", class="fa-solid exit-patients"),
          span(i18n$t("Editar paciente")),
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
  )

)
