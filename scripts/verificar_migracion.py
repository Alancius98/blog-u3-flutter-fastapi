"""Ensaya la migración sobre una copia del esquema original, sin tocar la BD del usuario."""
import json
from pathlib import Path
import pymysql

root=Path(__file__).resolve().parents[1]
runtime=root/'entrega_blog_u3/.runtime'
name='bd_migracion_original_u3'
db=pymysql.connect(unix_socket=str(runtime/'mysql.sock'),user='root',password=(runtime/'root-password').read_text(),autocommit=True)
with db.cursor() as c:
    c.execute('CREATE DATABASE IF NOT EXISTS bd_migracion_original_u3 CHARACTER SET utf8mb4')
    c.execute('USE bd_migracion_original_u3')
    c.execute('SHOW TABLES')
    if c.fetchall(): raise SystemExit('La base de prueba ya tiene tablas; no se sobreescribe.')
    c.execute('CREATE TABLE usuario (id_usr INT AUTO_INCREMENT PRIMARY KEY,nom_usr VARCHAR(100) NOT NULL,mail VARCHAR(150) NOT NULL UNIQUE,pass VARCHAR(255) NOT NULL,dir_usr VARCHAR(200),tip_usu INT NOT NULL DEFAULT 1) ENGINE=InnoDB')
    c.execute('CREATE TABLE blog (id_blog INT AUTO_INCREMENT PRIMARY KEY,titulo VARCHAR(150) NOT NULL,`desc` TEXT,img VARCHAR(500),tags VARCHAR(255)) ENGINE=InnoDB')
    c.execute('CREATE TABLE comentarios (id_com INT AUTO_INCREMENT PRIMARY KEY,comentario TEXT NOT NULL,fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,estatus INT NOT NULL DEFAULT 1,usr_id INT NOT NULL,blog_id INT NOT NULL,FOREIGN KEY (usr_id) REFERENCES usuario(id_usr),FOREIGN KEY (blog_id) REFERENCES blog(id_blog)) ENGINE=InnoDB')
    c.execute("INSERT INTO usuario(nom_usr,mail,pass,tip_usu) VALUES('Usuario anterior','anterior@example.com','HASH_DE_PRUEBA',2)")
    c.execute("INSERT INTO blog(titulo,`desc`) VALUES('Entrada anterior','Contenido conservado')")
    c.execute("INSERT INTO comentarios(comentario,usr_id,blog_id) VALUES('Comentario anterior',1,1)")
    sql=(root/'Flutter_LITIID/backend_API/migrations/001_seguridad.sql').read_text().replace('bd_aplicacion_movil',name)
    sql='\n'.join(line for line in sql.splitlines() if not line.startswith('--'))
    for statement in sql.split(';'):
        if statement.strip(): c.execute(statement)
    c.execute('SELECT titulo,`desc`,usr_id FROM blog WHERE id_blog=1'); post=c.fetchone()
    c.execute('SELECT comentario FROM comentarios WHERE id_com=1'); comment=c.fetchone()
    c.execute('SHOW TABLES'); tables={r[0] for r in c.fetchall()}
    c.execute("SHOW COLUMNS FROM usuario LIKE 'tip_usu'"); default=c.fetchone()[4]
    checks={'contenido_conservado':post[:2]==('Entrada anterior','Contenido conservado'),'autor_no_inventado':post[2] is None,'comentario_conservado':comment[0]=='Comentario anterior','tablas_nuevas':{'sesiones','valoraciones'}.issubset(tables),'registro_general_por_defecto':str(default)=='2'}
assert all(checks.values()),checks
out=root/'reportes/evidencias';out.mkdir(parents=True,exist_ok=True)
(out/'migracion_mysql.json').write_text(json.dumps(checks,ensure_ascii=False,indent=2))
print(json.dumps(checks,ensure_ascii=False))
