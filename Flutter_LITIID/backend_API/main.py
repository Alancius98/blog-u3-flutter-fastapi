import os

from fastapi import Depends, FastAPI, HTTPException, Query, Response
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import delete, func, or_, select, text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from pwdlib.exceptions import UnknownHashError

from database import obtener_sesion
from models import Usuario, Blog, Comentario, Sesion, Valoracion
from schemas import (LoginRequest, LoginRespuesta, UsuarioCrear, UsuarioActualizar, UsuarioRespuesta,
                     BlogCrear, BlogActualizar, BlogRespuesta, ComentarioCrear, ComentarioRespuesta, ValoracionCrear)
from security import (administrador, ahora, autor_o_admin, crear_sesion, hash_vacio,
                      password_hash, sesion_actual, usuario_actual)

app = FastAPI(title='API de aplicación móvil', version='2.0.0', description='Blog · Flutter, FastAPI y MySQL')
app.add_middleware(CORSMiddleware,
    allow_origins=os.getenv('CORS_ORIGINS', 'http://127.0.0.1:8080,http://localhost:8080').split(','),
    allow_credentials=False, allow_methods=['GET', 'POST', 'PUT', 'DELETE'],
    allow_headers=['Content-Type', 'Authorization'])


@app.middleware('http')
async def cabeceras(request, call_next):
    response = await call_next(request)
    response.headers['Cache-Control'] = 'no-store'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    return response


@app.get('/', tags=['Inicio'])
def inicio(db: Session = Depends(obtener_sesion)):
    db.execute(text('SELECT 1'))
    return {'mensaje': 'API funcionando correctamente', 'database': db.bind.dialect.name}


@app.post('/login', response_model=LoginRespuesta, tags=['Sesión'])
def iniciar_sesion(datos: LoginRequest, db: Session = Depends(obtener_sesion)):
    usuario = db.scalar(select(Usuario).where(Usuario.mail == str(datos.mail).lower()))
    try:
        valida = password_hash.verify(datos.password, usuario.pass_hash if usuario else hash_vacio)
    except (ValueError, UnknownHashError):
        # Los antiguos marcadores HASH_DE_PRUEBA no son credenciales válidas.
        # No se devuelve el hash ni el detalle del algoritmo al cliente.
        valida = False
    if usuario is None or not valida:
        raise HTTPException(401, 'Correo o contraseña incorrectos', headers={'WWW-Authenticate': 'Bearer'})
    return crear_sesion(db, usuario)


@app.get('/sesion', response_model=UsuarioRespuesta, tags=['Sesión'])
def perfil(usuario=Depends(usuario_actual)):
    return usuario


@app.post('/logout', status_code=204, tags=['Sesión'])
def cerrar_sesion(sesion=Depends(sesion_actual), db: Session = Depends(obtener_sesion)):
    db.delete(sesion)
    db.commit()
    return Response(status_code=204)


def guardar_usuario(datos, db):
    nombre = datos.nom_usr.strip()
    if len(nombre) < 2:
        raise HTTPException(422, 'El nombre debe tener al menos dos caracteres.')
    usuario = Usuario(nom_usr=nombre, mail=str(datos.mail).lower(), pass_hash=password_hash.hash(datos.password),
                      dir_usr=datos.dir_usr, tip_usu=datos.tip_usu)
    db.add(usuario)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, 'El correo ya está registrado')
    db.refresh(usuario)
    return usuario


@app.post('/usuarios', response_model=UsuarioRespuesta, status_code=201, tags=['Usuarios'])
def crear_usuario(datos: UsuarioCrear, db: Session = Depends(obtener_sesion)):
    if datos.tip_usu != 2:
        raise HTTPException(403, 'El registro público solo permite usuarios generales.')
    return guardar_usuario(datos, db)


@app.post('/admin/usuarios', response_model=UsuarioRespuesta, status_code=201, tags=['Usuarios'])
def crear_desde_admin(datos: UsuarioCrear, admin=Depends(administrador), db: Session = Depends(obtener_sesion)):
    return guardar_usuario(datos, db)


@app.get('/usuarios', response_model=list[UsuarioRespuesta], tags=['Usuarios'])
def listar_usuarios(offset: int = Query(0, ge=0), limit: int = Query(100, ge=1, le=100),
                    admin=Depends(administrador), db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Usuario).order_by(Usuario.id_usr).offset(offset).limit(limit)).all()


