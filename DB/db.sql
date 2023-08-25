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
    genero VARCHAR(15) CHECK (genero IN ('hombre', 'mujer', 'no definido')),
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
    id INTEGER PRIMARY KEY,
    repgridtxt TEXT
);
