import hashlib
import os
import secrets
from datetime import datetime, timedelta, timezone

from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pwdlib import PasswordHash
from sqlalchemy import select
from sqlalchemy.orm import Session

from database import obtener_sesion
from models import Sesion, Usuario

password_hash = PasswordHash.recommended()
hash_vacio = password_hash.hash(secrets.token_urlsafe(32))
bearer = HTTPBearer(auto_error=False)


def ahora():
    return datetime.now(timezone.utc).replace(tzinfo=None)


def resumen(token):
    return hashlib.sha256(token.encode()).hexdigest()


def crear_sesion(db, usuario):
    token = secrets.token_urlsafe(32)
    expira = ahora() + timedelta(minutes=int(os.getenv('SESSION_MINUTES', '60')))
    db.add(Sesion(usr_id=usuario.id_usr, token_hash=resumen(token), expira=expira))
    db.commit()
    return {'access_token': token, 'expira': expira, 'usuario': usuario}


def sesion_actual(credencial: HTTPAuthorizationCredentials | None = Depends(bearer), db: Session = Depends(obtener_sesion)):
    sesion = None
    if credencial and len(credencial.credentials) <= 200:
        sesion = db.scalar(select(Sesion).where(Sesion.token_hash == resumen(credencial.credentials)))
    if sesion is None or sesion.expira <= ahora() or db.get(Usuario, sesion.usr_id) is None:
        raise HTTPException(401, 'Sesión inválida o expirada. Inicia sesión nuevamente.', headers={'WWW-Authenticate': 'Bearer'})
    return sesion


def usuario_actual(sesion=Depends(sesion_actual), db: Session = Depends(obtener_sesion)):
    return db.get(Usuario, sesion.usr_id)


def administrador(usuario=Depends(usuario_actual)):
    if usuario.tip_usu != 1:
        raise HTTPException(403, 'Esta operación requiere un administrador.')
    return usuario


def autor_o_admin(autor_id, usuario):
    if usuario.tip_usu != 1 and autor_id != usuario.id_usr:
        raise HTTPException(403, 'Solo el autor o un administrador puede modificar este contenido.')
