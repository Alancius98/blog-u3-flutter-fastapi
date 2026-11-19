# Blog · Evaluación de la Unidad 3

**Alan Fentanes López · ISW-27**

Universidad Politécnica de Santa Rosa Jáuregui · Mobile programming II

Docente: Adriana Y. Contreras Álvarez

Este proyecto amplía el código de clase y conserva sus dos carpetas principales. Flutter presenta la aplicación; FastAPI valida las solicitudes y consulta MySQL.

Repositorio público: https://github.com/Alancius98/blog-u3-flutter-fastapi

Reporte: [PDF](reportes/Reporte_U3.pdf) y [Word](reportes/Reporte_U3.docx). Diagramas: [modelo BD](reportes/Modelo_BD.png) y [clases](reportes/Diagrama_clases.png). La grabación personal se entrega por separado.

```text
flutter application/
  flutter_application_1/       Aplicación Flutter
Flutter_LITIID/
  backend_API/                 API FastAPI y esquema MySQL
reportes/                      Reporte único PDF y Word, diagramas y evidencias
scripts/                       Verificación y documentación
```

## Funciones

Registro, inicio y cierre de sesión, consulta de publicaciones propias y ajenas, creación/edición/borrado de publicaciones, comentarios por publicación y valoraciones de 1 a 5 estrellas. Se conserva la navegación y los widgets del proyecto original; los filtros por texto y etiquetas ahora consultan la API.

El tipo 1 corresponde a Administrador y el tipo 2 a General. El registro público solo admite General. El administrador puede gestionar cuentas y moderar contenido ajeno. Cada usuario puede editar su perfil y modificar únicamente sus publicaciones y comentarios. La API comprueba los permisos, aunque se intente acceder sin utilizar la interfaz.

## Requisitos

Python 3.12 o superior, MySQL 8.0.16 o superior y Flutter con Dart 3.12.2 o superior. Chrome permite ejecutar la versión web. Para Android/iOS se necesitan sus herramientas nativas.

### Base de datos nueva

Desde la raíz:

```bash
mysql -u root -p < Flutter_LITIID/backend_API/bd.sql
```

El script no crea cuentas predeterminadas ni guarda contraseñas de ejemplo. En MySQL, crea una cuenta limitada y sustituye la contraseña:

```sql
CREATE USER 'blog_app'@'127.0.0.1' IDENTIFIED BY 'CAMBIAR_CONTRASENA';
GRANT SELECT,INSERT,UPDATE,DELETE ON bd_aplicacion_movil.* TO 'blog_app'@'127.0.0.1';
```

### Actualizar la base original

Guarda un respaldo antes de aplicar **una sola vez** `Flutter_LITIID/backend_API/migrations/001_seguridad.sql`. No ejecutes esa migración en una base creada con el nuevo `bd.sql`.

La migración conserva los registros. Las publicaciones anteriores quedan con autor desconocido (`usr_id NULL`), y su fecha corresponde al momento de la migración, no a una fecha histórica comprobada. Las nuevas publicaciones sí guardan el autor de la sesión. El marcador antiguo `HASH_DE_PRUEBA` no es un hash válido: registra cuentas nuevas o restablece las credenciales de forma administrativa; la API no lo convierte en una contraseña.

### API

```bash
cd Flutter_LITIID/backend_API
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Configura tu usuario, contraseña, host, puerto y base en .env.
uvicorn main:app --host 127.0.0.1 --port 8000
```

La documentación está en http://127.0.0.1:8000/docs. La ruta http://127.0.0.1:8000/ ejecuta una consulta y confirma el motor de la base. Las tablas se preparan con SQL, no se crean al importar la API.

Para crear un administrador nuevo, desde la carpeta de la API con el entorno activado:

```bash
python manage.py create-admin --mail TU_CORREO --nombre Administrador
```

El programa pide contraseña oculta y confirmación. No modifica cuentas existentes ni publica una contraseña administrativa. El registro público es `POST /usuarios`; la creación de cuentas desde una sesión administrativa utiliza `POST /admin/usuarios`.

### App

Abre otra terminal desde la raíz del repositorio:

