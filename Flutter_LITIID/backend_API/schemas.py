from datetime import datetime
from pydantic import BaseModel, ConfigDict, EmailStr, Field


class Entrada(BaseModel):
    model_config = ConfigDict(extra='forbid', str_strip_whitespace=True)


class UsuarioCrear(Entrada):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: EmailStr = Field(max_length=150)
    password: str = Field(min_length=8, max_length=128)
    dir_usr: str | None = Field(default=None, max_length=200)
    tip_usu: int = Field(default=2, strict=True, ge=1, le=2)

    # Los espacios de la contraseña son parte de la credencial.
    model_config = ConfigDict(extra='forbid')


class UsuarioActualizar(Entrada):
    id_usr: int = Field(ge=1)
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: EmailStr = Field(max_length=150)
    dir_usr: str | None = Field(default=None, max_length=200)
    tip_usu: int = Field(default=2, strict=True, ge=1, le=2)


class UsuarioRespuesta(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id_usr: int
    nom_usr: str
    mail: str
    dir_usr: str | None
    tip_usu: int


class LoginRequest(BaseModel):
    model_config = ConfigDict(extra='forbid')
    mail: EmailStr
    password: str = Field(min_length=1, max_length=128)


class LoginRespuesta(BaseModel):
    access_token: str
    token_type: str = 'bearer'
    expira: datetime
    usuario: UsuarioRespuesta


class BlogCrear(Entrada):
    titulo: str = Field(min_length=2, max_length=150)
    descripcion: str = Field(min_length=1, max_length=20000)
    img: str | None = Field(default=None, max_length=500)
    tags: str | None = Field(default=None, max_length=255)


class BlogActualizar(BlogCrear):
    id_blog: int = Field(ge=1)


class BlogRespuesta(BlogCrear):
    model_config = ConfigDict(from_attributes=True)
    id_blog: int
    usr_id: int | None
    autor: str
    fecha: datetime
    promedio: float = 0
    votos: int = 0
    mi_valoracion: int | None = None
    total_comentarios: int = 0


class ComentarioCrear(Entrada):
    comentario: str = Field(min_length=1, max_length=2000)
    blog_id: int = Field(ge=1)


class ComentarioRespuesta(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id_com: int
    comentario: str
    fecha: datetime
    estatus: int
    usr_id: int
    blog_id: int
    autor: str


class ValoracionCrear(Entrada):
    puntos: int = Field(strict=True, ge=1, le=5)
