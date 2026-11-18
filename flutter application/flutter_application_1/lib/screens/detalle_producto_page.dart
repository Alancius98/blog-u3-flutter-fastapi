import 'package:flutter/material.dart';

class DetalleProductoPage extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final IconData icono;

  const DetalleProductoPage({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del producto',
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                icono,
                size: 120,
                color: Colors.green,
              ),

              const SizedBox(
                height: 25,
              ),

              Text(
                nombre,

                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Text(
                descripcion,

                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              Text(
                'Has seleccionado: $nombre',

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}