import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  Future<List<UserModel>> obtenerUsuarios({int offset = 0}) async =>
      (await ApiClient.solicitar('GET', '/usuarios?offset=$offset&limit=100')
              as List)
          .map((e) => UserModel.fromJson(e))
          .toList();

  Future<UserModel> agregarUsuario(UserModel usuario) async =>
      UserModel.fromJson(
        await ApiClient.solicitar(
          'POST',
          ApiClient.esAdmin ? '/admin/usuarios' : '/usuarios',
          publico: !ApiClient.esAdmin,
          datos: usuario.toJsonCrear(),
        ),
      );

  Future<UserModel> actualizarUsuario(UserModel usuario) async {
    final data = await ApiClient.solicitar(
      'PUT',
      '/usuarios',
      datos: {
        'id_usr': usuario.id,
        'nom_usr': usuario.nombre,
        'mail': usuario.correo,
        'dir_usr': usuario.direccion,
        'tip_usu': usuario.tipoUsuario,
      },
    );
    if (ApiClient.usuario?['id_usr'] == usuario.id) {
      ApiClient.usuario = Map<String, dynamic>.from(data);
    }
    return UserModel.fromJson(data);
  }

  Future<void> eliminarUsuario(int id) async {
    await ApiClient.solicitar('DELETE', '/usuarios?id_usr=$id');
  }
}
