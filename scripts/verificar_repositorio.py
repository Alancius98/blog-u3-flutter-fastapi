import json
from datetime import datetime, timezone
from pathlib import Path
from playwright.sync_api import sync_playwright

root=Path(__file__).resolve().parents[1]
out=root/'reportes/evidencias'
url='https://github.com/Alancius98/blog-u3-flutter-fastapi'
with sync_playwright() as p:
    browser=p.chromium.launch()
    context=browser.new_context(viewport={'width':1440,'height':1000})
    page=context.new_page()
    response=page.goto(url,wait_until='domcontentloaded')
    page.get_by_role('heading',name='Blog · Evaluación de la Unidad 3',exact=True).wait_for()
    page.screenshot(path=str(out/'17_repositorio.png'))
    raw=context.request.get('https://raw.githubusercontent.com/Alancius98/blog-u3-flutter-fastapi/main/README.md')
    assert response.status==raw.status==200
    assert not any(c['name']=='user_session' for c in context.cookies('https://github.com'))
    record={'url':url,'utc':datetime.now(timezone.utc).isoformat(),'http_status':response.status,'raw_readme_status':raw.status,'cookie_sesion':False,'metodo':'Contexto privado Chromium sin cookies ni Authorization'}
    (out/'repositorio_publico.json').write_text(json.dumps(record,ensure_ascii=False,indent=2))
    print(json.dumps(record,ensure_ascii=False))
    context.close();browser.close()
