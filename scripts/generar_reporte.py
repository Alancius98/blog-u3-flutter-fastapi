"""Genera un reporte único para la aplicación y API con la estructura de clase."""
import json
from pathlib import Path
from xml.sax.saxutils import escape

from docx import Document
from docx.shared import Cm, Pt
from PIL import Image, ImageDraw, ImageFont
from reportlab.lib import colors
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Preformatted, Spacer, PageBreak, Image as PdfImage

root=Path(__file__).resolve().parents[1]
out=root/'reportes'; out.mkdir(exist_ok=True)
front=root/'flutter application/flutter_application_1'
back=root/'Flutter_LITIID/backend_API'
repo='https://github.com/Alancius98/blog-u3-flutter-fastapi'
fonts=[('/System/Library/Fonts/Supplemental/Arial.ttf','/System/Library/Fonts/Supplemental/Arial Bold.ttf'),('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf','/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf')]
regular,bold=next(pair for pair in fonts if all(Path(f).exists() for f in pair))
pdfmetrics.registerFont(TTFont('BlogArial',regular));pdfmetrics.registerFont(TTFont('BlogBold',bold))
body=ParagraphStyle('Body',fontName='BlogArial',fontSize=10.5,leading=16,spaceAfter=11,textColor=colors.HexColor('#203544'))
heading=ParagraphStyle('Heading',fontName='BlogBold',fontSize=22,leading=27,spaceAfter=17,textColor=colors.HexColor('#08245C'))
mono=ParagraphStyle('Code',fontName='Courier',fontSize=8,leading=11,spaceAfter=12)
story=[];word=Document()
section=word.sections[0];section.top_margin=section.bottom_margin=Cm(1.8)
section.left_margin=section.right_margin=Cm(2)
word.styles['Normal'].font.name='Arial';word.styles['Normal'].font.size=Pt(10.5)
section.footer.paragraphs[0].text='Blog · Evaluación U3 · Alan Fentanes López'
word.core_properties.author='Alan Fentanes López';word.core_properties.title='Blog · Evaluación U3'

def title(s):
    story.append(Paragraph(escape(s),heading));word.add_heading(s,1)
def p(s):
    story.append(Paragraph(escape(s).replace('\n','<br/>'),body));word.add_paragraph(s)
def code(s):
    story.append(Preformatted(s,mono));run=word.add_paragraph().add_run(s);run.font.name='Courier New';run.font.size=Pt(8)
def page():
    story.append(PageBreak());word.add_page_break()
def picture(path,height=12,width=17):
    with Image.open(path) as im:w,h=im.size
    scale=min(width*cm/w,height*cm/h)
    story.extend([PdfImage(str(path),w*scale,h*scale),Spacer(1,10)])
    word.add_picture(str(path),width=Cm(w*scale/cm))
def diagram(name,title_,boxes,lines,foot):
    im=Image.new('RGB',(1600,1050),'#F3F6F9');d=ImageDraw.Draw(im)
    d.text((40,25),title_,font=ImageFont.truetype(bold,35),fill='#08245C')
    for start,end,label,pos in lines:
        d.line([start,end],fill='#7492B4',width=4);d.text(pos,label,font=ImageFont.truetype(bold,20),fill='#08245C')
    for x,y,w,h,label,fields in boxes:
        d.rounded_rectangle((x,y,x+w,y+h),16,fill='white',outline='#B2C8DF',width=3)
        d.rectangle((x,y,x+w,y+52),fill='#08245C');d.text((x+12,y+8),label,font=ImageFont.truetype(bold,27),fill='white')
        for n,f in enumerate(fields):d.text((x+12,y+69+n*32),f,font=ImageFont.truetype(regular,22),fill='#203544')
    d.text((40,1000),foot,font=ImageFont.truetype(regular,19),fill='#536B77');im.save(out/name)

