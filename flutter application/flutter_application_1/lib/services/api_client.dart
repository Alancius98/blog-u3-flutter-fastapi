import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// La sesión solo permanece en memoria; el servidor verifica cada operación.
class ApiClient {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static String? _token;
  static Map<String, dynamic>? usuario;
  static bool get autenticado => _token != null;
  static bool get esAdmin => usuario?['tip_usu'] == 1;

  static void iniciar(Map<String, dynamic> datos) {
    _token = datos['access_token'] as String;
    usuario = Map<String, dynamic>.from(datos['usuario']);
  }

  static void limpiar() {
    _token = null;
    usuario = null;
  }

  static Future<void> cerrarSesion() async {
    await solicitar('POST', '/logout');
    limpiar();
  }

  static Future<void> verificarSesion() async {
    if (_token == null) return;
    usuario = Map<String, dynamic>.from(await solicitar('GET', '/sesion'));
  }

  static Future<dynamic> solicitar(
    String metodo,
    String ruta, {
    Map<String, dynamic>? datos,
    bool publico = false,
  }) async {
    final request = http.Request(
      metodo,
      Uri.parse('${ApiConfig.baseUrl}$ruta'),
    );
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    if (!publico && _token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    if (datos != null) request.body = jsonEncode(datos);
    final client = http.Client();
    try {
      final response = await client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
      dynamic body;
      try {
        body = response.body.isEmpty
            ? null
            : jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        throw Exception('La API devolvió una respuesta no válida.');
      }
      if (response.statusCode == 401 && !publico) {
        limpiar();
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (_) => false,
        );
      }
      if (response.statusCode >= 400) {
        final detail = body is Map ? body['detail'] : null;
        throw Exception(
          detail is String ? detail : 'Revisa los datos del formulario.',
        );
      }
      return body;
    } on TimeoutException {
      throw Exception('La API tardó demasiado. Intenta nuevamente.');
    } on http.ClientException {
      throw Exception('No se pudo conectar con la API. Revisa la conexión.');
    } finally {
      client.close();
    }
  }
}
