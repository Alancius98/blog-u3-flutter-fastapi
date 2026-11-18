class UserModel {
  final int id;
  final String nombre;
  final String correo;
  final String? password;
  final String? direccion;
  final int tipoUsuario;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    this.password,
    this.direccion,
    this.tipoUsuario = 2,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _toInt(json['id_usr'] ?? json['id'], fallback: 0),
      nombre: (json['nom_usr'] ?? json['nombre'] ?? '').toString(),
      correo: (json['mail'] ?? json['correo'] ?? '').toString(),
      direccion: (json['dir_usr'] ?? json['direccion'])?.toString(),
      tipoUsuario: _toInt(json['tip_usu'] ?? 1),
    );
  }

  Map<String, dynamic> toJsonCrear() {
    return {
      'nom_usr': nombre,
      'mail': correo,
      'password': password,
      'dir_usr': direccion,
      'tip_usu': tipoUsuario,
    };
  }

  static int _toInt(dynamic value, {int fallback = 1}) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? fallback;
}
