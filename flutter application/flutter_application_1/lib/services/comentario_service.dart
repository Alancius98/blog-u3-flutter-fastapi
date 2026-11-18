import '../models/comentario_model.dart';
import 'api_client.dart';

class ComentarioService {
  Future<List<ComentarioModel>> obtenerComentarios(
    int blogId, {
    int offset = 0,
  }) async =>
      (await ApiClient.solicitar(
                'GET',
                '/comentarios?blog_id=$blogId&offset=$offset&limit=20',
              )
              as List)
          .map((e) => ComentarioModel.fromJson(e))
          .toList();
  Future<void> agregarComentario(ComentarioModel comentario) async {
    await ApiClient.solicitar(
      'POST',
      '/comentarios',
      datos: {
        'comentario': comentario.comentario,
        'blog_id': comentario.blogId,
      },
    );
  }

  Future<void> eliminar(int id) async {
    await ApiClient.solicitar('DELETE', '/comentarios?id_com=$id');
  }
}
