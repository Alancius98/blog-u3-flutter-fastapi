import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),

      elevation: 4,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: onTap,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // IMAGEN
            if (post.imagen.isNotEmpty) Image.network(
              post.imagen,

              height: 180,

              width: double.infinity,

              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                height: 180,
                child: Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // CATEGORÍA
                  Text(
                    post.tags,

                    style: const TextStyle(
                      color: Color(0xFF2196F3),

                      fontWeight: FontWeight.bold,

                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    post.autor,
                    style: const TextStyle(
                      color: Color(0xFF08245C),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // TÍTULO
                  Text(
                    post.titulo,

                    style: const TextStyle(
                      fontSize: 20,

                      fontWeight: FontWeight.bold,

                      color: Color(0xFF08245C),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DESCRIPCIÓN
                  Text(
                    post.descripcion,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '★ ${post.votos == 0 ? 'Sin valoraciones' : post.promedio.toStringAsFixed(1)} · ${post.totalComentarios} comentarios',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