diagram('Modelo_BD.png','Modelo MySQL · Estructura ampliada',[
 (40,110,500,300,'usuario',['PK id_usr','nom_usr / mail UNIQUE','pass (hash) / dir_usr','tip_usu: 1 admin, 2 general']),
 (1040,110,500,300,'blog',['PK id_blog / titulo / desc','img / tags / fecha','FK usr_id → usuario.id_usr','Autor anterior: NULL permitido']),
 (40,600,440,300,'sesiones',['PK id_sesion','FK usr_id → usuario.id_usr','token_hash UNIQUE (64)','expira DATETIME UTC']),
 (580,600,440,300,'comentarios',['PK id_com / comentario','fecha / estatus','FK usr_id → usuario.id_usr','FK blog_id → blog.id_blog']),
 (1110,600,440,300,'valoraciones',['PK id_val / puntos: 1 a 5','FK usr_id / FK blog_id','UNIQUE(usr_id,blog_id)','CHECK puntos BETWEEN 1 AND 5']),
], [((540,220),(1040,220),'1 → N',(730,185)),((230,410),(230,600),'1 → N',(240,470)),((470,410),(710,600),'1 → N',(520,470)),((1200,410),(900,600),'1 → N',(990,470)),((1340,410),(1340,600),'1 → N',(1350,470)),((540,350),(1200,600),'usuario 1 → N',(780,480))], 'PK: primaria · FK: foránea · Las relaciones se eliminan explícitamente en la transacción al borrar una publicación.')
diagram('Diagrama_clases.png','Clases · Se conserva la organización original',[
 (40,120,450,330,'LoginApp / SessionGuard',['Rutas y verificación al reanudar','WelcomePage: portada pública','LoginPage / RegisterPage','BlogPage / PostDetailPage','UsersPage / ProfilePage','AddBlogPage']),
 (590,120,450,300,'Servicios',['AuthService / UserService','PostService','ComentarioService','ApiClient: Bearer y errores','ApiConfig: URL de la API']),
 (1130,120,420,300,'Modelos Dart',['UserModel','PostModel: autor y votos','ComentarioModel: autor','fromJson() / toJsonCrear()']),
 (330,650,450,250,'API FastAPI',['main.py: rutas originales','security.py: sesión y permisos','schemas.py: validación','database.py: sesión SQLAlchemy']),
 (960,650,480,250,'Modelos SQLAlchemy',['Usuario / Blog / Comentario','Sesion / Valoracion','Base de datos MySQL','SQL de instalación y migración']),
], [((490,250),(590,250),'usa',(515,215)),((1040,250),(1130,250),'JSON',(1050,215)),((800,420),(600,650),'HTTP',(650,500)),((780,760),(960,760),'ORM',(840,725))], 'ApiClient no sustituye los servicios: centraliza transporte, cabeceras y estado de sesión.')

