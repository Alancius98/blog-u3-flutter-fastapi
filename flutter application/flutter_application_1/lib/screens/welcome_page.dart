import 'package:flutter/material.dart';
import '../widgets/blog_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, size) {
          final mobile = size.maxWidth < 700;
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: mobile ? 20 : 48,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      const Expanded(child: BlogBrand()),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text('Iniciar sesión'),
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: mobile ? 650 : 620, minWidth: size.maxWidth),
                  child: Stack(
                    children: [
                      Positioned.fill(child: Image.asset(
                        'assets/images/blog_cover.jpg',
                        fit: BoxFit.cover,
                      )),
                      const Positioned.fill(child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xE63C2115),
                              Color(0xA63C2115),
                              Color(0x403C2115),
                            ],
                          ),
                        ),
                      )),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: mobile ? 26 : 48, vertical: mobile ? 72 : 100),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 640,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'UN ESPACIO PARA TUS IDEAS',
                                      style: TextStyle(
                                        color: Color(0xFFFFD8BB),
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Comparte lo que\nte inspira.',
                                      style: TextStyle(
                                        fontSize: mobile ? 46 : 70,
                                        height: 1.08,
                                        letterSpacing: -2,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Una historia, una idea o algo que acabas de aprender.\nDale un lugar y comienza la conversación.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        height: 1.6,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    ElevatedButton.icon(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/register',
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_forward_rounded,
                                      ),
                                      label: const Text('Crear mi cuenta'),
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/login',
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Text(
                                        'Ya tengo cuenta · Entrar',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 56,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Column(
                      children: [
                        const Text(
                          'Tu voz. Tus historias. Tu comunidad.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: blogInk,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Un blog para escribir a tu manera y descubrir otras perspectivas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: blogMuted,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Wrap(
                          spacing: 28,
                          runSpacing: 28,
                          alignment: WrapAlignment.center,
                          children: const [
                            _Feature(
                              icon: Icons.article_outlined,
                              title: 'Publica tus ideas',
                              text:
                                  'Comparte texto, imágenes y los temas que te interesan.',
                            ),
                            _Feature(
                              icon: Icons.forum_outlined,
                              title: 'Abre la conversación',
                              text:
                                  'Lee otras historias y participa con tus comentarios.',
                            ),
                            _Feature(
                              icon: Icons.star_outline_rounded,
                              title: 'Encuentra inspiración',
                              text:
                                  'Explora publicaciones y valora tus favoritas.',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Text(
                    'Mi Blog · Un espacio para compartir',
                    style: TextStyle(color: blogMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title, text;
  const _Feature({required this.icon, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 280,
    child: Column(
      children: [
        Icon(icon, color: blogOrange, size: 34),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            color: blogInk,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: blogMuted, height: 1.6),
        ),
      ],
    ),
  );
}
