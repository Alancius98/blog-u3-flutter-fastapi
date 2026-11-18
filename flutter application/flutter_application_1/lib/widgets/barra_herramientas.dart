import 'package:flutter/material.dart';

PreferredSizeWidget barraHerramientas(
  BuildContext context,
  String titulo,
) {
  return AppBar(
    title: Text(titulo),

    actions: [
      // BOTÓN BUSCAR
      IconButton(
        icon: const Icon(Icons.search),
        tooltip: 'Buscar',

        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acción: Buscar'),
            ),
          );
        },
      ),

      // BOTÓN REFRESCAR
      IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: 'Refrescar',

        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acción: Refrescar'),
            ),
          );
        },
      ),

      // MENÚ
      PopupMenuButton<String>(
        onSelected: (value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Opción seleccionada: $value',
              ),
            ),
          );
        },

        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'Configuración',
            child: Text('Configuración'),
          ),

          const PopupMenuItem(
            value: 'Acerca de',
            child: Text('Acerca de'),
          ),
        ],
      ),
    ],
  );
}