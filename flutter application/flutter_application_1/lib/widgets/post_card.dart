import 'package:flutter/material.dart';
import '../models/post_model.dart';
import 'blog_theme.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  const PostCard({super.key, required this.post, required this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Abrir publicación: ${post.titulo}',
    excludeSemantics: true,
    child: Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8DFD4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: post.imagen.isNotEmpty
                  ? Image.network(
                      post.imagen,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.tags.isEmpty ? 'HISTORIAS' : post.tags.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: blogOrange,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: blogInk,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: blogMuted,
                      fontSize: 14,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 17,
                        color: blogOrange,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          post.autor,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: blogInk),
                        ),
                      ),
                      if (post.fecha.isNotEmpty)
                        Text(
                          post.fecha.split('T').first,
                          style: const TextStyle(
                            fontSize: 10,
                            color: blogMuted,
                          ),
                        ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(height: 1),
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Color(0xFFAB701B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.votos == 0
                                ? 'Sin valoraciones'
                                : '${post.promedio.toStringAsFixed(1)} · ${post.votos} votos',
                            style: const TextStyle(
                              fontSize: 11,
                              color: blogMuted,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 15,
                            color: blogMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${post.totalComentarios} comentarios',
                            style: const TextStyle(
                              fontSize: 11,
                              color: blogMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Text(
                        'Leer historia',
                        style: TextStyle(
                          color: blogOrange,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 17, color: blogOrange),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _placeholder() => Container(
    color: const Color(0xFFF5E4D6),
    child: const Center(
      child: Icon(Icons.auto_stories_outlined, color: blogOrange, size: 48),
    ),
  );
}
