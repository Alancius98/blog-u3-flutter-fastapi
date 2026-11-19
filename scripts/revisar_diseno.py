"""Revisa el diseño con una cuenta existente; no crea usuarios o contenido."""
import json
import os
from pathlib import Path
from playwright.sync_api import sync_playwright

root = Path(__file__).resolve().parents[1]
runtime = root/'entrega_blog_u3/.runtime'
out = root/'reportes/evidencias'
correo = os.getenv('BLOG_TEST_EMAIL')
password = os.getenv('BLOG_TEST_PASSWORD')
if not correo or not password:
    private = json.loads((runtime/'cuenta_lector.json').read_text())
    correo, password = private['correo'], private['password']

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page(viewport={'width':1440,'height':1000})
    errors = []
    page.on('pageerror',lambda e:errors.append(str(e)))
    page.goto('http://127.0.0.1:8080')
    page.locator('flutter-view').wait_for()
    page.locator('flt-semantics-placeholder').evaluate('(e)=>e.click()')
    def foto(name):
        page.wait_for_timeout(800)
        page.screenshot(path=str(out/name))
    page.get_by_role('button',name='Iniciar sesión',exact=True).wait_for()
    foto('18_portada.png')
    page.get_by_role('button',name='Iniciar sesión',exact=True).click()
    page.get_by_role('button',name='INGRESAR',exact=True).wait_for()
    foto('19_login_diseno.png')
    for label,value in [('Correo electrónico',correo),('Contraseña',password)]:
        page.get_by_role('textbox',name=label,exact=True).click()
        page.wait_for_timeout(200)
        page.keyboard.type(value,delay=10)
    page.get_by_role('button',name='INGRESAR',exact=True).click()
    page.get_by_role('button',name='Escribir',exact=True).wait_for()
    page.get_by_role('button',name='Abrir publicación: Ideas para diseñar una aplicación clara',exact=True).wait_for()
    page.wait_for_timeout(1500)
    foto('20_blog_diseno.png')
    page.set_viewport_size({'width':390,'height':844})
    foto('21_blog_movil.png')
    page.get_by_role('button',name='Abrir publicación: Ideas para diseñar una aplicación clara',exact=True).click()
    page.get_by_role('heading',name='Detalle',exact=True).wait_for()
    foto('22_detalle_diseno.png')
    page.mouse.move(195,400)
    page.mouse.wheel(0,900)
    page.get_by_role('textbox',name='Tu comentario',exact=True).wait_for(state='attached')
    page.get_by_role('button',name='Back',exact=True).click()
    page.get_by_role('button',name=__import__('re').compile('Open navigation menu')).click()
    page.get_by_text('Cerrar sesión',exact=True).click()
    page.get_by_role('button',name='INGRESAR',exact=True).wait_for()
    assert not errors, errors
    (out/'diseno_verificado.json').write_text(json.dumps({'ancho_escritorio':1440,'ancho_movil':390,'errores_javascript':errors,'contenido_modificado':False,'recorrido':'Portada, login, listado, detalle, cierre de sesión'},ensure_ascii=False,indent=2))
    browser.close()
print('Diseño verificado sin modificar publicaciones, comentarios o cuentas.')
