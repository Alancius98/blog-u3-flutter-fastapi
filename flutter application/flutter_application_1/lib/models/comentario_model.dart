class ComentarioModel {
  final int? id;
  final String comentario;
  final String? fecha;
  final int estatus;
  final int usuarioId;
  final int blogId;
  final String autor;

  const ComentarioModel({
    this.id,
    required this.comentario,
    this.fecha,
    this.estatus = 1,
    required this.usuarioId,
    required this.blogId,
    this.autor = 'Usuario',
  });

  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      id: _toIntOrNull(json['id_com']),
      comentario: (json['comentario'] ?? '').toString(),
      fecha: json['fecha']?.toString(),
      estatus: _toInt(json['estatus'] ?? 1),
      usuarioId: _toInt(json['usr_id']),
      blogId: _toInt(json['blog_id']),
      autor: json['autor'] ?? 'Usuario',
    );
  }

  Map<String, dynamic> toJsonCrear() => {
    'comentario': comentario,
    'usr_id': usuarioId,
    'blog_id': blogId,
  };

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  static int? _toIntOrNull(dynamic value) =>
      value == null ? null : _toInt(value);
}
