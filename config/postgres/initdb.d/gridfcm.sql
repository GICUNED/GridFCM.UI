-- Crear tabla psicologo si no existe
CREATE TABLE IF NOT EXISTS psicologo (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR,
    email VARCHAR UNIQUE,
    username VARCHAR,
    token TEXT,
    refresh_token TEXT,
    rol VARCHAR
);

-- Crear tabla paciente si no existe
CREATE TABLE IF NOT EXISTS paciente (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR,
    edad INT,
    genero VARCHAR(15) CHECK (genero IN ('Hombre', 'Mujer', 'Sin definir')),
    anotaciones TEXT,
    diagnostico TEXT,
    fecha_registro TIMESTAMP
);

-- Crear tabla intermedia para la relación muchos a muchos si no existe
CREATE TABLE IF NOT EXISTS psicologo_paciente (
    id SERIAL PRIMARY KEY,
    fk_psicologo INT REFERENCES psicologo(id),
    fk_paciente INT REFERENCES paciente(id)
);

CREATE TABLE IF NOT EXISTS repgrid_xlsx (
    id SERIAL,
    fila INTEGER,
    columna INTEGER,
    valor varchar(100),
    fecha_registro TIMESTAMP,
    comentarios TEXT,
    fk_paciente INT REFERENCES paciente(id),
    PRIMARY KEY (id, fila, columna)
);

CREATE TABLE IF NOT EXISTS wimpgrid_xlsx (
    id SERIAL,
    fila INTEGER,
    columna INTEGER,
    valor varchar(100),
    fecha_registro TIMESTAMP,
    fk_paciente INT REFERENCES paciente(id),
    PRIMARY KEY (id, fila, columna)
);

CREATE TABLE IF NOT EXISTS wimpgrid_params (
    id SERIAL PRIMARY KEY,
    fk_wimpgrid INTEGER,
    fk_fila INTEGER,
    fk_columna INTEGER,
    comentarios TEXT,
    -- simdigraph
    sim_design varchar(25),
    sim_umbral varchar(25),
    sim_n_iter INTEGER,
    sim_n_max_iter INTEGER,
    sim_n_stop_iter INTEGER,
    sim_color varchar(25),
    sim_valor_diferencial DECIMAL(8, 6),
    sim_vector varchar(150),
    -- falta el vector que no se como aun

    -- pcsd
    pcsd_n_iter INTEGER,
    pcsd_n_max_iter INTEGER,
    pcsd_n_stop_iter INTEGER,
    pcsd_valor_diferencial DECIMAL(8, 6),
    pcsd_vector varchar(150),
    -- vector

    -- pcsd índices
    pcind_propagacion VARCHAR(50),
    pcind_umbral VARCHAR(25),
    pcind_n_max_iter INTEGER,
    pcind_n_stop_iter INTEGER,
    pcind_valor_diferencial DECIMAL(8, 6),
    pcind_vector varchar(150),
    -- vector

    FOREIGN KEY(fk_wimpgrid, fk_fila, fk_columna) REFERENCES wimpgrid_xlsx(id, fila, columna)
);

CREATE TABLE IF NOT EXISTS sugerencias (
    id serial PRIMARY KEY,
    sugerencia text,
    fk_psicologo integer REFERENCES psicologo(id),
    fecha timestamp
);



-- Seeder de prueba
INSERT INTO psicologo (nombre, email)
VALUES ('Psicólogo de prueba', 'demo@uned.com');
