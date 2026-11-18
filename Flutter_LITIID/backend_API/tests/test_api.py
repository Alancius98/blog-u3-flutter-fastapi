import os
import sys
from datetime import timedelta
from pathlib import Path

os.environ['DATABASE_URL'] = 'sqlite+pysqlite:///:memory:'
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, event, select
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from database import Base, obtener_sesion
from main import app
from models import Usuario, Blog, Sesion, Valoracion
from security import ahora

engine = create_engine('sqlite://', connect_args={'check_same_thread': False}, poolclass=StaticPool)


@event.listens_for(engine, 'connect')
def fk(connection, _):
    connection.execute('PRAGMA foreign_keys=ON')


Factory = sessionmaker(bind=engine)
client = TestClient(app)


@pytest.fixture(autouse=True)
def db_aislada():
    Base.metadata.create_all(engine)
    def conexion():
        with Factory() as db:
            yield db
    app.dependency_overrides[obtener_sesion] = conexion
    yield
    app.dependency_overrides.clear()
    Base.metadata.drop_all(engine)


def cuenta(mail='usuario@example.com', admin=False):
    r = client.post('/usuarios', json={'nom_usr': 'Usuario', 'mail': mail, 'password': 'Prueba123!'})
    assert r.status_code == 201, r.text
    if admin:
        with Factory() as db:
            db.get(Usuario, r.json()['id_usr']).tip_usu = 1
            db.commit()
    login = client.post('/login', json={'mail': mail, 'password': 'Prueba123!'})
    assert login.status_code == 200, login.text
    return {'Authorization': 'Bearer '+login.json()['access_token']}, r.json()['id_usr']


def publicar(h, titulo='Una publicación'):
    r = client.post('/blog', headers=h, json={'titulo': titulo, 'descripcion': 'Contenido de prueba', 'tags': 'Flutter'})
    assert r.status_code == 201, r.text
    return r.json()['id_blog']


def test_registro_hash_y_respuesta_publica():
    h, id = cuenta()
    r = client.get('/sesion', headers=h)
    assert set(r.json()) == {'id_usr', 'nom_usr', 'mail', 'dir_usr', 'tip_usu'}
    with Factory() as db:
        assert db.get(Usuario, id).pass_hash.startswith('$argon2id$')
        assert db.scalar(select(Sesion)).token_hash != h['Authorization'].split()[1]


def test_registro_no_permite_admin_y_valida_datos():
    assert client.post('/usuarios', json={'nom_usr':'Admin','mail':'admin@example.com','password':'Prueba123!','tip_usu':1}).status_code == 403
    for body in [{'nom_usr':'  ','mail':'a@example.com','password':'Prueba123!'}, {'nom_usr':'Ana','mail':'incorrecto','password':'Prueba123!'}, {'nom_usr':'Ana','mail':'a@example.com','password':'corta'}]:
        assert client.post('/usuarios', json=body).status_code == 422


def test_correo_duplicado():
    cuenta()
    assert client.post('/usuarios', json={'nom_usr':'Otro','mail':'USUARIO@example.com','password':'Prueba123!'}).status_code == 409


def test_login_incorrecto_y_hash_heredado():
    cuenta()
    for mail in ['usuario@example.com', 'nadie@example.com']:
        assert client.post('/login', json={'mail':mail,'password':'Incorrecta'}).status_code == 401
    with Factory() as db:
        db.scalar(select(Usuario)).pass_hash = 'HASH_DE_PRUEBA'
        db.commit()
    assert client.post('/login', json={'mail':'usuario@example.com','password':'Incorrecta'}).status_code == 401


def test_rutas_protegidas():
    assert client.get('/blog').status_code == 401
    assert client.get('/usuarios').status_code == 401
    assert client.post('/comentarios', json={'comentario':'Hola','blog_id':1}).status_code == 401


def test_expiracion_y_revocacion():
    h, _ = cuenta()
    with Factory() as db:
        db.scalar(select(Sesion)).expira = ahora()-timedelta(seconds=1)
        db.commit()
    assert client.get('/blog', headers=h).status_code == 401
    login = client.post('/login', json={'mail':'usuario@example.com','password':'Prueba123!'}).json()
    h = {'Authorization':'Bearer '+login['access_token']}
    assert client.post('/logout', headers=h).status_code == 204
    assert client.get('/blog', headers=h).status_code == 401


def test_autoria_y_filtro_propios():
    a, id = cuenta()
    b, _ = cuenta('otro@example.com')
    post = publicar(a)
    assert client.get('/blog', headers=b).json()[0]['usr_id'] == id
    assert client.get('/blog?propios=true', headers=b).json() == []
    assert len(client.get('/blog?propios=true', headers=a).json()) == 1
    assert client.put('/blog', headers=b, json={'id_blog':post,'titulo':'Cambio','descripcion':'Sin permiso'}).status_code == 403
    assert client.delete(f'/blog?id_blog={post}', headers=b).status_code == 403


