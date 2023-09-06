-- Crear tabla psicologo si no existe
CREATE TABLE IF NOT EXISTS psicologo (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR,
    email VARCHAR
);

-- Crear tabla paciente si no existe
CREATE TABLE IF NOT EXISTS paciente (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR,
    edad INT,
    genero VARCHAR(15) CHECK (genero IN ('Hombre', 'Mujer', 'Sin definir')),
    anotaciones TEXT,
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
    valor varchar(40),
    fecha_registro TIMESTAMP,
    fk_paciente INT REFERENCES paciente(id),
    PRIMARY KEY (id, fila, columna)
);

CREATE TABLE IF NOT EXISTS wimpgrid_xlsx (
    id SERIAL,
    fila INTEGER,
    columna INTEGER,
    valor varchar(40),
    fecha_registro TIMESTAMP,
    fk_paciente INT REFERENCES paciente(id),
    PRIMARY KEY (id, fila, columna)
);

/*
CREATE TABLE IF NOT EXISTS wimpgrid_params (
    id SERIAL PRIMARY KEY,
    -- simdigraph
    sim_design varchar(25),
    sim_umbral varchar(25),
    sim_n_iter INTEGER,
    sim_n_max_iter INTEGER,
    sim_n_stop_iter INTEGER,
    sim_valor_diferencial INTEGER,
    -- falta el vector que no se como aun

    -- pcsd
    pcsd_n_iter INTEGER,
    pcsd_n_max_iter INTEGER,
    pcsd_n_stop_iter INTEGER,
    pcsd_valor_diferencial INTEGER,
    -- vector

    -- pcsd índices
    pcind_propagacion VARCHAR(50),
    pcind_umbral VARCHAR(25),
    pcind_n_max_iter INTEGER,
    pcind_n_stop_iter INTEGER,
    pcind_valor_diferencial INTEGER,
    -- vector

    fk_wimpgrid INT REFERENCES wimpgrid_xlsx(id)
)
*/

-- Seeder de prueba
INSERT INTO psicologo (nombre, email)
VALUES ('Luis Ángel', 'la@uned.com');
