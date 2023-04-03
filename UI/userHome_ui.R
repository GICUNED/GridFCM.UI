user_home_ui <-  div(
    h1("Bienvenido a la página de inicio del usuario"),
    p("Aquí puedes agregar más contenido para mostrar al usuario después de iniciar sesión"),
    actionButton("crear_nuevo", "Crear nuevo análisis de rejilla"),
    tableOutput("rejillas_anteriores")
  )