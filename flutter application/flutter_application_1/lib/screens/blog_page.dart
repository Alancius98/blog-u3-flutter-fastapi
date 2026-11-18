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
      title: const Text('Mi Blog'),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const Text(
            'Bienvenido',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF08245C),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${ApiClient.usuario?['nom_usr'] ?? 'Usuario'} · ${ApiClient.esAdmin ? 'Administrador' : 'General'}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
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
          const SizedBox(height: 12),
          Wrap(
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
          const SizedBox(height: 12),
          SingleChildScrollView(
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
          ...posts.map(
            (post) => PostCard(
              post: post,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
                );
                if (mounted) cargar();
              },
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