```bash
cd "flutter application/flutter_application_1"
flutter pub get
flutter run -d chrome --web-hostname=127.0.0.1 --web-port=8080 --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Para compilar y servir localmente:

```bash
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8000
python3 -m http.server 8080 --bind 127.0.0.1 --directory build/web
```

En un emulador Android, ApiConfig usa `10.0.2.2:8000` por defecto. En un teléfono físico, configura la IP de la red local o la URL HTTPS de la API: localhost apunta al teléfono, no a la computadora. iOS requiere HTTPS o una excepción ATS limitada a desarrollo. No se ha realizado la prueba nativa. La plantilla Android usa firma de depuración; no está preparada para publicación en una tienda.

## Uso

Crea una cuenta general, inicia sesión y abre **Mi Blog**. Puedes consultar todas las publicaciones o elegir **Mis publicaciones**, buscar texto y filtrar etiquetas. **Escribir** abre el formulario original de publicación. En el detalle se pueden leer y crear comentarios, valorar y editar o eliminar contenido propio. El administrador puede moderar el contenido de otras cuentas.

Desde el menú lateral se accede al perfil y se cierra la sesión. El cierre revoca el token en MySQL. Recargar el navegador exige otro login, porque el token solo permanece en memoria. La recuperación por correo no está implementada y la pantalla lo indica sin afirmar que envía mensajes.

## Rutas

Salvo estado, registro público y login, se requiere `Authorization: Bearer TOKEN`.

| Método | Ruta | Función |
|---|---|---|
| GET | `/` | Estado y conexión de BD |
| POST | `/login` | Token temporal y datos del usuario |
| GET | `/sesion` | Consultar cuenta autenticada |
| POST | `/logout` | Revocar token |
| POST | `/usuarios` | Registro general |
| POST | `/admin/usuarios` | Crear cuenta como administrador |
| GET | `/usuarios` | Lista de usuarios, solo admin, offset/limit |
| PUT | `/usuarios` | Editar cuenta propia o como admin |
| DELETE | `/usuarios?id_usr=ID` | Admin; no permite borrar su propia cuenta o cuentas con contenido |
| GET | `/blog?propios=false&q=&categoria=&offset=0&limit=20` | Listado filtrado |
| POST / PUT | `/blog` | Crear / editar publicación |
| DELETE | `/blog?id_blog=ID` | Borrar publicación y sus comentarios/votos |
| GET | `/comentarios?blog_id=ID&offset=0&limit=20` | Comentarios de una publicación |
| POST | `/comentarios` | Crear comentario; autor desde sesión |
| DELETE | `/comentarios?id_com=ID` | Autor o administrador |
| PUT / DELETE | `/valoraciones?id_blog=ID` | Guardar o retirar voto propio |

Los campos originales se conservan: `mail`, `nom_usr`, `tip_usu`, `id_blog`, `titulo`, `descripcion`, `img`, `tags`, `comentario` y `blog_id`. La respuesta de `/login` ahora contiene `access_token`, `expira` y `usuario`. Los comentarios ya no aceptan `usr_id` enviado por el cliente. Las publicaciones y comentarios cargan 20 registros por página con botón Cargar más. La pantalla de usuarios carga hasta 100 cuentas; la API permite páginas, pero esa pantalla aún no incorpora navegación de páginas.

## Seguridad y alcance

Argon2id protege las contraseñas. El token aleatorio tiene 256 bits y la base solo almacena su resumen SHA-256. Las sesiones duran 60 minutos por defecto, configurable mediante SESSION_MINUTES, y se validan en cada operación. Las fechas de sesión se manejan en UTC; las fechas históricas de la base anterior no se reinterpretan ni se inventan.

Se limita CORS a los orígenes configurados, se validan entradas con Pydantic y se utilizan consultas parametrizadas. Antes de publicar en Internet faltan HTTPS, límites de intentos de acceso, recuperación de cuenta, auditoría y limpieza programada de sesiones. No hay MFA. Los secretos, los entornos y las bases de datos locales se excluyen de Git.

El alcance verificado se documenta en `reportes/evidencias/`. Las pruebas de API usan SQLite en memoria para aislamiento; la integración y el recorrido de navegador usan MySQL real local. No se afirma prueba Android/iOS ni despliegue remoto. El video personal se entrega por separado; no se incluye como si ya estuviera grabado por el estudiante.

## Pruebas

Desde la carpeta de la API, con el entorno activado:

```bash
python -m pytest tests -q
```

Desde la carpeta Flutter:

```bash
flutter analyze
flutter test
```

Los scripts de `scripts/` para evidencias crean cuentas y contenido de ensayo. No deben ejecutarse contra producción. La documentación y las pruebas corresponden a estas carpetas, no a las versiones independientes anteriores.
