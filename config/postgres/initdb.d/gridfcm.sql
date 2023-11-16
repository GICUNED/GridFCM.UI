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

-- Tabla para almacenar los usuarios demo para luego enviar publi
CREATE TABLE IF NOT EXISTS usuario_demo (
  id serial PRIMARY KEY,
  email varchar(75) NOT NULL
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

CREATE TABLE IF NOT EXISTS suscripcion (
    id SERIAL PRIMARY KEY,
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    licencias_contratadas INTEGER,
    licencias_disponibles INTEGER,
    organizacion BOOLEAN,
    activa BOOLEAN,
    fk_psicologo INT REFERENCES psicologo(id)
);

CREATE TABLE IF NOT EXISTS licencia (
    id SERIAL PRIMARY KEY,
    fk_psicologo INT REFERENCES psicologo(id),
    fk_suscripcion INT REFERENCES suscripcion(id)
);


-- Seeder para el psicologo de pruebas para el usuario demo
INSERT INTO psicologo (nombre, email, username, rol)
VALUES ('Caso de prueba', 'prueba@uned.com', 'prueba', 'usuario_demo');

-- Insertar el paciente en la tabla "paciente" con la fecha de registro específica
WITH paciente_insert AS (
  INSERT INTO paciente (nombre, edad, genero, fecha_registro)
  VALUES ('Caso de prueba', 40, 'Sin definir', '2023-10-30 09:41:55')
  RETURNING id
)

-- Insertar la relación en la tabla intermedia "psicologo_paciente" usando el "id" del psicólogo
INSERT INTO psicologo_paciente (fk_psicologo, fk_paciente)
SELECT p.id, pi.id
FROM psicologo AS p
CROSS JOIN paciente_insert AS pi
WHERE p.email = 'prueba@uned.com' and p.username = 'prueba';