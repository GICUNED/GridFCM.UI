user_home_ui <-  div(
    h2("Bienvenido a la página de inicio del usuario", class = "pagetitlecustom"),
    p("Aquí puedes agregar más contenido para mostrar al usuario después de iniciar sesión", class = "desccustom"),
    actionButton("crear_nuevo", "Crear nuevo análisis de rejilla"),
    tableOutput("rejillas_anteriores")
  )