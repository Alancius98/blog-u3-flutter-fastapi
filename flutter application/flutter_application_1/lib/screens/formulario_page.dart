import 'package:flutter/material.dart';

import '../widgets/barra_herramientas.dart';
import '../widgets/menu_lateral.dart';

class FormularioPage extends StatefulWidget {
  const FormularioPage({
    super.key,
  });

  @override
  State<FormularioPage> createState() =>
      _FormularioPageState();
}

class _FormularioPageState
    extends State<FormularioPage> {

  final _formKey =
      GlobalKey<FormState>();

  String nombre = '';
  String correo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraHerramientas(
        context,
        'Formulario',
      ),

      drawer: const MenuLateral(),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              // NOMBRE
              TextFormField(
                decoration:
                    const InputDecoration(
                  labelText: 'Nombre',
                  border:
                      OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }

                  return null;
                },

                onSaved: (value) {
                  nombre = value!;
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // CORREO
              TextFormField(
                decoration:
                    const InputDecoration(
                  labelText: 'Correo',
                  border:
                      OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      !value.contains('@')) {
                    return 'Ingresa un correo válido';
                  }

                  return null;
                },

                onSaved: (value) {
                  correo = value!;
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // BOTÓN
              ElevatedButton(
                child: const Text(
                  'Enviar',
                ),

                onPressed: () {
                  if (_formKey.currentState!
                      .validate()) {

                    _formKey.currentState!
                        .save();

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Datos: $nombre - $correo',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}