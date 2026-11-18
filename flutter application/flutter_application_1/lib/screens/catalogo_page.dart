import 'package:flutter/material.dart';

import '../widgets/barra_herramientas.dart';
import '../widgets/menu_lateral.dart';

import 'detalle_producto_page.dart';

class CatalogoPage extends StatelessWidget {
  const CatalogoPage({
    super.key,
  });

  static const List<Map<String, String>> productos = [
    {
      'nombre': 'Laptop',
      'descripcion': 'Computadora portátil',
      'icono': 'laptop',
    },
    {
      'nombre': 'Smartphone',
      'descripcion': 'Teléfono inteligente',
      'icono': 'phone',
    },
    {
      'nombre': 'Audífonos',
      'descripcion': 'Audífonos inalámbricos',
      'icono': 'headphones',
    },
    {
      'nombre': 'Tablet',
      'descripcion': 'Dispositivo portátil',
      'icono': 'tablet',
    },
    {
      'nombre': 'Smartwatch',
      'descripcion': 'Reloj inteligente',
      'icono': 'watch',
    },
    {
      'nombre': 'Teclado',
      'descripcion': 'Teclado para computadora',
      'icono': 'keyboard',
    },
  ];

  IconData obtenerIcono(String icono) {
    switch (icono) {
      case 'laptop':
        return Icons.laptop;

      case 'phone':
        return Icons.phone_android;

      case 'headphones':
        return Icons.headphones;

      case 'tablet':
        return Icons.tablet;

      case 'watch':
        return Icons.watch;

      case 'keyboard':
        return Icons.keyboard;

      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraHerramientas(
        context,
        'Catálogo',
      ),

      drawer: const MenuLateral(),

      body: ListView.builder(
        itemCount: productos.length,

        itemBuilder: (context, index) {
          final producto = productos[index];

          return Card(
            margin: const EdgeInsets.all(10),

            child: ListTile(
              leading: Icon(
                obtenerIcono(
                  producto['icono']!,
                ),

                size: 35,
              ),

              title: Text(
                producto['nombre']!,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                producto['descripcion']!,
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) =>
                        DetalleProductoPage(
                      nombre:
                          producto['nombre']!,

                      descripcion:
                          producto['descripcion']!,

                      icono:
                          obtenerIcono(
                        producto['icono']!,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}