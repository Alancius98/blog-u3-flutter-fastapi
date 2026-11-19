import 'package:flutter/material.dart';
import 'tipo_usuario_field.dart';

/// Campos compartidos por el alta y la edición del diálogo de usuarios.
class UsuarioFormFields extends StatelessWidget {
  final TextEditingController nombre, correo, direccion, password;
  final bool esEdicion, guardando;
  final int tipo;
  final ValueChanged<int> onTipoChanged;

  const UsuarioFormFields({
    super.key,
    required this.nombre,
    required this.correo,
    required this.direccion,
    required this.password,
    required this.esEdicion,
    required this.guardando,
    required this.tipo,
    required this.onTipoChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: nombre,
        enabled: !guardando,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Nombre completo'),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: correo,
        enabled: !guardando,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Correo electrónico'),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: direccion,
        enabled: !guardando,
        decoration: const InputDecoration(labelText: 'Dirección'),
      ),
      if (!esEdicion) ...[
        const SizedBox(height: 20),
        TextField(
          controller: password,
          enabled: !guardando,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Contraseña'),
        ),
      ],
      const SizedBox(height: 20),
      TipoUsuarioField(
        tipo: tipo,
        enabled: !guardando,
        onChanged: onTipoChanged,
      ),
    ],
  );
}
