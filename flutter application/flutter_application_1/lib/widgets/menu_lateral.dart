import 'package:flutter/material.dart';

import '../screens/home_page.dart';
import '../screens/catalogo_page.dart';
import '../screens/formulario_page.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,

        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Icon(
                  Icons.account_circle,
                  size: 64,
                  color: Colors.white,
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  'Menú de Prácticas',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // INICIO
          ListTile(
            leading: const Icon(
              Icons.home,
            ),

            title: const Text(
              'Inicio',
            ),

            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const HomePage(),
                ),
              );
            },
          ),

          // CATALOGO
          ListTile(
            leading: const Icon(
              Icons.list,
            ),

            title: const Text(
              'Catálogo',
            ),

            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CatalogoPage(),
                ),
              );
            },
          ),

          // FORMULARIO
          ListTile(
            leading: const Icon(
              Icons.input,
            ),

            title: const Text(
              'Formulario',
            ),

            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const FormularioPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}