-- Instalación nueva. Para actualizar una base anterior utilizar migrations/001_seguridad.sql.
CREATE DATABASE IF NOT EXISTS bd_aplicacion_movil CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bd_aplicacion_movil;

CREATE TABLE IF NOT EXISTS usuario (
    id_usr INT AUTO_INCREMENT PRIMARY KEY,
    nom_usr VARCHAR(100) NOT NULL,
    mail VARCHAR(150) NOT NULL UNIQUE,
    pass VARCHAR(255) NOT NULL,
    dir_usr VARCHAR(200),
    tip_usu INT NOT NULL DEFAULT 2
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS blog (
    id_blog INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    `desc` TEXT,
    img VARCHAR(500),
    tags VARCHAR(255),
    usr_id INT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX ix_blog_usr_id (usr_id),
    FOREIGN KEY (usr_id) REFERENCES usuario(id_usr)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS comentarios (
    id_com INT AUTO_INCREMENT PRIMARY KEY,
    comentario TEXT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estatus INT NOT NULL DEFAULT 1,
    usr_id INT NOT NULL,
    blog_id INT NOT NULL,
    FOREIGN KEY (usr_id) REFERENCES usuario(id_usr),
    FOREIGN KEY (blog_id) REFERENCES blog(id_blog)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sesiones (
    id_sesion INT AUTO_INCREMENT PRIMARY KEY,
    usr_id INT NOT NULL,
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    expira DATETIME NOT NULL,
    INDEX ix_sesiones_usr_id (usr_id),
    INDEX ix_sesiones_expira (expira),
    FOREIGN KEY (usr_id) REFERENCES usuario(id_usr)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS valoraciones (
    id_val INT AUTO_INCREMENT PRIMARY KEY,
    usr_id INT NOT NULL,
    blog_id INT NOT NULL,
    puntos INT NOT NULL,
    CONSTRAINT uq_voto_usuario_blog UNIQUE (usr_id, blog_id),
    CONSTRAINT ck_puntos CHECK (puntos BETWEEN 1 AND 5),
    INDEX ix_valoraciones_usr_id (usr_id),
    INDEX ix_valoraciones_blog_id (blog_id),
    FOREIGN KEY (usr_id) REFERENCES usuario(id_usr),
    FOREIGN KEY (blog_id) REFERENCES blog(id_blog)
) ENGINE=InnoDB;

-- Sin usuarios, contraseñas o hashes de prueba predeterminados.
-- Crear Administrador con python manage.py create-admin --mail TU_CORREO
