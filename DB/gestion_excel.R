codificar_excel_BD <- function(excel, tabla_destino, id_paciente){
    con <- establishDBConnection()
    t_inicio <- Sys.time()
    fecha <- Sys.time()
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
    message(t_total)

    DBI::dbDisconnect(con)
} 

decodificar_BD_excel <- function(tabla_origen, ruta_destino, id_paciente) {
    con <- establishDBConnection()
    
    # Consultar los datos de la tabla
    query <- sprintf("SELECT fila, columna, valor FROM %s WHERE fk_paciente = %d", tabla_origen, id_paciente)
    datos <- DBI::dbGetQuery(con, query)
    
    # Identificar el número máximo de filas y columnas
    filas_max <- max(datos$fila)
    columnas_max <- max(datos$columna)
    
    # Crear una matriz vacía para almacenar los datos
    matriz_datos <- matrix("", nrow = filas_max, ncol = columnas_max)
    
    # Llenar la matriz con los valores recuperados
    for (i in 1:nrow(datos)) {
        fila <- datos$fila[i]
        columna <- datos$columna[i]
        valor <- datos$valor[i]
        matriz_datos[fila, columna] <- valor
    }
    
    # Convertir la matriz en un data frame
    df_datos <- as.data.frame(matriz_datos)
    
    # Escribir el data frame en un archivo Excel
    write.xlsx(df_datos, ruta_destino, rowNames = FALSE, colNames = FALSE)
    
    DBI::dbDisconnect(con)
}
