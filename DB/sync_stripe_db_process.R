# source("establish_con.R")

# definimos todas la variables necesarias para atacar a keycloak
domain <- Sys.getenv("DOMAIN")
keycloak_client_id <- "gridfcm"
keycloak_client_secret <- Sys.getenv("KEYCLOAK_CLIENT_SECRET")


get_suscriptions_to_add_or_update <- function(con, email, lista_customer_ids, datos_bd, datos_suscripciones) {
  ## de aqui para abajo, para un email (cliente) me saca todas las suscripciones para actualizar/añadir
  id_suscripciones = c()
  status_suscripciones = c()
  cantidad_suscripciones = c()
  fecha_inicio_suscripciones = c()
  fecha_fin_suscripciones = c()

  
  id_suscripciones = datos_suscripciones[datos_suscripciones$customer %in% lista_customer_ids,"id"]
  status_suscripciones = datos_suscripciones[datos_suscripciones$customer %in% lista_customer_ids,"status"]
  cantidad_suscripciones = datos_suscripciones[datos_suscripciones$customer %in% lista_customer_ids,"quantity"]
  fecha_inicio_suscripciones = datos_suscripciones[datos_suscripciones$customer %in% lista_customer_ids,"current_period_start"]
  fecha_fin_suscripciones = datos_suscripciones[datos_suscripciones$customer %in% lista_customer_ids,"current_period_end"]

  stripe_data = data.frame(id_suscripcion=id_suscripciones, status=status_suscripciones, cantidad=cantidad_suscripciones, fecha_inicio=fecha_inicio_suscripciones, fecha_fin=fecha_fin_suscripciones)
  # message("dataframe")
  # message(stripe_data)


  suscripciones_a_añadir = c() # estan en stripe activas pero no en la bd
  suscripciones_a_actualizar_activas = c() # solamente se actualiza el status si procede. puede ser que pase de activa - no activa y viceversa
  suscripciones_a_actualizar_no_activas = c() # solamente se actualiza el status si procede. puede ser que pase de activa - no activa y viceversa

  # message("llego")
  if(!is.null(datos_bd$id) && length(datos_bd$id)>0){
    # sacamos el id_psicologo
    query <- sprintf("SELECT id from psicologo where email ='%s'", email)
    datos <- DBI::dbGetQuery(con, query)

    id_psicologo=datos$id

    # suscripciones activas de stripe con las de la bd
    stripe_activas = stripe_data[stripe_data$status=="active", "id_suscripcion"]
    # suscripciones no activas de stripe con las de la bd
    stripe_no_activas = stripe_data[stripe_data$status!="active", "id_suscripcion"]

    # message("stripe")
    # message(stripe_activas)
    # message(stripe_no_activas)
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

    # message(suscripciones_a_añadir)
    # message(suscripciones_a_actualizar_activas)
    # message(suscripciones_a_actualizar_no_activas)
    # message(suscripciones_manuales)

    # message("bd")
    # message(bd_auto)
    # message(bd_activas)
  }else{
    # no hay nada en la bd aun
    suscripciones_a_añadir = stripe_data[stripe_data$status=="active", "id_suscripcion"]
    # no deberia haber suscripciones a actualizar a no ser que sean manuales, asi que:
    suscripciones_a_actualizar_activas = c()
    suscripciones_a_actualizar_no_activas = c()
  }


  # añadir suscripciones
  if(!is.null(suscripciones_a_añadir) && length(suscripciones_a_añadir)>0){
    if(!is.null(id_psicologo)){
      # añadirlas. a priori no hacer aqui cambios de roles en keycloak ni en psicologo
      ## añadir a tabla suscripcion
      ### checkear si el id_psicologo ya esta en licencia, si no esta las licencias disponibles seran contratadas - 1. si ya esta, las disponibles seran las contratadas
      query <- sprintf("SELECT l.id from LICENCIA l inner join psicologo p on p.id=l.fk_psicologo where p.email ='%s'", email)
      datos <- DBI::dbGetQuery(con, query)
      if(!is.null(datos$id) && length(datos$id)>0){
        en_licencia_ya = TRUE
      }else{
        en_licencia_ya = FALSE
      }
      # message("paso1")
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

        if(en_licencia_ya && organizacion=="true"){
          sus_licencias_disponibles = cantidad_susc_a_añadir
        }else if (en_licencia_ya && !(organizacion=="true")) {
          sus_licencias_disponibles = cantidad_susc_a_añadir - 1
        }
        else{
          sus_licencias_disponibles = cantidad_susc_a_añadir - 1
        }
        # message("paso2")

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
  # message("paso3")

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

  ## para las actualizadas a activas, tenemos que ver si hay alguna que haya pasado a activa organizativa, para ver si hay que meter en licencias al usuario
  if(!is.null(suscripciones_a_actualizar_activas) && length(suscripciones_a_actualizar_activas)>0){
    ### checkear si el id_psicologo ya esta en licencia, si no esta las licencias disponibles seran contratadas - 1. si ya esta, las disponibles seran las contratadas
    # recorremos todas las suscripciones actualizadas a activas
    organizacion = "false"
    for(id_susc_a_actualizar_activas in suscripciones_a_actualizar_activas){
      # message(id_susc_a_añadir)
      cantidad_susc_a_actualizar_activas = stripe_data[stripe_data$id_suscripcion==id_susc_a_actualizar_activas, "cantidad"]
      if(cantidad_susc_a_actualizar_activas > 1){
        organizacion = "true"
      }else{
        organizacion= "false"
        en_licencia_ya = TRUE # no hay que meter en licencia al usuario con suscripcion individual
      }

      if(organizacion=="true"){
        break()
      }
    }
    message(organizacion)
    if(organizacion=="true"){
      query <- sprintf("SELECT l.id from LICENCIA l inner join psicologo p on p.id=l.fk_psicologo where p.email ='%s'", email)
      datos <- DBI::dbGetQuery(con, query)
      # message(datos)
      if(!is.null(datos$id) && length(datos$id)>0){
        en_licencia_ya = TRUE
      }else{
        en_licencia_ya = FALSE
      }

      # si no esta en licencia aun, metemos un registro
      if(!en_licencia_ya){
        query <- sprintf("SELECT id from SUSCRIPCION WHERE id_stripe_suscripcion = '%s'", suscripciones_a_actualizar_activas[1])
        # message(query)
        # message(query)
        datos <- DBI::dbGetQuery(con, query)

        # id de la suscripcion en nuestra tabla SUSCRIPCION
        id_susc_serial <- datos$id
        # metemos en licencia un registro con el id del usuario en cuestion y de la suscripcion
        query <- sprintf("INSERT INTO licencia (fk_psicologo, fk_suscripcion) VALUES(%d, %d);", id_psicologo, id_susc_serial)
        # message(query)
        # message(query)
        DBI::dbExecute(con, query)

        en_licencia_ya = TRUE
      }

    }
    

    
  }

  ## para las actualizadas a no activas, tenemos que borrar cualquier registro que apunte a ellas desde la tabla licencia
  if(!is.null(suscripciones_a_actualizar_no_activas) && length(suscripciones_a_actualizar_no_activas)>0){ 
    ids_actualizar_no_activas_text = paste("'",suscripciones_a_actualizar_no_activas,"'", sep="", collapse = ", ")

    query <- sprintf("SELECT id from SUSCRIPCION WHERE id_stripe_suscripcion in (%s)", ids_actualizar_no_activas_text)
    # message(query)
    # message(query)
    datos <- DBI::dbGetQuery(con, query)

    # id de la suscripcion en nuestra tabla SUSCRIPCION
    ids_actualizar_no_activas_serial <- datos$id

    # borramos de licencias todo lo que tenga que ver con estas ids
    ids_text = paste(ids_actualizar_no_activas_serial, collapse = ", ")
    query <- sprintf("delete from licencia where fk_suscripcion in (%s);", ids_text)
    # message(query)
    DBI::dbExecute(con, query)
  }



  # a = 'a' +123 + 123.5 * 'asdasd'
}


syncStripeDBProcess <- function() {
  limit_request_stripe = 10

  # establece conexion con la BD
  establishDBConnection <- function() {
      db_host <- Sys.getenv("DB_HOST")
      db_port <- Sys.getenv("DB_PORT")
      db_name <- Sys.getenv("DB_NAME")
      db_user <- Sys.getenv("DB_USER")
      db_password <- Sys.getenv("DB_PASSWORD")
      

      con <- DBI::dbConnect(
          RPostgres::Postgres(),
          host = db_host,
          port = db_port,
          dbname = db_name,
          user = db_user,
          password = db_password
      )

      return(con)
  }


  con <- establishDBConnection()
  stripe_sk = Sys.getenv("STRIPE_SK")

  # nos traemos todas las suscripciones de la bd
  # ahora traemos lo que tenemos en la base de datos, en suscripciones
  query <- sprintf("SELECT s.id, s.activa, s.id_stripe_suscripcion, s.tipo_suscripcion, s.fecha_inicio, s.fecha_fin, s.fk_psicologo,p.email
    from SUSCRIPCION s
    inner join psicologo p on p.id=s.fk_psicologo ")
  datos_bd <- DBI::dbGetQuery(con, query)



  # ahora sacamos todas las suscripciones con fecha fin > current_date - 3 (suscripciones que acabaron como maximo hace 3 dias, por si se cayera el servidor que ejecuta el script varios dias)
  # https://api.stripe.com/v1/subscriptions?limit=100&current_period_end[gt]=1706617372
  start_point = as.POSIXct (Sys.Date() -3)
  # date_current = as.POSIXct(c("2013-09-01 1:00am"), format="%Y-%m-%d %I:%M%p",tz="America/New_York")
  # message(start_point)
  start_point = as.numeric(start_point)
  # message(start_point)

  # hacer que si hay mas de 100, las saquemos todas
  suscripcion_url = sprintf("https://api.stripe.com/v1/subscriptions?limit=%d&status=%s&current_period_end[gt]=%s", limit_request_stripe, "all", start_point)
  # message(suscripcion_url)
  # suscripcion_url = sprintf("https://api.stripe.com/v1/subscriptions?customer=%s&status=%s", "cus_P3fbxTegsKzrFj", "all")
  resp <- httr::GET(url = suscripcion_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
  # message(resp)
  # message(resp)
  total_suscripciones <- (httr::content(resp, "text"))
  total_suscripciones <- jsonlite::fromJSON(total_suscripciones)

  datos_suscripciones = total_suscripciones$data[,c("id","quantity", "status","current_period_start","current_period_end", "customer")]

  # message(datos_suscripciones)
  # message(nrow(datos_suscripciones))
  
  if(nrow(datos_suscripciones)==limit_request_stripe){
    # volvemos a llamar a la api hasta que los hayamos sacado todos (de 100 en 100), pasandole &starting_after=cus_P61m7kr7jeFzJc (customer id seria el ultimo que hemos sacado)
    num_susc_aux = limit_request_stripe
    while (num_susc_aux == limit_request_stripe) {
        last_susc_id = datos_suscripciones$id[length(datos_suscripciones$id)]
        total_susc_aux_url = sprintf("https://api.stripe.com/v1/subscriptions?limit=%d&status=%s&current_period_end[gt]=%s&starting_after=%s", limit_request_stripe, "all", start_point, last_susc_id) # 100 como maximo
        resp_aux <- httr::GET(url = total_susc_aux_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
        # message(resp)
        total_susc_aux <- (httr::content(resp_aux, "text"))
        total_susc_aux <- jsonlite::fromJSON(total_susc_aux)

        if(!is.null(total_susc_aux) && !is.null(total_susc_aux$data) && length(total_susc_aux$data)>0){
            # sumamos esta lista a la total
            datos_susc_aux = total_susc_aux$data[,c("id","quantity", "status","current_period_start","current_period_end", "customer")]
            # datos_susc_aux = datos_susc_aux[,c("id","email")]
            # message("llego")
            datos_suscripciones = rbind(datos_suscripciones, datos_susc_aux)
            num_susc_aux = nrow(datos_susc_aux)
            # message(nrow(datos_suscripciones))
        }else{
            num_susc_aux = 0
        }

    }
    # datos_clientes = total_clientes$data
      
  }

  # message("saco las susc")
  # message(!is.null(datos_suscripciones))
  # message(!is.null(datos_suscripciones$id))
  # message(length(datos_suscripciones$id))
  # message(nrow(datos_suscripciones$id))
  # message(datos_suscripciones)

  # si hay alguna suscripcion activa
  if(!is.null(datos_suscripciones) && !is.null(datos_suscripciones$id) && length(datos_suscripciones$id)>0){
    message("entramos")
    # sacamos toda la lista de customers, de tal manera que para cada email distinto tenemos su lista de customers ids (un email puede tener asociados muchos customer ids)
    total_clientes_url = sprintf("https://api.stripe.com/v1/customers?limit=%d", limit_request_stripe) # 100 como maximo
    resp <- httr::GET(url = total_clientes_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
    # message(resp)
    total_clientes <- (httr::content(resp, "text"))
    total_clientes <- jsonlite::fromJSON(total_clientes)

    if(!is.null(total_clientes) && !is.null(total_clientes$data) && length(total_clientes$data)>0 && nrow(total_clientes$data)>0){
      datos_clientes = total_clientes$data
      datos_clientes = datos_clientes[,c("id","email")]
      # message(datos_clientes)
      if(nrow(total_clientes$data)==limit_request_stripe){
          # volvemos a llamar a la api hasta que los hayamos sacado todos (de 100 en 100), pasandole &starting_after=cus_P61m7kr7jeFzJc (customer id seria el ultimo que hemos sacado)
          num_clientes_aux = limit_request_stripe
          while (num_clientes_aux == limit_request_stripe) {
              last_client_id = datos_clientes$id[length(datos_clientes$id)]
              total_clientes_aux_url = sprintf("https://api.stripe.com/v1/customers?limit=%d&starting_after=%s", limit_request_stripe, last_client_id) # 100 como maximo
              resp_aux <- httr::GET(url = total_clientes_aux_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
              # message(resp)
              total_clientes_aux <- (httr::content(resp_aux, "text"))
              total_clientes_aux <- jsonlite::fromJSON(total_clientes_aux)

              if(!is.null(total_clientes_aux) && !is.null(total_clientes_aux$data) && length(total_clientes_aux$data)>0){
                  # sumamos esta lista a la total
                  datos_clientes_aux = total_clientes_aux$data
                  datos_clientes_aux = datos_clientes_aux[,c("id","email")]
                  datos_clientes = rbind(datos_clientes, datos_clientes_aux)
                  num_clientes_aux = nrow(datos_clientes_aux)
                  # message(datos_clientes)
              }else{
                  num_clientes_aux = 0
              }

          }
          # datos_clientes = total_clientes$data
          
      }
      # message(datos_clientes$id)
      # message(datos_clientes$email)
      # message(datos_clientes[datos_clientes$email=='juan@uned.com',"id"])
      # message(length(datos_clientes$id))


      # no hacer lo siguiente, no es optimo
      # para cada customer id llamamos a la funcion de abajo pasandole el customer id, email, (rol?¿)
      ## cuando hayamos procesado el ultimo customer id de cada email, revisamos entonces los roles

      ## cuando tengamos todas las suscripciones, usamos el codigo de abajo para que por cada cliente, se creen las sucripciones a añadir y se actualicen las que tocan
      # esto quiza no sea necesario con el nuevo approach
      # ahora sacamos para cada email todos los customer ids que hay
      lista_emails_unicos = unique(datos_clientes$email)
      # message(lista_emails_unicos)
      for(email in lista_emails_unicos){
          # cada email es un usuario unico en la BD, ya disponemos del email aqui
          lista_customer_ids = datos_clientes[datos_clientes$email==email, "id"]
          # message(lista_customer_ids)
          # message(email)
          # message(datos_bd)
          datos_bd_user = datos_bd[datos_bd$email==email,]
          # message(datos_bd_user$id)
          # message(nrow(datos_bd_user))
          if(!is.null(datos_bd_user) && nrow(datos_bd_user)>0){
            # message(datos_bd_user)
            get_suscriptions_to_add_or_update(con, email, lista_customer_ids, datos_bd_user, datos_suscripciones)
          }
          
          
          # message(email)
          # message(lista_customer_ids)

      }

    }

  }

  



  
  # ## de aqui para abajo, para un email (cliente) me saca todas las suscripciones para actualizar/añadir

  # # columnas finales de ids, status y cantidades 
  # id_suscripciones = c()
  # status_suscripciones = c()
  # cantidad_suscripciones = c()
  # fecha_inicio_suscripciones = c()
  # fecha_fin_suscripciones = c()

  # clientes_url = sprintf("https://api.stripe.com/v1/customers?email=%s", email)
  # resp <- httr::GET(url = clientes_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
  # # message(resp)
  # clientes <- (httr::content(resp, "text"))
  # clientes <- jsonlite::fromJSON(clientes)

  # if(!is.null(clientes) && !is.null(clientes$data) && length(clientes$data)>0){
  #   id_clientes = clientes$data$id
  #   ## ahora llamamos a las suscripciones que tienen estos client_ids
  #   for(id_cl in id_clientes){
  #     # message(id)
  #     suscripcion_url = sprintf("https://api.stripe.com/v1/subscriptions?customer=%s&status=%s", id_cl, "all")
  #     # suscripcion_url = sprintf("https://api.stripe.com/v1/subscriptions?customer=%s&status=%s", "cus_P3fbxTegsKzrFj", "all")
  #     resp <- httr::GET(url = suscripcion_url, add_headers("Authorization" = paste("Bearer", stripe_sk, sep = " ")))
  #     # message(resp)
  #     suscripcion <- (httr::content(resp, "text"))
  #     suscripcion <- jsonlite::fromJSON(suscripcion)
      
  #     if(!is.null(suscripcion) && !is.null(suscripcion$data) && length(suscripcion$data)>0){
  #       # cada cliente puede tener varias suscripciones
  #       id_susc = suscripcion$data$id
  #       status_susc = suscripcion$data$status
  #       cantidad_susc = suscripcion$data$quantity
  #       fecha_inicio_susc = suscripcion$data$current_period_start
  #       fecha_fin_susc = suscripcion$data$current_period_end


  #       id_suscripciones = append(id_suscripciones,id_susc)
  #       status_suscripciones = append(status_suscripciones, status_susc)
  #       cantidad_suscripciones = append(cantidad_suscripciones, cantidad_susc)
  #       fecha_inicio_suscripciones = append(fecha_inicio_suscripciones, fecha_inicio_susc)
  #       fecha_fin_suscripciones = append(fecha_fin_suscripciones, fecha_fin_susc)

  #     }
  #     # break()

      

  #   }
    
  # }



  # stripe_data = data.frame(id_suscripcion=id_suscripciones, status=status_suscripciones, cantidad=cantidad_suscripciones, fecha_inicio=fecha_inicio_suscripciones, fecha_fin=fecha_fin_suscripciones)
  # message("dataframe")
  # message(stripe_data)
  # # message(stripe_data$id_suscripcion)

  # # ahora traemos lo que tenemos en la base de datos, en suscripciones
  # query <- sprintf("SELECT id, activa, id_stripe_suscripcion, tipo_suscripcion, fecha_inicio, fecha_fin from SUSCRIPCION WHERE fk_psicologo = %d", id_psicologo)
  # datos_bd <- DBI::dbGetQuery(con, query)

  # suscripciones_a_añadir = c() # estan en stripe activas pero no en la bd
  # suscripciones_a_actualizar_activas = c() # solamente se actualiza el status si procede. puede ser que pase de activa - no activa y viceversa
  # suscripciones_a_actualizar_no_activas = c() # solamente se actualiza el status si procede. puede ser que pase de activa - no activa y viceversa
  # suscripciones_manuales = datos_bd[datos_bd$tipo_suscripcion=="manual" & datos_bd$activa, "id"]  # tipo manual en bd, se guarda el id de la bd serial, solamente se checkea que siguen siendo validas. Las no validas no se checkean

  # if(!is.null(datos_bd$id) && length(datos_bd$id)>0){
  #   message(datos_bd)
  #   # suscripciones activas de stripe con las de la bd
  #   stripe_activas = stripe_data[stripe_data$status=="active", "id_suscripcion"]
  #   # suscripciones no activas de stripe con las de la bd
  #   stripe_no_activas = stripe_data[stripe_data$status!="active", "id_suscripcion"]

  #   message("stripe")
  #   message(stripe_activas)
  #   message(stripe_no_activas)
  #   # todas las de bd con tipo auto
  #   bd_auto = datos_bd[datos_bd$tipo_suscripcion=="auto", "id_stripe_suscripcion"]
  #   # activas en bd con tipo auto
  #   bd_activas = datos_bd[datos_bd$activa & datos_bd$tipo_suscripcion=="auto", "id_stripe_suscripcion"]

  #   # si esta en stripe activa, y en la base de datos no esta, se añade
  #   suscripciones_a_añadir = stripe_activas[!(stripe_activas %in% bd_auto)]
  #   # si esta en stripe activa, y en la base de datos se encuentra no activa, se actualiza a activa
  #   suscripciones_a_actualizar_activas = stripe_activas[(stripe_activas %in% bd_auto & !(stripe_activas %in% bd_activas))]
  #   # si esta en stripe no activa, y en la base de datos se encuentra activa, se actualiza a no activa
  #   suscripciones_a_actualizar_no_activas = stripe_no_activas[(stripe_no_activas %in% bd_auto & stripe_no_activas %in% bd_activas)]

  #   message(suscripciones_a_añadir)
  #   message(suscripciones_a_actualizar_activas)
  #   message(suscripciones_a_actualizar_no_activas)
  #   message(suscripciones_manuales)

  #   message("bd")
  #   message(bd_auto)
  #   message(bd_activas)
  # }else{
  #   # no hay nada en la bd aun
  #   suscripciones_a_añadir = stripe_data[stripe_data$status=="active", "id_suscripcion"]
  #   # no deberia haber suscripciones a actualizar a no ser que sean manuales, asi que:
  #   suscripciones_a_actualizar_activas = c()
  #   suscripciones_a_actualizar_no_activas = c()
  # }

  # # añadir suscripciones
  # if(!is.null(suscripciones_a_añadir) && length(suscripciones_a_añadir)>0){
  #   # añadirlas. a priori no hacer aqui cambios de roles en keycloak ni en psicologo
  #   ## añadir a tabla suscripcion
  #   ### checkear si el id_psicologo ya esta en licencia, si no esta las licencias disponibles seran contratadas - 1. si ya esta, las disponibles seran las contratadas
  #   query <- sprintf("SELECT id from LICENCIA WHERE fk_psicologo = '%s'", id_psicologo)
  #   datos <- DBI::dbGetQuery(con, query)
  #   if(!is.null(datos$id) && length(datos$id)>0){
  #     en_licencia_ya = TRUE
  #   }else{
  #     en_licencia_ya = FALSE
  #   }
  #   # message("paso1")
  #   # recorremos todas las suscripciones a añadir
  #   for(id_susc_a_añadir in suscripciones_a_añadir){
  #     # message(id_susc_a_añadir)
  #     cantidad_susc_a_añadir = stripe_data[stripe_data$id_suscripcion==id_susc_a_añadir, "cantidad"]
  #     if(cantidad_susc_a_añadir > 1){
  #       organizacion = "true"
  #     }else{
  #       organizacion= "false"
  #       en_licencia_ya = TRUE # no hay que meter en licencia al usuario con suscripcion individual
  #     }

  #     if(en_licencia_ya && organizacion=="true"){
  #       sus_licencias_disponibles = cantidad_susc_a_añadir
  #     }else if (en_licencia_ya && !(organizacion=="true")) {
  #       sus_licencias_disponibles = cantidad_susc_a_añadir - 1
  #     }
  #     else{
  #       sus_licencias_disponibles = cantidad_susc_a_añadir - 1
  #     }
  #     # message("paso2")

  #     sus_fecha_inicio = as.POSIXct(stripe_data[stripe_data$id_suscripcion==id_susc_a_añadir, "fecha_inicio"], format="%H:%M:%S")
  #     sus_fecha_fin = as.POSIXct(stripe_data[stripe_data$id_suscripcion==id_susc_a_añadir, "fecha_fin"], format="%H:%M:%S")
  #     # message(sus_fecha_inicio)
  #     # message(en_licencia_ya)
  #     ### añadimos a tabla suscripcion
  #     query <- sprintf("INSERT INTO suscripcion
  #     (fecha_inicio, fecha_fin, licencias_contratadas, licencias_disponibles, organizacion, activa, id_stripe_suscripcion, fk_psicologo)
  #     VALUES('%s', '%s', %d, %d, %s, %s, '%s', %d);", sus_fecha_inicio, sus_fecha_fin, cantidad_susc_a_añadir, sus_licencias_disponibles, organizacion, "true", id_susc_a_añadir, id_psicologo)
  #     # message(query)
  #     DBI::dbExecute(con, query)

  #     # si no esta en licencia aun, metemos un registro
  #     if(!en_licencia_ya){
  #       query <- sprintf("SELECT id from SUSCRIPCION WHERE id_stripe_suscripcion = '%s'", id_susc_a_añadir)
  #       # message(query)
  #       datos <- DBI::dbGetQuery(con, query)

  #       # id de la suscripcion en nuestra tabla SUSCRIPCION
  #       id_susc_serial <- datos$id
  #       # metemos en licencia un registro con el id del usuario en cuestion y de la suscripcion
  #       query <- sprintf("INSERT INTO licencia (fk_psicologo, fk_suscripcion) VALUES(%d, %d);", id_psicologo, id_susc_serial)
  #       # message(query)
  #       DBI::dbExecute(con, query)

  #       en_licencia_ya = TRUE
  #     }
      
  #   }
    
  # }

  # # actualizar suscripciones
  # ## actualizar las suscripciones a activas y no activas a la vez
  # ### necesitamos tener esta cadena de texto por cada suscripcion: '(id_suscripcion, activa)'
  # values_text = ""
  # if(!is.null(suscripciones_a_actualizar_activas) && length(suscripciones_a_actualizar_activas)>0){
  #   for( sus_act_activas in suscripciones_a_actualizar_activas){
  #     value_text = paste("('", sus_act_activas, "', true)", sep="", collapse=NULL)

  #     if(values_text==""){
  #       values_text = value_text
  #     }else{
  #       values_text = paste(values_text,value_text, sep = ",", collapse=NULL)
  #     }
      
  #   }
  # }
  
  # if(!is.null(suscripciones_a_actualizar_no_activas) && length(suscripciones_a_actualizar_no_activas)>0){
  #   for( sus_act_no_activas in suscripciones_a_actualizar_no_activas){

  #     value_text = paste("('", sus_act_no_activas, "', false)", sep="", collapse=NULL)

  #     if(values_text==""){
  #       values_text = value_text
  #     }else{
  #       values_text = paste(values_text,value_text, sep = ",", collapse=NULL)
  #     }
  #   }
  # }
  # # message("paso3")

  # if(values_text!=""){
  #   # message(values_text)
  #   query <- sprintf("update SUSCRIPCION as s set
  #       activa = c.column_a
  #   from (values %s  
  #   ) as c(column_b, column_a) 
  #   where c.column_b = s.id_stripe_suscripcion;", values_text)
  #   # message(query)
  #   DBI::dbExecute(con, query)
  # }

  # ## para las actualizadas a no activas, tenemos que borrar cualquier registro que apunte a ellas desde la tabla licencia
  # if(!is.null(suscripciones_a_actualizar_no_activas) && length(suscripciones_a_actualizar_no_activas)>0){ 
  #   ids_actualizar_no_activas_text = paste("'",suscripciones_a_actualizar_no_activas,"'", sep="", collapse = ", ")

  #   query <- sprintf("SELECT id from SUSCRIPCION WHERE id_stripe_suscripcion in (%s)", ids_actualizar_no_activas_text)
  #   # message(query)
  #   # message(query)
  #   datos <- DBI::dbGetQuery(con, query)

  #   # id de la suscripcion en nuestra tabla SUSCRIPCION
  #   ids_actualizar_no_activas_serial <- datos$id

  #   # borramos de licencias todo lo que tenga que ver con estas ids
  #   ids_text = paste(ids_actualizar_no_activas_serial, collapse = ", ")
  #   query <- sprintf("delete from licencia where fk_suscripcion in (%s);", ids_text)
  #   # message(query)
  #   DBI::dbExecute(con, query)
  # }
  
  # message("paso4")

  # revisar las manuales
  suscripciones_manuales = datos_bd[datos_bd$tipo_suscripcion=="manual" & datos_bd$activa, "id"]  # tipo manual en bd, se guarda el id de la bd serial, solamente se checkea que siguen siendo validas. Las no validas no se checkean
  # message("suscripciones manuales")
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
        # message("cambio a inactiva")
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
      # message(query)
      DBI::dbExecute(con, query)

      # ahora si hay algun registro con estas suscripciones en licencia los quitamos
      query <- sprintf("delete from licencia where fk_suscripcion in (%s);", ids_text)
      DBI::dbExecute(con, query)

    }
  }
  
  # message("llego final")
  # DBI::dbDisconnect(con)

  # permisos, habria que iterar sobre todos los usuarios de psicologo
  # revisar los permisos, se tendrá que ver el rol que tiene el usuario ahora mismo y ver si es consistente con el que debería tener
  ## hay que jugar con suscripciones añadidas, suscripciones actualizadas a activas y no activas y las manuales.
  ## lo mas facil quizá sea comprobar en la bd si se tiene alguna licencia/suscripcion donde este el usuario dado de alta, y comprobar si el rol que tiene concuerda.

  # (copiada de plan_subscription_server) funcion que devuelve el token para acceder a la api de admin
  obtener_token_admin_api <- function(params){
    token_url <- sprintf("https://%s/keycloak/realms/Gridfcm/protocol/openid-connect/token", domain)
    message(token_url)
    params <- list(
        client_id = keycloak_client_id,
        client_secret = keycloak_client_secret,
        grant_type = "client_credentials"
    )
    message(params)
    message(add_headers("Content-Type" = "application/x-www-form-urlencoded"))
    resp <- httr::POST(url = token_url, add_headers("Content-Type" = "application/x-www-form-urlencoded"), body = params, encode="form")
    message(resp)
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

  query <- sprintf("SELECT id, rol, email from psicologo")
  # message(query)
  datos_psicologos <- DBI::dbGetQuery(con, query)
  # message("gestionar roles")

  if(!is.null(datos_psicologos) && length(datos_psicologos$id)>0){
    # message("gestionar roles entro")
    # message(datos_psicologos$id)
    # message(datos_psicologos)
    ## primero, sacamos el token para acceder a la api de admin
    admin_token <- obtener_token_admin_api()

    rol_ilimitado <- '{"id": "c70eddee-5dd0-49ed-8a02-20eeff11d751","name": "usuario_ilimitado"}'
    rol_ilimitado <- jsonlite::fromJSON(rol_ilimitado)

    rol_coordinador <- '{"id": "fcaf869c-dce6-493b-90e9-33a47f027a6c","name": "usuario_coordinador_organizacion"}'
    rol_coordinador <- jsonlite::fromJSON(rol_coordinador)

  
    for(id_psicologo_db in datos_psicologos$id){
      message("entro loop")
      email_psicolog_db = datos_psicologos[datos_psicologos$id==id_psicologo_db, "email"]
      # message(id_psicologo_db)
      # message("entro loop")
      # message(id_psicologo_db)
      rol = datos_psicologos[datos_psicologos$id==id_psicologo_db,"rol"]
      message(rol)
      # message(rol)
      if(rol != "usuario_administrador"){
        # message("gestionar roles entro admin")
        # si no es administrador, tenemos que hacer el checkeo para darle los posibles permisos que le falten, o quitarle los que no deba tener.
        ## miramos si tiene alguna suscripcion activa
        query <- sprintf("SELECT id, organizacion, activa from SUSCRIPCION WHERE fk_psicologo = %d", id_psicologo_db)
        # message(query)
        datos <- DBI::dbGetQuery(con, query)

        suscripciones_activas_organizacion = datos[datos$activa & datos$organizacion, "id"]
        suscripciones_activas_individual = datos[datos$activa & !(datos$organizacion), "id"]

        ## ahora sacamos las licencias activas para este usuario
        query <- sprintf("SELECT id from licencia WHERE fk_psicologo = %d", id_psicologo_db)
        datos <- DBI::dbGetQuery(con, query)
        licencias_activas = datos$id

        # message(suscripciones_activas_organizacion)
        # message(suscripciones_activas_individual)
        # message(licencias_activas)

        # calculamos el rol que debe tener
        rol_debe_tener = "usuario_gratis"
        if(!is.null(suscripciones_activas_organizacion) && length(suscripciones_activas_organizacion)>0){
          rol_debe_tener = "usuario_coordinador_organizacion"
        }else if (!is.null(suscripciones_activas_individual) && length(suscripciones_activas_individual)>0) {
          rol_debe_tener = "usuario_ilimitado"
        }else if (!is.null(licencias_activas) && length(licencias_activas)>0) {
          rol_debe_tener = "usuario_ilimitado"
        }
        # message(rol)
        # message(rol_debe_tener)
        # if(rol != rol_debe_tener){
        #   message("entraria")
        # }
        # message("rol debe tener despues")
        if(rol != rol_debe_tener){
          # message("id psicologo")
          # message(id_psicologo_db)
          

          # message("admin token")
          # message(admin_token)
          ## ahora necesitamos el user id del usuario al que actualizar los roles
          # message(email)
          # message("llego")
          user_id <- obtener_user_id(email_psicolog_db, admin_token)

          # message("user id")
          # message(user_id)
          if(!is.null(user_id) && user_id != ""){
            message("user id not null")
            rol_url <- sprintf("https://%s/keycloak/admin/realms/Gridfcm/users/%s/role-mappings/realm", domain, user_id)
            resp <- httr::GET(url = rol_url, add_headers("Content-Type" = "application/json","Authorization" = paste("Bearer", admin_token, sep = " ")))


            # hacemos el cambio de rol en keycloak, partimos de que el usuario no puede tener el administrador llegados este punto
            if(rol_debe_tener == "usuario_coordinador_organizacion"){
              ## meter usuario_coordinador_organizacion a keycloak y quitar usuario_ilimitado si existiera
              message("haria el cambio en keycloak")
              request_body <- data.frame(
                  id = c(rol_coordinador$id),name = c(rol_coordinador$name)
              )
              request_body_json <- toJSON(request_body, auto_unbox = TRUE)
              resp <- httr::POST(url = rol_url, add_headers("Content-Type" = "application/json","Authorization" = paste("Bearer", admin_token, sep = " ")), body = request_body_json, encode="json")
              # message("roles")
              # message(resp)
              roles <- (httr::content(resp, "text"))
              message(resp)
              if(!is.null(roles) && roles != ""){
                  roles <- jsonlite::fromJSON(roles)
                  if(is.null(roles$error)){
                      message("no error")
                  }else{
                      message("error")
                  }
              }
              ## quitamos usuario_ilimitado por si existiera (aqui se podria ver si el rol actual es ilimitado, y si no es no hace falta hacer la llamada)
              request_body <- data.frame(
                  id = c(rol_ilimitado$id),name = c(rol_ilimitado$name)
              )
              request_body_json <- toJSON(request_body, auto_unbox = TRUE)
              resp <- httr::DELETE (url = rol_url, add_headers("Content-Type" = "application/json","Authorization" = paste("Bearer", admin_token, sep = " ")), body = request_body_json, encode="json")
              roles <- (httr::content(resp, "text"))
              if(!is.null(roles) && roles != ""){
                  roles <- jsonlite::fromJSON(roles)
                  if(is.null(roles$error)){
                      message("no error")
                  }else{
                      message("error")
                  }
              }
              # metemos en psicologo el rol de usuario_coordinador_organizacion
              query <- sprintf("update psicologo as p set
                rol = 'usuario_coordinador_organizacion' 
                where p.id = %d;", id_psicologo_db)
              # message(query)
              DBI::dbExecute(con, query)


            }else if (rol_debe_tener == "usuario_ilimitado") {
              ## meter usuario ilimitado 
              message("entro usuario_ilimitado")
              request_body <- data.frame(
                  id = c(rol_ilimitado$id),name = c(rol_ilimitado$name)
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
              
              ## quitar usuario_coordinador_organizacion si existiera
              request_body <- data.frame(
                  id = c(rol_coordinador$id),name = c(rol_coordinador$name)
              )
              request_body_json <- toJSON(request_body, auto_unbox = TRUE)
              resp <- httr::DELETE (url = rol_url, add_headers("Content-Type" = "application/json","Authorization" = paste("Bearer", admin_token, sep = " ")), body = request_body_json, encode="json")
              roles <- (httr::content(resp, "text"))
              if(!is.null(roles) && roles != ""){
                  roles <- jsonlite::fromJSON(roles)
                  if(is.null(roles$error)){
                      message("no error")
                  }else{
                      message("error")
                  }
              }

              # metemos en psicologo el rol de usuario_ilimitado
              query <- sprintf("update psicologo as p set
                rol = 'usuario_ilimitado' 
                where p.id = %d;", id_psicologo_db)
              # message(query)
              DBI::dbExecute(con, query)

            }else if (rol_debe_tener == "usuario_gratis") {
              ## meter usuario gratis
              message("entro usuario gratis")
              ## quitar usuario_coordinador_organizacion y usuario_ilimitado si existieran
              request_body <- data.frame(
                  id = c(rol_coordinador$id, rol_ilimitado$id),name = c(rol_coordinador$name, rol_ilimitado$name)
              )
              request_body_json <- toJSON(request_body, auto_unbox = TRUE)
              resp <- httr::DELETE (url = rol_url, add_headers("Content-Type" = "application/json","Authorization" = paste("Bearer", admin_token, sep = " ")), body = request_body_json, encode="json")
              roles <- (httr::content(resp, "text"))
              if(!is.null(roles) && roles != ""){
                  roles <- jsonlite::fromJSON(roles)
                  if(is.null(roles$error)){
                      message("no error")
                  }else{
                      message("error")
                  }
              }

              # metemos en psicologo el rol de usuario_gratis
              query <- sprintf("update psicologo as p set
                rol = 'usuario_gratis' 
                where p.id = %d;", id_psicologo_db)
              # message(query)
              DBI::dbExecute(con, query)


            }



          }else{
            message("user id null")
          }
          # message(user_id)

          # rol_url <- sprintf("https://%s/keycloak/admin/realms/Gridfcm/users/%s/role-mappings/realm", domain, user_id)
          # resp <- httr::GET(url = rol_url, add_headers("Content-Type" = "application/json","Authorization" = paste("Bearer", admin_token, sep = " ")))
          # message("roles")
          # message(resp)

          
          # message(rol_debe_tener)




        }
      }
    }
  }
  DBI::dbDisconnect(con)
  message("acabo final del todo")
}

# install.packages("DBI")
# install.packages("RPostgres")
# install.packages("DBI")
# install.packages("DBI")
# syncStripeDBProcess()