@app.put('/usuarios', response_model=UsuarioRespuesta, tags=['Usuarios'])
def actualizar_usuario(datos: UsuarioActualizar, actual=Depends(usuario_actual), db: Session = Depends(obtener_sesion)):
    autor_o_admin(datos.id_usr, actual)
    usuario = db.get(Usuario, datos.id_usr)
    if usuario is None:
        raise HTTPException(404, 'Usuario no encontrado')
    if actual.tip_usu != 1 and datos.tip_usu != usuario.tip_usu:
        raise HTTPException(403, 'No puedes cambiar tu tipo de usuario.')
    if datos.id_usr == actual.id_usr and datos.tip_usu != actual.tip_usu:
        raise HTTPException(409, 'No puedes cambiar tu propio rol desde esta pantalla.')
    usuario.nom_usr, usuario.mail = datos.nom_usr, str(datos.mail).lower()
    usuario.dir_usr, usuario.tip_usu = datos.dir_usr, datos.tip_usu
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, 'El correo ya está registrado')
    return usuario


@app.delete('/usuarios', status_code=204, tags=['Usuarios'])
def eliminar_usuario(id_usr: int, admin=Depends(administrador), db: Session = Depends(obtener_sesion)):
    if id_usr == admin.id_usr:
        raise HTTPException(409, 'No puedes eliminar tu propia cuenta desde administración.')
    usuario = db.get(Usuario, id_usr)
    if usuario is None:
        raise HTTPException(404, 'Usuario no encontrado')
    if db.scalar(select(Blog.id_blog).where(Blog.usr_id == id_usr).limit(1)) or db.scalar(select(Comentario.id_com).where(Comentario.usr_id == id_usr).limit(1)):
        raise HTTPException(409, 'El usuario tiene publicaciones o comentarios asociados.')
    db.execute(delete(Sesion).where(Sesion.usr_id == id_usr))
    db.execute(delete(Valoracion).where(Valoracion.usr_id == id_usr))
    db.delete(usuario)
    db.commit()
    return Response(status_code=204)


def buscar_blog(db, id_blog):
    publicacion = db.get(Blog, id_blog)
    if publicacion is None:
        raise HTTPException(404, 'Publicación no encontrada')
    return publicacion


def respuestas_blog(db, publicaciones, usuario):
    ids = [p.id_blog for p in publicaciones]
    if not ids:
        return []
    autores = dict(db.execute(select(Usuario.id_usr, Usuario.nom_usr).where(Usuario.id_usr.in_([p.usr_id for p in publicaciones if p.usr_id]))).all())
    comentarios = dict(db.execute(select(Comentario.blog_id, func.count()).where(Comentario.blog_id.in_(ids)).group_by(Comentario.blog_id)).all())
    votos = {r[0]: (float(r[1]), r[2]) for r in db.execute(select(Valoracion.blog_id, func.avg(Valoracion.puntos), func.count()).where(Valoracion.blog_id.in_(ids)).group_by(Valoracion.blog_id))}
    propios = dict(db.execute(select(Valoracion.blog_id, Valoracion.puntos).where(Valoracion.blog_id.in_(ids), Valoracion.usr_id == usuario.id_usr)).all())
    return [dict(id_blog=p.id_blog, titulo=p.titulo, descripcion=p.descripcion or '', img=p.img, tags=p.tags,
                 usr_id=p.usr_id, autor=autores.get(p.usr_id, 'Sin autor registrado'), fecha=p.fecha,
                 promedio=votos.get(p.id_blog, (0, 0))[0], votos=votos.get(p.id_blog, (0, 0))[1],
                 mi_valoracion=propios.get(p.id_blog), total_comentarios=comentarios.get(p.id_blog, 0)) for p in publicaciones]


@app.get('/blog', response_model=list[BlogRespuesta], tags=['Blog'])
def listar_blog(propios: bool = False, q: str = Query('', max_length=150), categoria: str = Query('', max_length=255),
                offset: int = Query(0, ge=0), limit: int = Query(100, ge=1, le=100),
                usuario=Depends(usuario_actual), db: Session = Depends(obtener_sesion)):
    consulta = select(Blog).order_by(Blog.id_blog.desc())
    if propios:
        consulta = consulta.where(Blog.usr_id == usuario.id_usr)
    if q.strip():
        consulta = consulta.where(or_(Blog.titulo.icontains(q.strip(), autoescape=True), Blog.descripcion.icontains(q.strip(), autoescape=True)))
    if categoria.strip():
        consulta = consulta.where(Blog.tags.icontains(categoria.strip(), autoescape=True))
    return respuestas_blog(db, db.scalars(consulta.offset(offset).limit(limit)).all(), usuario)


