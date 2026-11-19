"""Recorrido de Flutter real con FastAPI y MySQL, sobre una BD separada de ensayo."""
import json
import os
import re
import secrets
import sys
import time
from pathlib import Path

import httpx
from dotenv import load_dotenv
from playwright.sync_api import sync_playwright, Locator
from sqlalchemy import select, text

root = Path(__file__).resolve().parents[1]
runtime = root/'entrega_blog_u3/.runtime'
load_dotenv(runtime/'estructura.env', override=True)
sys.path.insert(0, str(root/'Flutter_LITIID/backend_API'))
from database import engine, SessionLocal
from models import Usuario
from security import password_hash

out=root/'reportes/evidencias'
out.mkdir(parents=True,exist_ok=True)
client=httpx.Client(base_url='http://127.0.0.1:8000')
suffix=str(time.time_ns())
mail=f'usuario.{suffix}@example.com'
password='PruebaMovil2026!'
admin_mail=f'admin.{suffix}@example.com'
admin_password=secrets.token_urlsafe(24)
with SessionLocal() as db:
    db.add(Usuario(nom_usr='Administrador',mail=admin_mail,pass_hash=password_hash.hash(admin_password),tip_usu=1))
    db.commit()
admin_token=client.post('/login',json={'mail':admin_mail,'password':admin_password}).json()['access_token']
ah={'Authorization':'Bearer '+admin_token}
publicacion=client.post('/blog',headers=ah,json={'titulo':'Aprender con Flutter','descripcion':'Esta publicación pertenece a otra cuenta. El contenido se consulta desde MySQL mediante FastAPI.','tags':'Flutter'})
publicacion.raise_for_status(); foreign_id=publicacion.json()['id_blog']

def escribir(locator, value, **kwargs):
    locator.click(); locator.page.wait_for_timeout(200)
    locator.page.keyboard.press('Meta+A' if sys.platform=='darwin' else 'Control+A')
    locator.page.keyboard.press('Backspace')
    locator.page.keyboard.type(value,delay=15)
    locator.page.wait_for_timeout(100)
Locator.fill=escribir

