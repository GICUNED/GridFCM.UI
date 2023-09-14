codificar_excel_BD <- function(excel, tabla_destino, id_paciente){
    con <- establishDBConnection()
    t_inicio <- Sys.time()
    fecha <- as.POSIXct(Sys.time(), origin = "1970-01-01")
    fecha <- format(fecha, format = "%Y-%m-%d %H:%M:%S", tz = "Europe/Madrid")
    message(fecha)
    # consultar max id y meter manual
    # Consultar el máximo valor actual de 'id'
    max_id <- as.integer(DBI::dbGetQuery(con, sprintf("SELECT MAX(id) FROM %s", tabla_destino)))
    if (!is.na(max_id)) {
        id <- max_id + 1
    } else {
        id <- 1
    }
    for(i in 1:nrow(excel)){
        for(j in 1:ncol(excel)){
            fila <- i
            columna <- j
            valor <- as.character(excel[i, j])
            query <- sprintf("INSERT INTO %s (id, fila, columna, valor, fecha_registro, fk_paciente) VALUES (%d, %d, %d, '%s', '%s', %d)", 
                            tabla_destino, id, fila, columna, valor, fecha, id_paciente)
            DBI::dbExecute(con, query)
        }
    }
    t_fin <- Sys.time()
    t_total <- t_fin - t_inicio
    message(paste(t_total, "segundos"))
    DBI::dbDisconnect(con)

    return(fecha)
} 


decodificar_BD_excel <- function(tabla_origen, ruta_destino, id_paciente, fecha_registro='') {
    con <- establishDBConnection()
    id <- 0
    # Consultar los datos de la tabla
    if(fecha_registro==''){
        query <- sprintf("SELECT id, fila, columna, valor FROM %s WHERE fk_paciente = %d and id = (SELECT MAX(id) FROM %s WHERE fk_paciente = %d)", 
                tabla_origen, id_paciente, tabla_origen, id_paciente)
        datos <- DBI::dbGetQuery(con, query)
        id <- max(datos$id) # último id insertado?? puede que falle esto 
    }
    else{
        query <- sprintf("SELECT id, fila, columna, valor FROM %s WHERE fk_paciente = %d and fecha_registro = '%s'", tabla_origen, id_paciente, fecha_registro)
        datos <- DBI::dbGetQuery(con, query)
        id <- unique(datos$id)
    }
    
    # Identificar el número máximo de filas y columnas
    filas_max <- max(datos$fila)
    columnas_max <- max(datos$columna)
    
    
    # Crear una matriz vacía para almacenar los datos
    #matriz_strings <- matrix("", nrow = filas_max, ncol = columnas_max)
    #matriz_integers <- matrix(integer(), nrow = filas_max, ncol = columnas_max)
    matriz <- matrix("", nrow = filas_max, ncol = columnas_max)
    
    # Llenar la matriz con los valores recuperados
    for (i in 1:nrow(datos)) {
        fila <- datos$fila[i]
        columna <- datos$columna[i]
        valor <- datos$valor[i]
        matriz[fila, columna] <- valor
    }
    
    # Convertir la matriz en un data frame
    #df_datos <- as.data.frame(matriz_integers)
    #df_datos_int <- as.data.frame(matriz_integers)

    wb <- createWorkbook()
    addWorksheet(wb, "Sheet 1")
    #addWorksheet(wb, "Sheet 2")

    writeData(wb, sheet="Sheet 1", matriz, rowNames=FALSE, colNames=FALSE)
    #writeData(wb, sheet="Sheet 2", matriz_integers, rowNames=FALSE)
    saveWorkbook(wb, ruta_destino, overwrite=TRUE)

    #sheet1 <- readxl::read_excel(ruta_destino, sheet="Sheet 1")
    #sheet2 <- readxl::read_excel(ruta_destino, sheet="Sheet 2")

    #combined_data <- data.frame(
     #   V1 = coalesce(sheet1$V1, sheet2$V1),
      #  V2 = coalesce(sheet1$V2, sheet2$V2),
       # V3 = coalesce(sheet1$V3, sheet2$V3)
    #)
    #message(sheet2[5,5])
    #message(class(sheet2[5,5]))

    #write.xlsx(combined_data, ruta_destino, rowNames = FALSE, overwrite=TRUE)
    
    DBI::dbDisconnect(con)
    return(id)
}