@app.post('/blog', response_model=BlogRespuesta, status_code=201, tags=['Blog'])
def crear_blog(datos: BlogCrear, usuario=Depends(usuario_actual), db: Session = Depends(obtener_sesion)):
    publicacion = Blog(**datos.model_dump(), usr_id=usuario.id_usr)
    db.add(publicacion)
    db.commit()
    db.refresh(publicacion)
    return respuestas_blog(db, [publicacion], usuario)[0]


@app.put('/blog', response_model=BlogRespuesta, tags=['Blog'])
def actualizar_blog(datos: BlogActualizar, usuario=Depends(usuario_actual), db: Session = Depends(obtener_sesion)):
    publicacion = buscar_blog(db, datos.id_blog)
    autor_o_admin(publicacion.usr_id, usuario)
    for campo, valor in datos.model_dump(exclude={'id_blog'}).items():
        setattr(publicacion, campo, valor)
    db.commit()
    return respuestas_blog(db, [publicacion], usuario)[0]


@app.delete('/blog', status_code=204, tags=['Blog'])
def eliminar_blog(id_blog: int, usuario=Depends(usuario_actual), db: Session = Depends(obtener_sesion)):
    publicacion = buscar_blog(db, id_blog)
    autor_o_admin(publicacion.usr_id, usuario)
    db.execute(delete(Comentario).where(Comentario.blog_id == id_blog))
    db.execute(delete(Valoracion).where(Valoracion.blog_id == id_blog))
    db.delete(publicacion)
    db.commit()
    return Response(status_code=204)


def respuestas_comentarios(db, comentarios):
    autores = dict(db.execute(select(Usuario.id_usr, Usuario.nom_usr).where(Usuario.id_usr.in_([c.usr_id for c in comentarios]))).all())
    return [dict(id_com=c.id_com, comentario=c.comentario, fecha=c.fecha, estatus=c.estatus,
                 usr_id=c.usr_id, blog_id=c.blog_id, autor=autores.get(c.usr_id, 'Usuario')) for c in comentarios]


@app.get('/comentarios', response_model=list[ComentarioRespuesta], tags=['Comentarios'])
def listar_comentarios(blog_id: int, offset: int = Query(0, ge=0), limit: int = Query(100, ge=1, le=100),
                       usuario=Depends(usuario_actual), db: Session = Depends(obtener_sesion)):
    buscar_blog(db, blog_id)
    lista = db.scalars(select(Comentario).where(Comentario.blog_id == blog_id).order_by(Comentario.id_com).offset(offset).limit(limit)).all()
    return respuestas_comentarios(db, lista)


@app.post('/comentarios', response_model=ComentarioRespuesta, status_code=201, tags=['Comentarios'])
def crear_comentario(datos: ComentarioCrear, usuario=Depends(usuario_actual), db: Session = Depends(obtener_sesion)):
    buscar_blog(db, datos.blog_id)
    nuevo = Comentario(**datos.model_dump(), usr_id=usuario.id_usr, estatus=1)
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return respuestas_comentarios(db, [nuevo])[0]


@app.delete('/comentarios', status_code=204, tags=['Comentarios'])
def eliminar_comentario(id_com: int, usuario=Depends(usuario_actual), db: Session = Depends(obtener_sesion)):
    comentario = db.get(Comentario, id_com)
    if comentario is None:
        raise HTTPException(404, 'Comentario no encontrado')
    autor_o_admin(comentario.usr_id, usuario)
    db.delete(comentario)
    db.commit()
    return Response(status_code=204)


@app.put('/valoraciones', response_model=BlogRespuesta, tags=['Valoraciones'])
def valorar(datos: ValoracionCrear, id_blog: int = Query(..., ge=1), usuario=Depends(usuario_actual), db: Session = Depends(obtener_sesion)):
    publicacion = buscar_blog(db, id_blog)
    voto = db.scalar(select(Valoracion).where(Valoracion.blog_id == id_blog, Valoracion.usr_id == usuario.id_usr))
    if voto:
        voto.puntos = datos.puntos
    else:
        db.add(Valoracion(blog_id=id_blog, usr_id=usuario.id_usr, puntos=datos.puntos))
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, 'La valoración cambió; actualiza e intenta nuevamente.')
    return respuestas_blog(db, [publicacion], usuario)[0]


@app.delete('/valoraciones', response_model=BlogRespuesta, tags=['Valoraciones'])
def quitar_valoracion(id_blog: int = Query(..., ge=1), usuario=Depends(usuario_actual), db: Session = Depends(obtener_sesion)):
    publicacion = buscar_blog(db, id_blog)
    db.execute(delete(Valoracion).where(Valoracion.blog_id == id_blog, Valoracion.usr_id == usuario.id_usr))
    db.commit()
    return respuestas_blog(db, [publicacion], usuario)[0]
