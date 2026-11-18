class PostModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String imagen;
  final String tags;
  final int? autorId, miValoracion;
  final String autor, fecha;
  final int votos, totalComentarios;
  final double promedio;

  const PostModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.tags,
    this.autorId,
    this.miValoracion,
    this.autor = '',
    this.fecha = '',
    this.votos = 0,
    this.totalComentarios = 0,
    this.promedio = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: _toInt(json['id_blog'] ?? json['id']),
      titulo: (json['titulo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      imagen: (json['img'] ?? '').toString(),
      tags: (json['tags'] ?? '').toString(),
      autorId: json['usr_id'],
      miValoracion: json['mi_valoracion'],
      autor: json['autor'] ?? 'Sin autor registrado',
      fecha: json['fecha'] ?? '',
      votos: json['votos'] ?? 0,
      totalComentarios: json['total_comentarios'] ?? 0,
      promedio: (json['promedio'] as num? ?? 0).toDouble(),
    );
  }

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}
