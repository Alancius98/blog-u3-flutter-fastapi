import 'package:flutter/material.dart';

import '../widgets/barra_herramientas.dart';
import '../widgets/menu_lateral.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraHerramientas(
        context,
        'Inicio',
      ),

      drawer: const MenuLateral(),

      body: const Center(
        child: Text(
          'Bienvenido a mi aplicación',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}