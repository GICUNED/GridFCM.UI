syncStripeDB <- function(email, id_psicologo, rol, con) {
    # llamamos a stripe para sacar todos los client_id con este email (cada compra registra a un nuevo client_id)
    stripe_sk = Sys.getenv("STRIPE_SK")

    # columnas finales de ids, status y cantidades 
    id_suscripciones = c()
    status_suscripciones = c()
    cantidad_suscripciones = c()
    fecha_inicio_suscripciones = c()
    fecha_fin_suscripciones = c()

    clientes_url = sprintf("https://api.stripe.com/v1/customers?email=%s", email)
    resp <- httr::GET(url = clientes_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
    # message(resp)
    clientes <- (httr::content(resp, "text"))
    clientes <- jsonlite::fromJSON(clientes)

    if(!is.null(clientes) && !is.null(clientes$data) && length(clientes$data)>0){
      id_clientes = clientes$data$id
      ## ahora llamamos a las suscripciones que tienen estos client_ids
      for(id_cl in id_clientes){
        # message(id)
        suscripcion_url = sprintf("https://api.stripe.com/v1/subscriptions?customer=%s&status=%s", id_cl, "all")
        # suscripcion_url = sprintf("https://api.stripe.com/v1/subscriptions?customer=%s&status=%s", "cus_P3fbxTegsKzrFj", "all")
        resp <- httr::GET(url = suscripcion_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
        # message(resp)
        suscripcion <- (httr::content(resp, "text"))
        suscripcion <- jsonlite::fromJSON(suscripcion)
        
        if(!is.null(suscripcion) && !is.null(suscripcion$data) && length(suscripcion$data)>0){
          # cada cliente puede tener varias suscripciones
          id_susc = suscripcion$data$id
          status_susc = suscripcion$data$status
          cantidad_susc = suscripcion$data$quantity
          fecha_inicio_susc = suscripcion$data$current_period_start
          fecha_fin_susc = suscripcion$data$current_period_end


          id_suscripciones = append(id_suscripciones,id_susc)
          status_suscripciones = append(status_suscripciones, status_susc)
          cantidad_suscripciones = append(cantidad_suscripciones, cantidad_susc)
          fecha_inicio_suscripciones = append(fecha_inicio_suscripciones, fecha_inicio_susc)
          fecha_fin_suscripciones = append(fecha_fin_suscripciones, fecha_fin_susc)

        }
        # break()

        

      }
      
    }

    stripe_data = data.frame(id_suscripcion=id_suscripciones, status=status_suscripciones, cantidad=cantidad_suscripciones, fecha_inicio=fecha_inicio_suscripciones, fecha_fin=fecha_fin_suscripciones)
    message("dataframe")
    message(stripe_data)
    # message(stripe_data$id_suscripcion)

    # ahora traemos lo que tenemos en la base de datos, en suscripciones
    query <- sprintf("SELECT id, activa, id_stripe_suscripcion, tipo_suscripcion, fecha_inicio, fecha_fin from SUSCRIPCION WHERE fk_psicologo = %d", id_psicologo)
    datos_bd <- DBI::dbGetQuery(con, query)

    suscripciones_a_añadir = c() # estan en stripe activas pero no en la bd
    suscripciones_a_actualizar_activas = c() # solamente se actualiza el status si procede. puede ser que pase de activa - no activa y viceversa
    suscripciones_a_actualizar_no_activas = c() # solamente se actualiza el status si procede. puede ser que pase de activa - no activa y viceversa
    suscripciones_manuales = datos_bd[datos_bd$tipo_suscripcion=="manual" & datos_bd$activa, "id"]  # tipo manual en bd, se guarda el id de la bd serial, solamente se checkea que siguen siendo validas. Las no validas no se checkean

    if(!is.null(datos_bd$id) && length(datos_bd$id)>0){
      message(datos_bd)
      # suscripciones activas de stripe con las de la bd
      stripe_activas = stripe_data[stripe_data$status=="active", "id_suscripcion"]
      # suscripciones no activas de stripe con las de la bd
      stripe_no_activas = stripe_data[stripe_data$status!="active", "id_suscripcion"]

      message("stripe")
      message(stripe_activas)
      message(stripe_no_activas)
      # todas las de bd con tipo auto
      bd_auto = datos_bd[datos_bd$tipo_suscripcion=="auto", "id_stripe_suscripcion"]
      # activas en bd con tipo auto
      bd_activas = datos_bd[datos_bd$activa & datos_bd$tipo_suscripcion=="auto", "id_stripe_suscripcion"]

      # si esta en stripe activa, y en la base de datos no esta, se añade
      suscripciones_a_añadir = stripe_activas[!(stripe_activas %in% bd_auto)]
      # si esta en stripe activa, y en la base de datos se encuentra no activa, se actualiza a activa
      suscripciones_a_actualizar_activas = stripe_activas[(stripe_activas %in% bd_auto & !(stripe_activas %in% bd_activas))]
      # si esta en stripe no activa, y en la base de datos se encuentra activa, se actualiza a no activa
      suscripciones_a_actualizar_no_activas = stripe_no_activas[(stripe_no_activas %in% bd_auto & stripe_no_activas %in% bd_activas)]

      message(suscripciones_a_añadir)
      message(suscripciones_a_actualizar_activas)
      message(suscripciones_a_actualizar_no_activas)
      message(suscripciones_manuales)

      message("bd")
      message(bd_auto)
      message(bd_activas)
    }else{
      # no hay nada en la bd aun
      suscripciones_a_añadir = stripe_data[stripe_data$status=="active", "id_suscripcion"]
      # no deberia haber suscripciones a actualizar a no ser que sean manuales, asi que:
      suscripciones_a_actualizar_activas = c()
      suscripciones_a_actualizar_no_activas = c()
    }

    # añadir suscripciones
    if(!is.null(suscripciones_a_añadir) && length(suscripciones_a_añadir)>0){
      # añadirlas. a priori no hacer aqui cambios de roles en keycloak ni en psicologo
      ## añadir a tabla suscripcion
      ### checkear si el id_psicologo ya esta en licencia, si no esta las licencias disponibles seran contratadas - 1. si ya esta, las disponibles seran las contratadas
      query <- sprintf("SELECT id from LICENCIA WHERE fk_psicologo = '%s'", id_psicologo)
      datos <- DBI::dbGetQuery(con, query)
      if(!is.null(datos$id) && length(datos$id)>0){
        en_licencia_ya = TRUE
      }else{
        en_licencia_ya = FALSE
      }
      # recorremos todas las suscripciones a añadir
      for(id_susc_a_añadir in suscripciones_a_añadir){
        # message(id_susc_a_añadir)
        cantidad_susc_a_añadir = stripe_data[stripe_data$id_suscripcion==id_susc_a_añadir, "cantidad"]
        if(cantidad_susc_a_añadir > 1){
          organizacion = "true"
        }else{
          organizacion= "false"
          en_licencia_ya = TRUE # no hay que meter en licencia al usuario con suscripcion individual
        }

        if(en_licencia_ya && organizacion){
          sus_licencias_disponibles = cantidad_susc_a_añadir
        }else if (en_licencia_ya && !organizacion) {
          sus_licencias_disponibles = cantidad_susc_a_añadir - 1
        }
        else{
          sus_licencias_disponibles = cantidad_susc_a_añadir - 1
        }
        sus_fecha_inicio = as.POSIXct(stripe_data[stripe_data$id_suscripcion==id_susc_a_añadir, "fecha_inicio"], format="%H:%M:%S")
        sus_fecha_fin = as.POSIXct(stripe_data[stripe_data$id_suscripcion==id_susc_a_añadir, "fecha_fin"], format="%H:%M:%S")
        # message(sus_fecha_inicio)
        # message(en_licencia_ya)
        ### añadimos a tabla suscripcion
        query <- sprintf("INSERT INTO suscripcion
        (fecha_inicio, fecha_fin, licencias_contratadas, licencias_disponibles, organizacion, activa, id_stripe_suscripcion, fk_psicologo)
        VALUES('%s', '%s', %d, %d, %s, %s, '%s', %d);", sus_fecha_inicio, sus_fecha_fin, cantidad_susc_a_añadir, sus_licencias_disponibles, organizacion, "true", id_susc_a_añadir, id_psicologo)
        # message(query)
        DBI::dbExecute(con, query)

        # si no esta en licencia aun, metemos un registro
        if(!en_licencia_ya){
          query <- sprintf("SELECT id from SUSCRIPCION WHERE id_stripe_suscripcion = '%s'", id_susc_a_añadir)
          # message(query)
          datos <- DBI::dbGetQuery(con, query)

          # id de la suscripcion en nuestra tabla SUSCRIPCION
          id_susc_serial <- datos$id
          # metemos en licencia un registro con el id del usuario en cuestion y de la suscripcion
          query <- sprintf("INSERT INTO licencia (fk_psicologo, fk_suscripcion) VALUES(%d, %d);", id_psicologo, id_susc_serial)
          # message(query)
          DBI::dbExecute(con, query)

          en_licencia_ya = TRUE
        }
        
      }
      
    }

    # actualizar suscripciones
    ## actualizar las suscripciones a activas y no activas a la vez
    ### necesitamos tener esta cadena de texto por cada suscripcion: '(id_suscripcion, activa)'
    values_text = ""
    if(!is.null(suscripciones_a_actualizar_activas) && length(suscripciones_a_actualizar_activas)>0){
      for( sus_act_activas in suscripciones_a_actualizar_activas){
        value_text = paste("('", sus_act_activas, "', true)", sep="", collapse=NULL)

        if(values_text==""){
          values_text = value_text
        }else{
          values_text = paste(values_text,value_text, sep = ",", collapse=NULL)
        }
        
      }
    }
    
    if(!is.null(suscripciones_a_actualizar_no_activas) && length(suscripciones_a_actualizar_no_activas)>0){
      for( sus_act_no_activas in suscripciones_a_actualizar_no_activas){

        value_text = paste("('", sus_act_no_activas, "', false)", sep="", collapse=NULL)

        if(values_text==""){
          values_text = value_text
        }else{
          values_text = paste(values_text,value_text, sep = ",", collapse=NULL)
        }
      }
    }
    if(values_text!=""){
      # message(values_text)
      query <- sprintf("update SUSCRIPCION as s set
          activa = c.column_a
      from (values %s  
      ) as c(column_b, column_a) 
      where c.column_b = s.id_stripe_suscripcion;", values_text)
      # message(query)
      DBI::dbExecute(con, query)
    }

    ## para las actualizadas a no activas, tenemos que borrar cualquier registro que apunte a ellas desde la tabla licencia
    if(!is.null(suscripciones_a_actualizar_no_activas) && length(suscripciones_a_actualizar_no_activas)>0){ 
      ids_actualizar_no_activas_text = paste("'",suscripciones_a_actualizar_no_activas,"'", sep="", collapse = ", ")

      query <- sprintf("SELECT id from SUSCRIPCION WHERE id_stripe_suscripcion in (%s)", ids_actualizar_no_activas_text)
      message(query)
      # message(query)
      datos <- DBI::dbGetQuery(con, query)

      # id de la suscripcion en nuestra tabla SUSCRIPCION
      ids_actualizar_no_activas_serial <- datos$id

      # borramos de licencias todo lo que tenga que ver con estas ids
      ids_text = paste(ids_actualizar_no_activas_serial, collapse = ", ")
      query <- sprintf("delete from licencia where fk_suscripcion in (%s);", ids_text)
      message(query)
      DBI::dbExecute(con, query)
    }
    

    # revisar las manuales
    if(!is.null(suscripciones_manuales) && length(suscripciones_manuales)>0){
      ## tenemos que ver que current_date < fecha_fin
      current_date = Sys.Date()
      # fecha_1 = datos_bd[datos_bd$tipo_suscripcion=="manual", "fecha_fin"]
      # message(fecha_1)
      # fecha_1_date = as.Date(fecha_1)
      # message(fecha_1_date)
      # message(datos_bd[datos_bd$tipo_suscripcion=="manual", "fecha_fin"])

      ids_manuales_a_cambiar_a_no_activo = c()
      for(id_susc_manual in suscripciones_manuales){
        # vamos una a una comprobando
        # message(datos_bd[datos_bd$id==id_susc_manual, c("fecha_inicio", "fecha_fin")])
        fechas_susc_manual = datos_bd[datos_bd$id==id_susc_manual, c("fecha_inicio", "fecha_fin")]
        fecha_inicio_susc_manual = as.Date(fechas_susc_manual$fecha_inicio)
        fecha_fin_susc_manual = as.Date(fechas_susc_manual$fecha_fin)

        # message(fecha_inicio_susc_manual)
        # message(fecha_fin_susc_manual)

        if(current_date < fecha_inicio_susc_manual || current_date > fecha_fin_susc_manual){
          message("cambio a inactiva")
          ids_manuales_a_cambiar_a_no_activo = append(ids_manuales_a_cambiar_a_no_activo, id_susc_manual)
        }else{
          message("se queda activa")
        }
      }
      
      
      if(!is.null(ids_manuales_a_cambiar_a_no_activo) && length(ids_manuales_a_cambiar_a_no_activo)>0){
        # cambiamos en la bd a no activas las suscripciones bajo estos ids
        # message(ids_manuales_a_cambiar_a_no_activo)
        ids_text = paste(ids_manuales_a_cambiar_a_no_activo, collapse = ", ")
        query <- sprintf("update SUSCRIPCION as s set
          activa = false 
          where s.id in (%s);", ids_text)
        message(query)
        DBI::dbExecute(con, query)

        # ahora si hay algun registro con estas suscripciones en licencia los quitamos
        query <- sprintf("delete from licencia where fk_suscripcion in (%s);", ids_text)
        DBI::dbExecute(con, query)

      }
    }
    

    # revisar los permisos, se tendrá que ver el rol que tiene el usuario ahora mismo y ver si es consistente con el que debería tener
    ## hay que jugar con suscripciones añadidad, suscripciones actualizadas a activas y no activas y las manuales.
    ## lo mas facil quizá sea comprobar en la bd si se tiene alguna licencia/suscripcion donde este el usuario dado de alta, y comprobar si el rol que tiene concuerda.
    message("stripe")
    message(rol)
    if(rol != "usuario_administrador"){
      # si no es administrador, tenemos que hacer el checkeo para darle los posibles permisos que le falten, o quitarle los que no deba tener.
      ## miramos si tiene alguna suscripcion activa
      query <- sprintf("SELECT id, organizacion, activa from SUSCRIPCION WHERE fk_psicologo = %d", id_psicologo)
      # message(query)
      datos <- DBI::dbGetQuery(con, query)

      suscripciones_activas_organizacion = datos[datos$activa & datos$organizacion, "id"]
      suscripciones_activas_individual = datos[datos$activa & !(datos$organizacion), "id"]

      ## ahora sacamos las licencias activas para este usuario
      query <- sprintf("SELECT id from licencia WHERE fk_psicologo = %d", id_psicologo)
      datos <- DBI::dbGetQuery(con, query)
      licencias_activas = datos$id

      message(suscripciones_activas_organizacion)
      message(suscripciones_activas_individual)
      message(licencias_activas)

      # calculamos el rol que debe tener
      rol_debe_tener = "usuario_gratis"
      if(!is.null(suscripciones_activas_organizacion) && length(suscripciones_activas_organizacion)>0){
        rol_debe_tener = "usuario_coordinador_organizacion"
      }else if (!is.null(suscripciones_activas_individual) && length(suscripciones_activas_individual)>0) {
        rol_debe_tener = "usuario_ilimitado"
      }else if (!is.null(licencias_activas) && length(licencias_activas)>0) {
        rol_debe_tener = "usuario_ilimitado"
      }

      if(rol != rol_debe_tener){
        # definimos todas la variables necesarias para atacar a keycloak
        domain <- Sys.getenv("DOMAIN")
        keycloak_client_id <- "gridfcm"
        keycloak_client_secret <- Sys.getenv("KEYCLOAK_CLIENT_SECRET")
        rol_ilimitado <- '{"id": "c70eddee-5dd0-49ed-8a02-20eeff11d751","name": "usuario_ilimitado"}'
        rol_ilimitado <- jsonlite::fromJSON(rol_ilimitado)

        rol_coordinador <- '{"id": "fcaf869c-dce6-493b-90e9-33a47f027a6c","name": "usuario_coordinador_organizacion"}'
        rol_coordinador <- jsonlite::fromJSON(rol_coordinador)

        # (copiada de plan_subscription_server) funcion que devuelve el token para acceder a la api de admin
        obtener_token_admin_api <- function(params){
            token_url <- sprintf("https://%s/keycloak/realms/Gridfcm/protocol/openid-connect/token", domain)
            params <- list(
                client_id = keycloak_client_id,
                client_secret = keycloak_client_secret,
                grant_type = "client_credentials"
            )
            resp <- httr::POST(url = token_url, add_headers("Content-Type" = "application/x-www-form-urlencoded"), body = params, encode="form")
            respuesta <- (httr::content(resp, "text"))
            token_data <- jsonlite::fromJSON(respuesta)
            #token
            admin_token <- token_data$access_token
            return(admin_token)
        }

        # (copiada de plan_subscription_server) funcion que devuelve el user_id pasandole como param el email
        obtener_user_id <- function(email, admin_token){
            user_url <- sprintf("https://%s/keycloak/admin/realms/Gridfcm/users?email=%s&exact=%s", domain, email, "true")

            resp <- httr::GET(url = user_url, add_headers("Authorization" = paste("Bearer", admin_token, sep = " ")))
            user_data <- (httr::content(resp, "text"))
            if(!is.null(user_data) && user_data != ""){
                user_data <- jsonlite::fromJSON(user_data)
                if(is.null(user_data$error)){
                    message("no error")
                    user_id <- user_data$id
                }else{
                    message("error")
                    user_id <- NULL
                }
            }else{
                user_id <- NULL
            }
            return(user_id)
        }

        ## primero, sacamos el token para acceder a la api de admin
        admin_token <- obtener_token_admin_api()
        ## ahora necesitamos el user id del usuario al que quitar el rol ilimitado
        user_id <- obtener_user_id(email, admin_token)

        message(user_id)

        rol_url <- sprintf("https://%s/keycloak/admin/realms/Gridfcm/users/%s/role-mappings/realm", domain, user_id)

        # hacemos el cambio de rol en keycloak, partimos de que el usuario no puede tener el administrador llegados este punto
        if(rol_debe_tener == "usuario_coordinador_organizacion"){
          ## meter usuario_coordinador_organizacion a keycloak y quitar usuario_ilimitado si existiera
          request_body <- data.frame(
              id = c(rol_coordinador$id),name = c(rol_coordinador$name)
          )
          request_body_json <- toJSON(request_body, auto_unbox = TRUE)
          resp <- httr::POST(url = rol_url, add_headers("Content-Type" = "application/json","Authorization" = paste("Bearer", admin_token, sep = " ")), body = request_body_json, encode="json")
          roles <- (httr::content(resp, "text"))
          if(!is.null(roles) && roles != ""){
              roles <- jsonlite::fromJSON(roles)
              if(is.null(roles$error)){
                  message("no error")
              }else{
                  message("error")
              }
          }
          ## quitamos usuario_ilimitado si existiera
          

        }else if (rol_debe_tener == "usuario_ilimitado") {
          ## meter usuario ilimitado y quitar usuario_coordinador_organizacion si existiera
        }else if (rol_debe_tener == "usuario_gratis") {
          ## meter usuario gratis y quitar usuario_coordinador_organizacion y usuario_ilimitado si existieran

        }
        message(rol_debe_tener)




        # devolvemos el rol que debemos poner en la sesion
        return(rol_debe_tener)
      }else{
        return(rol)
      }

    }else{
      return(rol)
    }

  }
