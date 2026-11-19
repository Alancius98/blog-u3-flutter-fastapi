import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/category_chip.dart';
import '../services/post_service.dart';
import '../services/api_client.dart';
import '../widgets/post_card.dart';
import '../models/post_model.dart';
import 'post_detail_page.dart';
import 'add_blog_page.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/blog_theme.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});
  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final PostService postService = PostService();
  final buscar = TextEditingController();
  Timer? pausa;
  List<PostModel> posts = [];
  bool propios = false, cargando = true, mas = false;
  String categoria = '';
  String? error;
  int revision = 0;
  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  void dispose() {
    pausa?.cancel();
    buscar.dispose();
    super.dispose();
  }

  Future<void> cargar({bool agregar = false}) async {
    final actual = ++revision;
    setState(() {
      cargando = true;
      error = null;
      if (!agregar) posts = [];
    });
    try {
      final nuevos = await postService.obtenerPosts(
        propios: propios,
        buscar: buscar.text.trim(),
        categoria: categoria,
        offset: agregar ? posts.length : 0,
      );
      if (mounted && actual == revision) {
        setState(() {
          posts = agregar ? [...posts, ...nuevos] : nuevos;
          mas = nuevos.length == 20;
        });
      }
    } catch (e) {
      if (mounted && actual == revision) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted && actual == revision) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const BlogBrand(),
      actions: [
        IconButton(
          tooltip: 'Actualizar',
          onPressed: cargar,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    drawer: AdminDrawer(usuario: ApiClient.usuario ?? {}, rutaActual: '/blog'),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBlogPage()),
        );
        if (mounted) cargar();
      },
      icon: const Icon(Icons.edit),
      label: const Text('Escribir'),
    ),
    body: RefreshIndicator(
      onRefresh: cargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E2D2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HISTORIAS QUE CONECTAN',
                      style: TextStyle(
                        color: blogOrange,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Cada idea tiene\nuna historia.',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        color: blogInk,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Hola, ${ApiClient.usuario?['nom_usr'] ?? 'Usuario'}. Lee, comparte y comienza una conversación.',
                      style: const TextStyle(color: blogMuted, height: 1.6),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      ApiClient.esAdmin
                          ? 'Tu espacio · Administrador'
                          : 'Tu espacio · General',
                      style: const TextStyle(
                        color: blogOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: TextField(
                controller: buscar,
                decoration: const InputDecoration(
                  labelText: 'Buscar publicaciones',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  pausa?.cancel();
                  pausa = Timer(const Duration(milliseconds: 400), cargar);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todas las publicaciones'),
                      selected: !propios,
                      onSelected: (_) {
                        setState(() => propios = false);
                        cargar();
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Mis publicaciones'),
                      selected: propios,
                      onSelected: (_) {
                        setState(() => propios = true);
                        cargar();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['', 'Flutter', 'IA', 'Diseño']
                      .map(
                        (valor) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CategoryChip(
                            text: valor.isEmpty ? 'Todos' : valor,
                            selected: categoria == valor,
                            onTap: () {
                              setState(() => categoria = valor);
                              cargar();
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (cargando && posts.isEmpty)
            const Center(child: CircularProgressIndicator()),
          if (error != null)
            Column(
              children: [
                Text(error!),
                TextButton(
                  onPressed: () => cargar(agregar: posts.isNotEmpty),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          if (!cargando && error == null && posts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No hay publicaciones con estos filtros.'),
            ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: LayoutBuilder(
                builder: (context, size) {
                  final columns = size.maxWidth >= 1050
                      ? 3
                      : size.maxWidth >= 680
                      ? 2
                      : 1;
                  final width = (size.maxWidth - (columns - 1) * 24) / columns;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: posts
                        .map(
                          (post) => SizedBox(
                            width: width,
                            child: PostCard(
                              post: post,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PostDetailPage(post: post),
                                  ),
                                );
                                if (mounted) cargar();
                              },
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ),
          if (mas && posts.isNotEmpty && error == null)
            TextButton(
              onPressed: cargando ? null : () => cargar(agregar: true),
              child: Text(cargando ? 'Cargando…' : 'Cargar más publicaciones'),
            ),
        ],
      ),
    ),
  );
}
