import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/comentario_model.dart';
import '../services/api_client.dart';
import '../services/comentario_service.dart';
import '../services/post_service.dart';
import 'add_blog_page.dart';
import '../widgets/blog_theme.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;
  const PostDetailPage({super.key, required this.post});
  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late PostModel post;
  final comentario = TextEditingController();
  final servicio = ComentarioService();
  final posts = PostService();
  List<ComentarioModel> comentarios = [];
  bool cargando = true, guardando = false, votando = false, mas = false;
  String? error;
  bool get puedeEditar =>
      ApiClient.esAdmin || post.autorId == ApiClient.usuario?['id_usr'];
  @override
  void initState() {
    super.initState();
    post = widget.post;
    cargar();
  }

  @override
  void dispose() {
    comentario.dispose();
    super.dispose();
  }

  void mensaje(Object e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> cargar({bool agregar = false}) async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final nuevos = await servicio.obtenerComentarios(
        post.id,
        offset: agregar ? comentarios.length : 0,
      );
      if (mounted) {
        setState(() {
          comentarios = agregar ? [...comentarios, ...nuevos] : nuevos;
          mas = nuevos.length == 20;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<bool> confirmar(String titulo) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(titulo),
          content: const Text('Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> enviar() async {
    if (comentario.text.trim().isEmpty) {
      mensaje('Escribe un comentario.');
      return;
    }
    setState(() => guardando = true);
    try {
      await servicio.agregarComentario(
        ComentarioModel(
          comentario: comentario.text.trim(),
          usuarioId: 0,
          blogId: post.id,
        ),
      );
      comentario.clear();
      await cargar();
    } catch (e) {
      mensaje(e);
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  Future<void> valorar(int? puntos) async {
    setState(() => votando = true);
    try {
      final nuevo = puntos == null
          ? await posts.quitarValoracion(post.id)
          : await posts.valorar(post.id, puntos);
      if (mounted) setState(() => post = nuevo);
    } catch (e) {
      mensaje(e);
    } finally {
      if (mounted) setState(() => votando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Detalle'),
      actions: [
        if (puedeEditar) ...[
          IconButton(
            tooltip: 'Editar publicación',
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddBlogPage(post: post)),
              );
              if (resultado == true && context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Eliminar publicación',
            onPressed: () async {
              if (!await confirmar('¿Eliminar publicación?')) return;
              try {
                await posts.eliminar(post.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                mensaje(e);
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (post.imagen.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  post.imagen,
                  height: 320,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 80,
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              post.tags,
              style: const TextStyle(
                color: blogOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              post.titulo,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: blogInk,
              ),
            ),
            const SizedBox(height: 12),
            Text('Por ${post.autor}', style: const TextStyle(color: blogMuted)),
            const SizedBox(height: 20),
            Text(
              post.descripcion,
              style: const TextStyle(fontSize: 18, height: 1.8, color: blogInk),
            ),
            const Divider(height: 40),
            const Text(
              'Valora esta publicación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              post.votos == 0
                  ? 'Sin valoraciones'
                  : '${post.promedio.toStringAsFixed(1)} de 5 · ${post.votos} votos',
            ),
            Wrap(
              children: List.generate(
                5,
                (n) => IconButton(
                  tooltip: 'Valorar con ${n + 1} estrellas',
                  onPressed: votando ? null : () => valorar(n + 1),
                  icon: Icon(
                    n < (post.miValoracion ?? 0)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ),
            if (post.miValoracion != null)
              TextButton(
                onPressed: votando ? null : () => valorar(null),
                child: const Text('Quitar mi valoración'),
              ),
            const Divider(height: 40),
            const Text(
              'Comentarios',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: comentario,
              maxLength: 2000,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Tu comentario',
                border: OutlineInputBorder(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: guardando ? null : enviar,
                child: Text(guardando ? 'Guardando…' : 'Comentar'),
              ),
            ),
            const SizedBox(height: 16),
            if (cargando) const Center(child: CircularProgressIndicator()),
            if (error != null)
              Column(
                children: [
                  Text(error!),
                  TextButton(
                    onPressed: cargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            if (!cargando && error == null && comentarios.isEmpty)
              const Text('Todavía no hay comentarios.'),
            ...comentarios.map(
              (c) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.autor,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (ApiClient.esAdmin ||
                              c.usuarioId == ApiClient.usuario?['id_usr'])
                            IconButton(
                              tooltip: 'Eliminar comentario',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                if (!await confirmar('¿Eliminar comentario?')) {
                                  return;
                                }
                                try {
                                  await servicio.eliminar(c.id!);
                                  await cargar();
                                } catch (e) {
                                  mensaje(e);
                                }
                              },
                            ),
                        ],
                      ),
                      Text(c.comentario),
                      const SizedBox(height: 6),
                      Text(
                        c.fecha?.split('T').first ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (mas && error == null)
              TextButton(
                onPressed: cargando ? null : () => cargar(agregar: true),
                child: const Text('Cargar más comentarios'),
              ),
          ],
        ),
      ),
    ),
  );
}
