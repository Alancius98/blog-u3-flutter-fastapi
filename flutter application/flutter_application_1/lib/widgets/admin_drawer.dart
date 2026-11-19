import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'blog_theme.dart';

class AdminDrawer extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final String rutaActual;

  const AdminDrawer({
    super.key,
    required this.usuario,
    required this.rutaActual,
  });

  String get nombre =>
      ApiClient.usuario?['nom_usr']?.toString() ??
      usuario['nom_usr']?.toString() ??
      'Usuario';
  String get correo =>
      ApiClient.usuario?['mail']?.toString() ??
      usuario['mail']?.toString() ??
      '';

  void _navegar(BuildContext context, String ruta) {
    Navigator.pop(context);
    if (ruta == rutaActual) return;
    Navigator.pushReplacementNamed(context, ruta, arguments: usuario);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF9C421D)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: blogOrange,
                  size: 34,
                ),
              ),
              accountName: Text(nombre),
              accountEmail: Text(correo),
            ),
            if (ApiClient.esAdmin)
              _opcion(
                context,
                Icons.people_alt_outlined,
                'Gestión de usuarios',
                '/users',
              ),
            if (ApiClient.esAdmin)
              _opcion(
                context,
                Icons.person_add_alt_1,
                'Registrar usuario',
                '/register',
              ),
            _opcion(context, Icons.post_add, 'Agregar blog', '/add-blog'),
            _opcion(context, Icons.article_outlined, 'Ver blog', '/blog'),
            _opcion(
              context,
              Icons.account_circle_outlined,
              'Mi perfil',
              '/profile',
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                try {
                  await ApiClient.cerrarSesion();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _opcion(
    BuildContext context,
    IconData icono,
    String titulo,
    String ruta,
  ) {
    final seleccionado = ruta == rutaActual;
    return ListTile(
      leading: Icon(icono, color: seleccionado ? blogOrange : null),
      title: Text(titulo),
      selected: seleccionado,
      onTap: () => _navegar(context, ruta),
    );
  }
}
