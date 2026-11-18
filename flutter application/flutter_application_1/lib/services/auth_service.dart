import 'api_client.dart';

class AuthService {
  String? validarLogin({required String usuario, required String password}) {
    return usuario.trim().isEmpty || password.isEmpty
        ? 'Ingresa tu correo y contraseña'
        : null;
  }

  Future<Map<String, dynamic>> autenticar({
    required String correo,
    required String password,
  }) async {
    final datos = Map<String, dynamic>.from(
      await ApiClient.solicitar(
        'POST',
        '/login',
        publico: true,
        datos: {'mail': correo.trim().toLowerCase(), 'password': password},
      ),
    );
    ApiClient.iniciar(datos);
    return ApiClient.usuario!;
  }
}