with sync_playwright() as p:
    browser=p.chromium.launch()
    context=browser.new_context(viewport={'width':1280,'height':900},record_video_dir=str(runtime/'video_estructura'),record_video_size={'width':1280,'height':900})
    page=context.new_page()
    errores=[]
    page.on('pageerror',lambda e:errores.append(str(e)))
    page.goto('http://127.0.0.1:8080')
    page.locator('flutter-view').wait_for()
    page.locator('flt-semantics-placeholder').evaluate('(e)=>e.click()')
    page.get_by_role('button',name='Iniciar sesión',exact=True).click()
    page.get_by_role('button',name='INGRESAR',exact=True).wait_for()
    def foto(name):
        page.wait_for_timeout(650)
        page.screenshot(path=str(out/name))
    foto('01_login.png')
    page.get_by_role('button',name='Registrarse',exact=True).click()
    page.get_by_role('textbox',name='Nombre completo',exact=True).fill('Usuario')
    page.get_by_role('textbox',name='Correo electrónico',exact=True).fill(mail)
    page.get_by_role('textbox',name='Dirección',exact=True).fill('Querétaro')
    page.get_by_role('textbox',name='Contraseña',exact=True).fill(password)
    foto('02_registro.png')
    page.get_by_role('button',name='REGISTRARME',exact=True).click()
    page.get_by_role('button',name='INGRESAR',exact=True).wait_for()
    page.get_by_role('textbox',name='Correo electrónico',exact=True).fill(mail)
    page.get_by_role('textbox',name='Contraseña',exact=True).fill('Incorrecta123!')
    page.get_by_role('button',name='INGRESAR',exact=True).click()
    page.get_by_text('Correo o contraseña incorrectos',exact=True).last.wait_for()
    foto('03_error_login.png')
    page.get_by_role('textbox',name='Contraseña',exact=True).fill(password)
    page.get_by_role('button',name='INGRESAR',exact=True).click()
    page.get_by_text('Mi Blog',exact=True).wait_for()
    foto('04_blog.png')
    page.get_by_role('button',name='Escribir',exact=True).click()
    page.get_by_role('textbox',name='Título',exact=True).fill('Mi publicación desde Flutter')
    page.get_by_role('textbox',name='Descripción',exact=True).fill('El contenido se envía a FastAPI y se guarda en MySQL. La publicación debe seguir disponible después de cerrar y volver a iniciar sesión.')
    page.get_by_role('textbox',name='Etiquetas (opcional)',exact=True).fill('Flutter')
    foto('05_crear_blog.png')
    page.get_by_role('button',name='Guardar publicación',exact=True).click()
    page.get_by_text('Publicación agregada correctamente',exact=True).last.wait_for()
    page.get_by_role('button',name='Back',exact=True).click()
    page.get_by_role('button',name=re.compile('Abrir publicación: Mi publicación desde Flutter')).first.click()
    page.get_by_role('textbox',name='Tu comentario',exact=True).fill('Comentario persistido desde la aplicación.')
    page.get_by_role('button',name='Comentar',exact=True).click()
    page.get_by_role('button',name='Eliminar comentario',exact=True).wait_for()
    foto('06_comentarios.png')
    page.get_by_role('button',name='Valorar con 5 estrellas',exact=True).click()
    page.get_by_role('button',name='Quitar mi valoración',exact=True).wait_for()
    foto('07_valoracion.png')
    page.get_by_role('button',name='Editar publicación',exact=True).click()
    page.get_by_role('textbox',name='Título',exact=True).fill('Mi publicación desde Flutter actualizada')
    page.get_by_role('button',name='Guardar publicación',exact=True).click()
    page.get_by_text('Mi Blog',exact=True).wait_for()
    page.get_by_role('checkbox',name='Mis publicaciones',exact=True).click()
    foto('08_propios.png')
    page.get_by_role('textbox',name='Buscar publicaciones',exact=True).fill('actualizada')
    foto('09_busqueda.png')
    page.get_by_role('textbox',name='Buscar publicaciones',exact=True).fill('')
    page.get_by_role('checkbox',name='Todas las publicaciones',exact=True).click()
    page.get_by_role('button',name=re.compile('Aprender con Flutter')).first.click()
    assert page.get_by_role('button',name='Editar publicación',exact=True).count()==0
    page.get_by_role('textbox',name='Tu comentario',exact=True).fill('Puedo comentar en una publicación de otra cuenta.')
    page.get_by_role('button',name='Comentar',exact=True).click()
    page.get_by_role('button',name='Eliminar comentario',exact=True).wait_for()
    foto('10_ajenos.png')
    page.get_by_role('button',name='Back',exact=True).click()
    page.get_by_text('Mi Blog',exact=True).wait_for()
    page.wait_for_timeout(500)
    page.get_by_role('button',name=re.compile('Open navigation menu')).click()
    page.get_by_text('Mi perfil',exact=True).click()
    page.get_by_role('textbox',name='Nombre completo',exact=True).fill('Usuario actualizado')
    page.get_by_role('button',name='Guardar cambios',exact=True).click()
    page.get_by_text('Perfil actualizado correctamente',exact=True).last.wait_for()
    foto('11_perfil.png')
    page.get_by_role('button',name=re.compile('Open navigation menu')).click()
    page.get_by_text('Cerrar sesión',exact=True).click()
    page.get_by_role('button',name='INGRESAR',exact=True).wait_for()
    page.get_by_role('textbox',name='Correo electrónico',exact=True).fill(mail)
    page.get_by_role('textbox',name='Contraseña',exact=True).fill(password)
    page.get_by_role('button',name='INGRESAR',exact=True).click()
    page.get_by_text('Mi Blog',exact=True).wait_for()
    page.set_viewport_size({'width':390,'height':844})
    foto('12_movil.png')
    page.get_by_role('button',name=re.compile('Abrir publicación: Mi publicación desde Flutter actualizada')).first.click()
    page.mouse.move(195,400);page.mouse.wheel(0,650)
    foto('13_persistencia.png')
    page.set_viewport_size({'width':1280,'height':900})
    page.get_by_role('button',name='Back',exact=True).click()
    page.get_by_role('button',name=re.compile('Open navigation menu')).click()
    page.get_by_text('Cerrar sesión',exact=True).click()
    page.get_by_role('textbox',name='Correo electrónico',exact=True).fill(admin_mail)
    page.get_by_role('textbox',name='Contraseña',exact=True).fill(admin_password)
    page.get_by_role('button',name='INGRESAR',exact=True).click()
    page.get_by_text('Gestión de usuarios',exact=True).wait_for()
    foto('14_administrador.png')
    page.get_by_role('button',name=re.compile('Open navigation menu')).click()
    page.get_by_text('Ver blog',exact=True).click()
    page.get_by_role('button',name=re.compile('Abrir publicación: Mi publicación desde Flutter actualizada')).first.click()
    page.get_by_role('button',name='Editar publicación',exact=True).wait_for()
    foto('15_moderacion.png')
    login=client.post('/login',json={'mail':mail,'password':password}).json()
    h={'Authorization':'Bearer '+login['access_token']}
    propios=client.get('/blog',headers=h,params={'propios':True}).json()
    id=propios[0]['id_blog']
    with engine.connect() as db:
        rows=[dict(row._mapping) for row in db.execute(text('SELECT b.id_blog,b.titulo,u.nom_usr,c.comentario FROM blog b JOIN usuario u ON u.id_usr=b.usr_id LEFT JOIN comentarios c ON c.blog_id=b.id_blog WHERE b.id_blog=:id'),{'id':id})]
        votos=[dict(row._mapping) for row in db.execute(text('SELECT blog_id,usr_id,puntos FROM valoraciones WHERE blog_id=:id'),{'id':id})]
    bloqueado=client.get('/usuarios',headers=h).status_code
    client.post('/logout',headers=h).raise_for_status()
    revocado=client.get('/blog',headers=h).status_code
    evidence={'estado':client.get('/').json(),'publicaciones_api':propios,'consulta_mysql':rows,'valoraciones_mysql':votos,'usuario_admin_http':bloqueado,'token_revocado_http':revocado,'errores_navegador':errores,'entorno':'Flutter Web Chromium, 1280 y 390 px; API y MySQL reales locales; sin prueba nativa'}
    (out/'acceso_datos.json').write_text(json.dumps(evidence,ensure_ascii=False,indent=2,default=str))
    page.set_content('<html><body style="font:18px Arial;padding:30px"><h1>Verificación del acceso a datos</h1><pre style="white-space:pre-wrap">'+__import__('html').escape(json.dumps(evidence,ensure_ascii=False,indent=2,default=str))+'</pre></body></html>')
    foto('16_mysql.png')
    client.post('/logout',headers=ah)
    video=page.video
    context.close()
    video.save_as(str(runtime/'estructura.webm'))
    browser.close()
    assert not errores, errores
    print('Recorrido completo sin errores JavaScript. Evidencias en',out)