title('EVALUACIÓN UNIDAD 3')
p('Caso práctico: Diseño de blog')
title('Aplicación Flutter, API y base de datos')
p('Actividad para alcanzar 10 Puntos')
p('Estudiante: Alan Fentanes López\nInstitución: Universidad Politécnica de Santa Rosa Jáuregui\nMateria: Mobile programming II\nDocente: Adriana Y. Contreras Álvarez\nGrupo: ISW-27')
p('Fecha de actualización: 18 de noviembre de 2026')
p('Repositorio público: '+repo)
p('La meta de 10 puntos corresponde a los 7 puntos del proyecto y los 3 del reporte.')
page()
title('1. Objetivo y organización')
p('El objetivo es ampliar el blog de clase sin reemplazar su estructura. La aplicación usa Flutter y Dart; la API utiliza FastAPI y guarda los datos en MySQL. Se conservaron las carpetas flutter application y Flutter_LITIID, además de los nombres principales de pantallas, modelos y servicios.')
code('flutter application/\n  flutter_application_1/\n    lib/screens/   Pantallas del blog\n    lib/services/  Solicitudes a la API\n    lib/models/    Datos de Flutter\n    lib/widgets/   Componentes de interfaz\n    lib/pages/     Gestión de usuarios\nFlutter_LITIID/\n  backend_API/\n    main.py / models.py / schemas.py\n    database.py / security.py / bd.sql\n    migrations/ / tests/\nreportes/          Reporte y evidencias')
p('La ampliación incluye sesiones seguras, registro general, permisos de administrador y usuario, publicaciones propias y ajenas y comentarios conectados al detalle. También se completaron la búsqueda y los filtros del listado. Como módulo opcional se añadieron valoraciones de 1 a 5 estrellas.')
p('Se conserva la organización de pantallas y widgets del código recibido. La presentación utiliza colores naranja y crema, una portada de bienvenida y tarjetas con imágenes amplias. Las páginas de prácticas y catálogo permanecen en el proyecto, pero no se presentan como un sistema de ventas o pagos.')
page()
title('2. Frontend: pantallas y navegación')
p('WelcomePage es la portada pública. Presenta una fotografía local y los accesos a Iniciar sesión y Crear mi cuenta. El diseño toma como referencia la composición de la página de Blogger, sin copiar su logotipo ni utilizar sus servicios. Las publicaciones se organizan en tres, dos o una columna según el ancho de pantalla.')
p('LoginPage solicita correo y contraseña y utiliza AuthService. El servidor devuelve un token y los datos públicos de la cuenta. El tipo 1 abre la gestión de usuarios y el tipo 2 abre Mi Blog. La aplicación guarda la sesión solo en memoria; al recargar el navegador es necesario iniciar sesión otra vez.')
p('RegisterPage conserva nombre, correo, dirección y contraseña. El registro público crea una cuenta General. Un administrador autenticado puede crear cuentas desde su menú. La API no confía en el selector de la interfaz: valida el permiso antes de aceptar un tipo administrativo.')
p('BlogPage presenta las publicaciones con PostCard y permite consultar todas o solo las propias. Los filtros de texto y etiquetas consultan el servidor. Se cargan 20 entradas por página y el botón Cargar más permite continuar. AddBlogPage conserva el formulario original y ahora sirve también para editar una entrada.')
p('PostDetailPage mantiene la imagen, título, etiquetas y descripción. Se añadieron lectura y creación de comentarios, eliminación con confirmación y estrellas. El autor puede modificar su contenido y el administrador puede moderar contenido ajeno. Los comentarios se consultan por publicación, no como una lista general sin contexto.')
p('AdminDrawer conserva la navegación lateral y ahora permite cerrar la sesión en el servidor. ProfilePage actualiza los datos de la cuenta actual. SessionGuard comprueba la sesión al volver a la aplicación. Los accesos privados se revisan también en las rutas de Flutter, aunque la seguridad definitiva corresponde a FastAPI.')
page()
title('3. Clases y comunicación')
picture(out/'Diagrama_clases.png',12)
p('AuthService, UserService, PostService y ComentarioService conservan sus responsabilidades. ApiClient centraliza JSON, cabeceras Bearer, tiempos de espera y errores. Una respuesta HTTP 401 limpia la sesión y lleva al login. ApiConfig mantiene la URL configurable mediante API_BASE_URL.')
p('Los modelos originales UserModel, PostModel y ComentarioModel se ampliaron con autoría y datos de votos. No se cambiaron los nombres principales de los campos enviados por la API. El frontend no se conecta directamente con MySQL; toda consulta pasa por FastAPI.')
page()
title('4. Backend: rutas y permisos')
p('La API mantiene /login, /usuarios, /blog y /comentarios. El login ahora devuelve access_token, expira y usuario. Las rutas /sesion y /logout permiten consultar y cerrar la sesión. Todas las operaciones privadas comprueban el token antes de acceder a los datos.')
code('POST /usuarios         Registro público general\nPOST /login            Credenciales y token\nGET  /sesion           Cuenta autenticada\nPOST /logout           Revocar token\nGET/PUT/DELETE /usuarios   Gestión según permisos\nPOST /admin/usuarios   Crear cuenta como admin\nGET/POST/PUT/DELETE /blog  Publicaciones\nGET/POST/DELETE /comentarios  Comentarios por blog\nPUT/DELETE /valoraciones?id_blog=ID  Voto propio')
p('El Usuario General solo puede editar su perfil y su contenido. El Administrador consulta cuentas, registra usuarios y modera publicaciones o comentarios ajenos. No puede eliminar su propia cuenta desde administración. Una cuenta con publicaciones o comentarios asociados no se elimina para no perder su autoría.')
p('El registro público rechaza tip_usu=1. Los comentarios ya no aceptan usr_id enviado por el cliente: el servidor toma el autor de la sesión. Lo mismo ocurre al crear publicaciones y valoraciones. Pydantic limita las longitudes, revisa el correo y rechaza campos no permitidos.')
page()
title('5. Modelo de datos y migración')
picture(out/'Modelo_BD.png',11.5)
p('Se conservan usuario, blog y comentarios. blog añade usr_id y fecha. sesiones guarda el resumen del token y su vencimiento; valoraciones relaciona una cuenta con una entrada. La combinación usr_id y blog_id es única y CHECK limita los puntos a 1–5.')
p('bd.sql sirve para instalaciones nuevas y no crea cuentas de ejemplo. La migración 001_seguridad.sql se aplica una sola vez al esquema anterior, con respaldo previo. Las entradas antiguas conservan autor desconocido en lugar de asignar una persona sin evidencia. Su fecha añadida corresponde a la migración, no a una fecha histórica comprobada.')
p('La migración se ensayó con una copia del esquema anterior. Se comprobó que conserva publicación y comentario, deja la autoría sin inventar, crea las tablas nuevas y cambia el valor predeterminado a General. No se ejecutó sobre la base privada del estudiante.')
page()
title('6. Seguridad y manejo de errores')
p('pwdlib calcula hashes Argon2id. No se guarda la contraseña original ni se utiliza un cifrado reversible. El registro admite contraseñas de 8 a 128 caracteres. El mensaje de acceso incorrecto es general para no indicar si existe el correo.')
p('El token tiene 256 bits aleatorios. La base solo guarda su resumen SHA-256 y la fecha de vencimiento en UTC. La duración predeterminada es de 60 minutos, configurable con SESSION_MINUTES. Cerrar sesión elimina el registro y revoca el token. Las operaciones posteriores responden con HTTP 401 si el token ya no es válido.')
code('def autor_o_admin(autor_id, usuario):\n    if usuario.tip_usu != 1 and autor_id != usuario.id_usr:\n        raise HTTPException(403, "Sin permiso")\n\n# La identidad se obtiene desde usuario_actual,\n# no desde el cuerpo JSON enviado por Flutter.')
p('SQLAlchemy utiliza consultas parametrizadas. CORS acepta solo los orígenes configurados. La cuenta MySQL utilizada en las pruebas tiene permisos de lectura y escritura limitados al esquema de ensayo. Las respuestas de usuario no muestran pass_hash. El archivo .env, los entornos y los respaldos se excluyen de Git.')
p('La recuperación por correo sigue pendiente y la pantalla lo indica sin afirmar que envía un enlace. Antes de publicar se necesitan HTTPS, límites de intentos de acceso, auditoría y limpieza de sesiones vencidas. Esta entrega comprueba la integración local, no una configuración de producción completa.')
page()
title('7. Recursos, librerías y sensores')
p('El blog utiliza Material Icons, Cupertino Icons, tarjetas y formularios Flutter. Las imágenes de publicaciones son URLs opcionales y Image.network muestra un icono alternativo si fallan. La portada incluye una fotografía local de Unsplash, cuya fuente está registrada en assets/images/FUENTES.md. No se requiere cámara, GPS ni micrófono y no se añadieron permisos de sensores innecesarios.')
p('El frontend conserva http ^1.6.0 y cupertino_icons ^1.0.8. dart:convert procesa JSON y dart:async controla esperas y búsquedas. flutter_test y flutter_lints permiten revisar la interfaz y el código. El requisito Dart del proyecto se mantiene en ^3.12.2.')
p('La API usa FastAPI 0.121.3, Uvicorn 0.38.0, SQLAlchemy 2.0.44 y PyMySQL 1.1.2. pwdlib[argon2] 0.3.0 protege las credenciales; email-validator valida correos; python-dotenv carga la configuración y cryptography da soporte a la conexión MySQL. Las versiones se conservan en requirements.txt.')
p('pytest y httpx se utilizan para las pruebas de API. Playwright registra el recorrido real de Flutter Web. ReportLab y python-docx generan los documentos y Pillow construye los diagramas. Estas herramientas de documentación no forman parte de las funciones ejecutadas en el dispositivo.')
page()
title('8. Acceso a datos desde la app')
p('ComentarioService envía comentario y blog_id a /comentarios. ApiClient añade la cabecera Bearer y la API comprueba sesión, publicación y contenido. El autor se asigna en el servidor, no a partir del identificador que el cliente quiera enviar.')
code("# Flutter_LITIID/backend_API/main.py\n@app.post('/comentarios', status_code=201, ...)\ndef crear_comentario(datos, usuario=Depends(usuario_actual), ...):\n    buscar_blog(db, datos.blog_id)\n    nuevo = Comentario(**datos.model_dump(),\n                       usr_id=usuario.id_usr, estatus=1)\n    db.add(nuevo)\n    db.commit()\n    db.refresh(nuevo)")
p('El fragmento resume el código completo de la ruta. Después de guardar se vuelve a consultar el listado. En la verificación se comparó lo que devuelve la API con una consulta directa que une blog, usuario y comentarios.')
code('SELECT b.id_blog, b.titulo, u.nom_usr, c.comentario\nFROM blog b\nJOIN usuario u ON u.id_usr = b.usr_id\nLEFT JOIN comentarios c ON c.blog_id = b.id_blog\nWHERE b.id_blog = :id;')
p('Las valoraciones también se consultaron directamente en MySQL. Una modificación del voto conserva un solo registro por cuenta y publicación. Las evidencias no incluyen contraseñas, tokens ni contenido de .env.')
page()
title('9. Evidencias: registro y publicaciones')
picture(out/'evidencias/02_registro.png',8.2)
p('Figura 1. Registro desde el formulario original, con datos ficticios de ensayo.')
picture(out/'evidencias/04_blog.png',8.2)
p('Figura 2. Mi Blog obtiene las publicaciones a través de FastAPI y MySQL.')
page()
title('9.1. Comentarios y persistencia')
picture(out/'evidencias/13_persistencia.png',19,9.5)
p('Figura 3. Comentario consultado después de cerrar y volver a iniciar sesión. Se utiliza Flutter Web a ancho móvil; no es un teléfono físico ni un emulador Android.')
page()
title('9.2. Datos y roles')
picture(out/'evidencias/16_mysql.png',11)
p('Figura 4. Consulta de comprobación independiente, no una pantalla del blog. Permite contrastar API y MySQL.')
data=json.loads((out/'evidencias/acceso_datos.json').read_text())
p('Motor confirmado: '+data['estado']['database']+'. Sin permiso administrativo: HTTP '+str(data['usuario_admin_http'])+'. Token revocado: HTTP '+str(data['token_revocado_http'])+'. Errores JavaScript registrados: '+str(len(data['errores_navegador']))+'.')
p('La información completa se conserva en reportes/evidencias/acceso_datos.json. La vista del administrador y los controles sobre publicaciones ajenas se muestran en las capturas 14 y 15.')
page()
title('10. Pruebas y alcance comprobado')
p('Se aprobaron 18 pruebas de API con SQLite en memoria. Cubren registro, hashing, login, credenciales heredadas inválidas, permisos, expiración, revocación, autoría, comentarios, administración, perfil, estrellas, búsqueda, paginación y borrado de relaciones. También se comprobaron la ruta /valoraciones, su parámetro obligatorio id_blog y la configuración CORS de desarrollo: acepta puertos locales y rechaza dominios externos.')
p('Flutter aprobó seis pruebas: navegación de portada a login, registro público sin selector administrativo, limpieza del estado de sesión, login a 390 px, registro desde portada a 390 px y adaptación de la portada con texto ampliado. El análisis estático no reportó incidencias y la compilación web release se completó. Estas pruebas no sustituyen el recorrido con HTTP real.')
p('La integración con FastAPI y MySQL locales aprobó 15 comprobaciones. La migración del esquema anterior aprobó otras cinco. El recorrido en Chromium verifica registro, error de credenciales, login, publicaciones, comentarios, votos, edición, filtros, perfil, reingreso y administración.')
p('Los archivos pruebas.json, integracion_mysql.json, migracion_mysql.json y acceso_datos.json conservan los resultados. Esta documentación corresponde a flutter application/flutter_application_1 y Flutter_LITIID/backend_API, no a las versiones independientes anteriores.')
p('No se ha probado Android/iOS ni un despliegue remoto. La aplicación conserva sus carpetas nativas, pero el equipo no dispone del SDK Android ni Xcode completo para validar esas compilaciones. El video personal se entrega por separado. No se presenta una grabación automática como explicación realizada por el estudiante.')
page()
title('11. Instalación y uso')
p('Desde la raíz del repositorio, bd.sql prepara una instalación nueva. Para una base anterior se utiliza la migración con respaldo. Después se configura .env sin publicar credenciales y se inicia la API desde su carpeta.')
code('mysql -u root -p < Flutter_LITIID/backend_API/bd.sql\ncd Flutter_LITIID/backend_API\npython3 -m venv venv\nsource venv/bin/activate\npip install -r requirements.txt\ncp .env.example .env\n# Configurar las credenciales de MySQL.\nuvicorn main:app --host 127.0.0.1 --port 8000')
p('En otra terminal se inicia Flutter. El README incluye la configuración de usuarios MySQL y el comando local para crear un Administrador sin contraseña fija.')
code('cd "flutter application/flutter_application_1"\nflutter pub get\nflutter run -d chrome --web-hostname=127.0.0.1 \\\n  --web-port=8080 \\\n  --dart-define=API_BASE_URL=http://127.0.0.1:8000')
p('El estado está en / y Swagger en /docs. En un emulador Android se utiliza 10.0.2.2; en un teléfono físico se necesita una IP accesible o una URL HTTPS. localhost en un teléfono no apunta a la computadora. La instalación móvil y la publicación en Internet quedan pendientes de confirmación.')
page()
title('12. Reflexión y referencias')
p('Estoy revisando el proyecto y considero importante conservar la estructura del código recibido. Separar pantallas, servicios y modelos ayuda a encontrar cada responsabilidad. Las mejoras se integraron en esas partes sin convertir el trabajo en una aplicación independiente.')
p('Para mí, una diferencia importante es iniciar sesión frente a tener permiso. No basta con mostrar un menú distinto: el servidor debe comprobar quién realiza cada acción. De la misma manera, mostrar un comentario no demuestra que esté guardado; por eso las evidencias lo comparan con la base de datos después de volver a entrar.')
p('Conservar datos antiguos también requiere cuidado. Si una publicación no tenía autor, no es correcto asignarle una persona sin comprobarlo. La migración deja esa información como desconocida. Todavía hacen falta pruebas en un dispositivo móvil y una revisión de seguridad para un servidor público.')
p('Referencias: docs.flutter.dev; pub.dev/packages/http; fastapi.tiangolo.com; docs.sqlalchemy.org; dev.mysql.com/doc; frankie567.github.io/pwdlib; owasp.org, Password Storage Cheat Sheet. Referencia visual: www.blogger.com/about/. Fotografía de portada: Unsplash, photo-1455390582262-044cdead277a. Documento de la actividad: evaluación_U3.docx.')
if (out/'evidencias/18_portada.png').exists():
    page();title('13. Presentación visual actual')
    picture(out/'evidencias/18_portada.png',9)
    p('Portada pública con acceso al registro y al login. La fotografía se carga como recurso local, sin depender de una petición externa al abrir esta pantalla.')
    picture(out/'evidencias/20_blog_diseno.png',9)
    p('Listado con imágenes, autor, fecha, comentarios y valoraciones. Esta revisión utiliza cuentas y contenido existentes, sin crear registros de prueba adicionales.')
    page();title('13.1. Vista móvil y formularios')
    picture(out/'evidencias/21_blog_movil.png',17,8)
    p('Listado a 390 px de ancho. Las tarjetas pasan a una columna y los filtros conservan sus funciones. La verificación de diseño no modifica publicaciones, comentarios o cuentas.')
