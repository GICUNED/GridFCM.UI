establishDBConnection <- function() {
    db_host <- 'postgres'
    db_port <- '5432'
    db_name <- 'gridfcm'
    db_user <- 'gridfcm'
    db_password <- 'password'
    
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
