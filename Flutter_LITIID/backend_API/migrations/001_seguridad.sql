-- Ejecutar UNA VEZ sobre el esquema original, con respaldo previo.
-- Cambiar USE si la base tiene otro nombre. No borra registros existentes.
USE bd_aplicacion_movil;
ALTER TABLE usuario ALTER COLUMN tip_usu SET DEFAULT 2;
ALTER TABLE blog
    ADD COLUMN usr_id INT NULL,
    ADD COLUMN fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD INDEX ix_blog_usr_id (usr_id),
    ADD CONSTRAINT fk_blog_autor FOREIGN KEY (usr_id) REFERENCES usuario(id_usr);

CREATE TABLE sesiones (
    id_sesion INT AUTO_INCREMENT PRIMARY KEY,
    usr_id INT NOT NULL,
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    expira DATETIME NOT NULL,
    INDEX ix_sesiones_usr_id (usr_id),
    INDEX ix_sesiones_expira (expira),
    FOREIGN KEY (usr_id) REFERENCES usuario(id_usr)
) ENGINE=InnoDB;
CREATE TABLE valoraciones (
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
-- Las entradas anteriores conservan usr_id NULL: no se inventa una autoría.
-- Su fecha es la de migración, no la fecha histórica de publicación.
-- HASH_DE_PRUEBA no es válido: registra cuentas nuevas o restablece hashes mediante administración local.
