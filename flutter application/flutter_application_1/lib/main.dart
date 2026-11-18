import 'package:flutter/material.dart';

import 'screens/login_user_page.dart';
import 'screens/register_user_page.dart';
import 'screens/blog_page.dart';
import 'screens/add_blog_page.dart';
import 'screens/profile_page.dart';
import 'pages/users_page.dart';
import 'services/api_client.dart';

void main() {
  runApp(const SessionGuard(child: LoginApp()));
}

class SessionGuard extends StatefulWidget {
  final Widget child;
  const SessionGuard({super.key, required this.child});
  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> with WidgetsBindingObserver {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); }
  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ApiClient.verificarSesion().catchError((Object _) {});
  }
  @override
  Widget build(BuildContext context) => widget.child;
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Mi aplicacion',
      navigatorKey: ApiClient.navigatorKey,
      onGenerateRoute: (settings) {
        final ruta = settings.name ?? '/login';
        final protegida = ruta != '/login' && ruta != '/register';
        if (protegida && !ApiClient.autenticado) {
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
        if (ruta == '/users' && !ApiClient.esAdmin) {
          return MaterialPageRoute(builder: (_) => const BlogPage());
        }
        final pagina = switch (ruta) {
          '/register' => const RegisterPage(),
          '/users' => const UsersPage(),
          '/blog' => const BlogPage(),
          '/add-blog' => const AddBlogPage(),
          '/profile' => const ProfilePage(),
          _ => const LoginPage(),
        };
        return MaterialPageRoute(settings: settings, builder: (_) => pagina);
      },

      initialRoute: '/login',
    );
  }
}
