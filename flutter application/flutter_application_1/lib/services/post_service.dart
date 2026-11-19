import '../models/post_model.dart';
import 'api_client.dart';

class PostService {
  Future<PostModel> agregarPost({
    required String titulo,
    required String descripcion,
    String? imagen,
    String? tags,
    int? id,
  }) async {
    final data = await ApiClient.solicitar(
      id == null ? 'POST' : 'PUT',
      '/blog',
      datos: {
        'id_blog': ?id,
        'titulo': titulo.trim(),
        'descripcion': descripcion.trim(),
        'img': (imagen ?? '').trim().isEmpty ? null : imagen!.trim(),
        'tags': (tags ?? '').trim().isEmpty ? null : tags!.trim(),
      },
    );
    return PostModel.fromJson(data);
  }

  Future<List<PostModel>> obtenerPosts({
    bool propios = false,
    String buscar = '',
    String categoria = '',
    int offset = 0,
  }) async =>
      (await ApiClient.solicitar(
                'GET',
                Uri(
                  path: '/blog',
                  queryParameters: {
                    'propios': '$propios',
                    'q': buscar,
                    'categoria': categoria,
                    'offset': '$offset',
                    'limit': '20',
                  },
                ).toString(),
              )
              as List)
          .map((e) => PostModel.fromJson(e))
          .toList();

  Future<void> eliminar(int id) async {
    await ApiClient.solicitar('DELETE', '/blog?id_blog=$id');
  }

  Future<PostModel> valorar(int id, int puntos) async => PostModel.fromJson(
    await ApiClient.solicitar(
      'PUT',
      '/valoraciones?id_blog=$id',
      datos: {'puntos': puntos},
    ),
  );
  Future<PostModel> quitarValoracion(int id) async => PostModel.fromJson(
    await ApiClient.solicitar('DELETE', '/valoraciones?id_blog=$id'),
  );
}
