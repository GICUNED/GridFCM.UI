establishDBConnection <- function() {
    db_user <- 'postgres'
    db_password <- 'password'
    db_host <- 'postgres'
    db_port <- '5432'
    db_name <- 'postgres'
    
    # Create a connection
    
    con <- DBI::dbConnect(
              RPostgres::Postgres(),
              user = db_user,
              password = db_password,
              host = db_host,
              port = db_port,
              dbname = db_name)

    return(con)
  }