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

-- Crear tabla repgrid si no existe
CREATE TABLE IF NOT EXISTS repgrid (
    id SERIAL PRIMARY KEY,
    repgridtxt TEXT,
    fk_paciente INT REFERENCES paciente(id)
);

-- Crear tabla wimpgrid si no existe
CREATE TABLE IF NOT EXISTS wimpgrid (
    id SERIAL PRIMARY KEY,
    wimpgridtxt TEXT,
    fk_paciente INT REFERENCES paciente(id)
    -- faltaria añadir los controles para poder guardar la simulación....
);

-- Seeder de prueba
INSERT INTO psicologo (nombre, email)
VALUES ('Luis Ángel', 'la@uned.com');
