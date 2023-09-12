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
              password = db_password)

    return(con)
  }