def test_publicacion_asigna_autor_servidor():
    a, _ = cuenta()
    assert client.post('/blog', headers=a, json={'titulo':'Hola','descripcion':'Texto','usr_id':99}).status_code == 422
    assert client.post('/blog', headers=a, json={'titulo':'  ','descripcion':'Texto'}).status_code == 422


def test_comentarios_por_publicacion_y_suplantacion():
    a, _ = cuenta()
    b, id = cuenta('otro@example.com')
    post = publicar(a)
    r = client.post('/comentarios', headers=b, json={'blog_id':post,'comentario':'Buena idea 🌿'})
    assert r.status_code == 201 and r.json()['usr_id'] == id
    assert client.get(f'/comentarios?blog_id={post}', headers=a).json()[0]['comentario'] == 'Buena idea 🌿'
    assert client.post('/comentarios', headers=b, json={'blog_id':post,'comentario':'Hola','usr_id':99}).status_code == 422
    assert client.post('/comentarios', headers=b, json={'blog_id':999,'comentario':'Hola'}).status_code == 404
    assert client.delete('/comentarios?id_com='+str(r.json()['id_com']), headers=a).status_code == 403
    assert client.delete('/comentarios?id_com='+str(r.json()['id_com']), headers=b).status_code == 204


def test_admin_gestiona_y_modera():
    a, id = cuenta()
    admin, _ = cuenta('admin@example.com', True)
    post = publicar(a)
    assert client.get('/usuarios', headers=a).status_code == 403
    assert len(client.get('/usuarios', headers=admin).json()) == 2
    assert client.put('/blog', headers=admin, json={'id_blog':post,'titulo':'Moderada','descripcion':'Revisada'}).status_code == 200
    assert client.delete(f'/blog?id_blog={post}', headers=admin).status_code == 204
    assert client.post('/admin/usuarios', headers=a, json={'nom_usr':'Nuevo','mail':'nuevo@example.com','password':'Prueba123!'}).status_code == 403
    assert client.post('/admin/usuarios', headers=admin, json={'nom_usr':'Nuevo','mail':'nuevo@example.com','password':'Prueba123!','tip_usu':1}).status_code == 201


def test_perfil_no_escala_privilegios():
    a, id = cuenta()
    b, other = cuenta('otro@example.com')
    data = {'id_usr':id,'nom_usr':'Nombre nuevo','mail':'usuario@example.com','tip_usu':2}
    assert client.put('/usuarios', headers=a, json=data).status_code == 200
    assert client.put('/usuarios', headers=b, json=data).status_code == 403
    assert client.put('/usuarios', headers=a, json={**data,'tip_usu':1}).status_code == 403


def test_valoracion_unica_promedio_y_retiro():
    a, _ = cuenta()
    b, _ = cuenta('otro@example.com')
    post = publicar(a)
    ruta = f'/blog/{post}/valoracion'
    assert client.put(ruta, headers=a, json={'puntos':5}).json()['votos'] == 1
    r = client.put(ruta, headers=b, json={'puntos':3}).json()
    assert r['promedio'] == 4 and r['mi_valoracion'] == 3
    r = client.put(ruta, headers=a, json={'puntos':1}).json()
    assert r['votos'] == 2 and r['promedio'] == 2
    assert client.delete(ruta, headers=a).json()['votos'] == 1
    for puntos in [0,6,True,2.5,'5']:
        assert client.put(ruta, headers=a, json={'puntos':puntos}).status_code == 422


def test_busqueda_y_paginacion():
    a, _ = cuenta()
    id = publicar(a, 'Objetivo único')
    for n in range(3): publicar(a, f'Otra {n}')
    assert client.get('/blog?limit=1', headers=a).json()[0]['id_blog'] != id
    assert client.get('/blog?q=Objetivo&limit=1', headers=a).json()[0]['id_blog'] == id
    assert client.get('/blog?q=%25', headers=a).json() == []
    assert client.get('/blog?categoria=NoExiste', headers=a).json() == []


def test_borrado_relaciones():
    a, _ = cuenta()
    post = publicar(a)
    client.post('/comentarios', headers=a, json={'blog_id':post,'comentario':'Prueba'})
    client.put(f'/blog/{post}/valoracion', headers=a, json={'puntos':5})
    assert client.delete(f'/blog?id_blog={post}', headers=a).status_code == 204
    with Factory() as db:
        assert db.scalar(select(Valoracion)) is None
    assert client.get(f'/comentarios?blog_id={post}', headers=a).status_code == 404


def test_entradas_antiguas_conservan_autoria_desconocida():
    a, _ = cuenta()
    with Factory() as db:
        db.add(Blog(titulo='Anterior', descripcion='Conservada', usr_id=None))
        db.commit()
    assert client.get('/blog', headers=a).json()[0]['autor'] == 'Sin autor registrado'
    assert client.get('/blog?propios=true', headers=a).json() == []


def test_estado_y_cabeceras():
    r = client.get('/')
    assert r.status_code == 200 and r.json()['database'] == 'sqlite'
    assert r.headers['cache-control'] == 'no-store'
