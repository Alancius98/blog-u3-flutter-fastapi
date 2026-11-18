"""Base MySQL separada de prueba; no modifica el .env original ni la BD del estudiante."""
import json
import secrets
from pathlib import Path

import pymysql

root = Path(__file__).resolve().parents[1]
runtime = root / 'entrega_blog_u3/.runtime'
db_name = 'bd_blog_estructura_u3'
password = secrets.token_urlsafe(24)
connection = pymysql.connect(unix_socket=str(runtime/'mysql.sock'), user='root', password=(runtime/'root-password').read_text(), autocommit=True)
with connection.cursor() as cursor:
    sql = (root/'Flutter_LITIID/backend_API/bd.sql').read_text().replace('bd_aplicacion_movil', db_name)
    sql = '\n'.join(line for line in sql.splitlines() if not line.startswith('--'))
    for statement in sql.split(';'):
        if statement.strip(): cursor.execute(statement)
    cursor.execute('CREATE USER IF NOT EXISTS %s@%s IDENTIFIED BY %s', ('estructura_app', '127.0.0.1', password))
    cursor.execute('ALTER USER %s@%s IDENTIFIED BY %s', ('estructura_app', '127.0.0.1', password))
    cursor.execute('GRANT SELECT,INSERT,UPDATE,DELETE ON bd_blog_estructura_u3.* TO %s@%s', ('estructura_app', '127.0.0.1'))
env = runtime/'estructura.env'
env.write_text(f'DATABASE_URL=mysql+pymysql://estructura_app:{password}@127.0.0.1:3307/{db_name}?charset=utf8mb4\nCORS_ORIGINS=http://127.0.0.1:8080,http://localhost:8080\n')
env.chmod(0o600)
print('Base aislada preparada; .env original sin cambios. Configuración privada:', env)
