patient_ui <- fluidPage(class="patient-diff",
  shinyjs::useShinyjs(),
  shiny.i18n::usei18n(i18n),


  fluidRow(class = ("flex-container-xl"),
    h2(i18n$t("Pacientes"), class = "pt pagetitlecustom"),
    p(i18n$t("Esta página te permite..."), class = "desccustom"),
  ),

  fluidRow(class="custom-margins mt-2",
    column(12, class = ("button-container mb-2"),
      actionButton(class="mr-auto", "addPatient", i18n$t("Añadir paciente"), status = 'info', icon = icon("person-circle-plus")),
      actionButton("editarPaciente", i18n$t("Editar"), disabled=TRUE, icon = icon("pen-to-square")),
      actionButton("borrarPaciente", i18n$t("Borrar"), status ="danger", disabled=TRUE, icon = icon("trash-can"))
    ),

    column(12, class = "patients-table p-3 bg-white rounded-lg",
      shinycssloaders::withSpinner(DTOutput("user_table"), type = 4, color = "#022a0c", size = 0.6),
      div(class = "button-container mt-2 justify-content-center",    
        actionButton("importarGridPaciente", i18n$t("Nueva rejilla"), disabled=TRUE, icon = icon("plus"), status="success"),
        ),
    ),
    column(12, id = "patientSimulations", class = "p-3 mt-4 bg-white rounded-lg mix-diff simulation-tab",

          # Boton para editar la simulacion repgrid
          div(class = "button-container pb-2",
            h4(class = "paciente-seleccionado mr-auto mb-0 font-weight-bold", htmlOutput("paciente_simulacion_header")),
            actionButton("cargarSimulacion", i18n$t("Abrir simulación"), disabled=TRUE, icon = icon("download")),
            actionButton("borrarSimulacion", i18n$t("Borrar simulación"), disabled=TRUE, status ="danger", icon = icon("trash-can"))
          ),
            tabsetPanel(id = "tabSimulaciones",
              tabPanel(i18n$t("RepGrid"), id = "patient-rep", icon = icon("magnifying-glass-chart"),
                # Listado de simulaciones repgrid
                shinycssloaders::withSpinner(DTOutput("simulaciones_rep"), type = 4, color = "#022a0c", size = 0.6)
                # div(id="simulationIndicatorRG", class = "mr-auto patient-active-label",htmlOutput("simulation_active_rg"),
              ),
              tabPanel(i18n$t("WimpGrid"), id = "patient-wimp", icon = icon("border-none"),
                # Listado de simulaciones repgrid
                shinycssloaders::withSpinner(DTOutput("simulaciones_wimp"), type = 4, color = "#022a0c", size = 0.6)
                # div(id="simulationIndicatorRG", class = "mr-auto patient-active-label",htmlOutput("simulation_active_rg"),
              )
            )
  ),
          
),


 #fluidRow


  #Formulario para añadir paciente
  shinyjs::hidden(
    fluidRow(id = "patientForm",
        div(class = "patient-backdrop"),
        div(class="patient-form-container",
            div(class = "flex-container-resp-col",
              div(class = "card-title border-divider-sm",
              icon("circle-xmark", id = "new-patient-cancel", class = "fa-solid exit-patients"), 
              span(i18n$t("Nuevo paciente")),
              ),
              textInput("nombre", i18n$t("Nombre:")),
              div(class="d-flex w-100",
                column(6, class = "w-50 p-0 pr-2", numericInput("edad", i18n$t("Edad:"), value = 0)),
                column(6, class = "w-50 p-0", selectInput("genero", i18n$t("Género:"), c("Hombre", "Mujer", "Sin definir"))),
              ),
              textAreaInput("diagnostico", i18n$t("Problema:"), placeholder = "Diagnóstico preliminar"),
              textAreaInput("anotaciones", i18n$t("Anotaciones:"), placeholder = "Comentarios relativos al paciente"),
              actionButton("guardarAddPatient", i18n$t("Guardar"), status = 'success', disabled=TRUE, icon = icon("save"))
            )),
    )
  ),

  shinyjs::hidden(
    fluidRow(id = "editForm",
    div(class="patient-backdrop"),
    div(class="patient-form-container",
        div(class="flex-container-resp-col",
          div(class="card-title border-divider-sm",
          icon("circle-xmark", id = "edit-patient-cancel", class="fa-solid exit-patients"),
          span(i18n$t("Editar paciente")),
          ),

          textInput("nombreEdit", i18n$t("Nombre:")),
          div(class="d-flex w-100",
            column(6, class = "p-0 pr-2", numericInput("edadEdit", i18n$t("Edad:"), value = 0)),
            column(6, class = "p-0", selectInput("generoEdit", i18n$t("Género:"), c("Hombre", "Mujer", "Sin definir"))),
          ),
          textAreaInput("diagnosticoEdit", i18n$t("Problema:")),
          textAreaInput("anotacionesEdit", i18n$t("Anotaciones:")),
          #En amarillo el boton???
          actionButton("saveEdit", i18n$t("Editar"), status = 'success', icon = icon("save"))
        )
      )
    )
  )
) #fluidPage