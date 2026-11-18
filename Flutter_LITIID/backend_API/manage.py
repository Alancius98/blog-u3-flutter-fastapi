import argparse
from getpass import getpass
from pydantic import ValidationError
from sqlalchemy import select
from database import SessionLocal
from models import Usuario
from schemas import UsuarioCrear
from security import password_hash


def main():
    parser = argparse.ArgumentParser(description='Crear una cuenta administrativa nueva sin contraseña fija.')
    parser.add_argument('comando', choices=['create-admin'])
    parser.add_argument('--mail', required=True)
    parser.add_argument('--nombre', default='Administrador')
    args = parser.parse_args()
    password = getpass('Contraseña: ')
    if password != getpass('Confirmar contraseña: '):
        parser.exit(1, 'Las contraseñas no coinciden.\n')
    try:
        datos = UsuarioCrear(nom_usr=args.nombre, mail=args.mail, password=password, tip_usu=1)
        if len(datos.nom_usr.strip()) < 2:
            raise ValueError()
    except (ValidationError, ValueError):
        parser.exit(1, 'Revisa nombre, correo y contraseña (8–128 caracteres).\n')
    with SessionLocal() as db:
        if db.scalar(select(Usuario).where(Usuario.mail == str(datos.mail).lower())):
            parser.exit(1, 'El correo ya existe. No se modificó la cuenta.\n')
        db.add(Usuario(nom_usr=datos.nom_usr.strip(), mail=str(datos.mail).lower(), pass_hash=password_hash.hash(password), tip_usu=1))
        db.commit()
    print('Administrador creado. No compartas la contraseña en el repositorio.')


if __name__ == '__main__':
    main()
