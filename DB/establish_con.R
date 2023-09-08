establishDBConnection <- function() {
    db_host <- 'postgres'#Sys.getenv("DB_HOST")
    db_port <- '5432'#Sys.getenv("DB_PORT")
    db_name <- 'gridfcm'#Sys.getenv("DB_NAME")
    db_user <- 'gridfcm'#Sys.getenv("DB_USER")
    db_password <- 'password'#Sys.getenv("DB_PASSWORD")
    #message(paste("variables >>>> ", db_host, db_port, db_name))
    
    # Create a connection
    
    con <- DBI::dbConnect(
              RPostgres::Postgres(),
              host = db_host,
              port = db_port,
              dbname = db_name,
              user = db_user,
              password = db_password)

    return(con)
  }