public=out/'evidencias/repositorio_publico.json'
if public.exists():
    page();title('Anexo. Acceso público al repositorio')
    record=json.loads(public.read_text())
    p('Liga: '+record['url'])
    p('Fecha UTC: '+record['utc']+'. Página HTTP '+str(record['http_status'])+'. README sin autenticación HTTP '+str(record['raw_readme_status'])+'. La consulta se realizó sin sesión de GitHub.')
    picture(out/'evidencias/17_repositorio.png',15)
    p('La captura y el JSON corresponden a una ventana privada de Chromium. El repositorio conserva las carpetas de Flutter y FastAPI del proyecto de clase.')

def footer(canvas,doc):
    canvas.setFont('BlogArial',8);canvas.setFillColor(colors.HexColor('#536B77'))
    canvas.drawString(2*cm,1.1*cm,'Blog · Evaluación U3 · Alan Fentanes López');canvas.drawRightString(19*cm,1.1*cm,str(doc.page))
SimpleDocTemplate(str(out/'Reporte_U3.pdf'),pagesize=(21*cm,29.7*cm),leftMargin=2*cm,rightMargin=2*cm,topMargin=1.8*cm,bottomMargin=2*cm,title='Blog · Evaluación U3',author='Alan Fentanes López').build(story,onFirstPage=footer,onLaterPages=footer)
word.save(out/'Reporte_U3.docx')
print('Reporte único generado:',out)
