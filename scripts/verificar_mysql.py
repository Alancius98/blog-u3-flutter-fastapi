"""Pruebas de integración sobre la base local de ensayo; nunca usar en producción."""
import json
import secrets
import sys
from pathlib import Path

import httpx
from dotenv import load_dotenv
from sqlalchemy import select

root = Path(__file__).resolve().parents[1]
load_dotenv(root/'entrega_blog_u3/.runtime/estructura.env', override=True)
sys.path.insert(0, str(root/'Flutter_LITIID/backend_API'))
from database import SessionLocal
from models import Usuario, Sesion
from security import password_hash

out = root/'reportes/evidencias'
out.mkdir(parents=True, exist_ok=True)
client = httpx.Client(base_url='http://127.0.0.1:8000')
password = secrets.token_urlsafe(24)
email = f'integracion.{secrets.token_hex(5)}@example.com'
admin_email = f'admin.{secrets.token_hex(5)}@example.com'
created = client.post('/usuarios', json={'nom_usr':'Usuario de integración','mail':email,'password':password})
created.raise_for_status()
with SessionLocal() as db:
    db.add(Usuario(nom_usr='Administrador de integración',mail=admin_email,pass_hash=password_hash.hash(password),tip_usu=1))
    db.commit()
def login(mail):
    r=client.post('/login',json={'mail':mail,'password':password});r.raise_for_status()
    return {'Authorization':'Bearer '+r.json()['access_token']}
h=login(email); a=login(admin_email)
checks={'mysql_real':client.get('/').json()['database']=='mysql',
        'registro_general':created.json()['tip_usu']==2,
        'usuario_no_lista_cuentas':client.get('/usuarios',headers=h).status_code==403,
        'admin_lista_cuentas':client.get('/usuarios',headers=a).status_code==200,
        'registro_no_crea_admin':client.post('/usuarios',json={'nom_usr':'Falso admin','mail':'fake@example.com','password':password,'tip_usu':1}).status_code==403}
post=client.post('/blog',headers=h,json={'titulo':'Integración temporal','descripcion':'MySQL real','tags':'Flutter'})
post.raise_for_status(); id=post.json()['id_blog']
checks['autoria_sesion']=post.json()['usr_id']==created.json()['id_usr']
c=client.post('/comentarios',headers=h,json={'blog_id':id,'comentario':'Comentario Unicode 🌿'})
c.raise_for_status()
checks['comentario_lectura']=client.get('/comentarios',headers=a,params={'blog_id':id}).json()[0]['comentario']=='Comentario Unicode 🌿'
client.put(f'/blog/{id}/valoracion',headers=h,json={'puntos':5}).raise_for_status()
client.put(f'/blog/{id}/valoracion',headers=a,json={'puntos':3}).raise_for_status()
r=client.put(f'/blog/{id}/valoracion',headers=h,json={'puntos':1}).json()
checks['voto_unico_promedio']=r['votos']==2 and r['promedio']==2
checks['busqueda_servidor']=client.get('/blog',headers=h,params={'q':'Integración temporal','propios':True}).json()[0]['id_blog']==id
checks['edicion_admin']=client.put('/blog',headers=a,json={'id_blog':id,'titulo':'Moderada','descripcion':'Verificada'}).status_code==200
checks['comentario_admin']=client.delete('/comentarios',headers=a,params={'id_com':c.json()['id_com']}).status_code==204
checks['retiro_valoracion']=client.delete(f'/blog/{id}/valoracion',headers=a).json()['votos']==1
checks['borrado_publicacion']=client.delete('/blog',headers=h,params={'id_blog':id}).status_code==204
checks['logout']=client.post('/logout',headers=h).status_code==204
checks['token_revocado']=client.get('/blog',headers=h).status_code==401
client.post('/logout',headers=a).raise_for_status()
assert all(checks.values()), checks
(out/'integracion_mysql.json').write_text(json.dumps(checks,ensure_ascii=False,indent=2))
print(json.dumps(checks,ensure_ascii=False))
