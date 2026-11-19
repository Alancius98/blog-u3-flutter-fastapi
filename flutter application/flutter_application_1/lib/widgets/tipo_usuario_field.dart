import 'package:flutter/material.dart';
import 'blog_theme.dart';

class TipoUsuarioField extends StatelessWidget {
  final int tipo;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const TipoUsuarioField({
    super.key,
    required this.tipo,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Tipo de usuario',
        style: TextStyle(
          color: blogMuted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 10),
      Semantics(
        label: 'Tipo de usuario',
        child: DropdownButtonFormField<int>(
          initialValue: tipo,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.expand_more_rounded, color: blogMuted),
          decoration: const InputDecoration(
            // El título está fuera del borde; no se usa etiqueta flotante.
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          items: const [
            DropdownMenuItem(value: 2, child: Text('General')),
            DropdownMenuItem(value: 1, child: Text('Administrador')),
          ],
          onChanged: enabled
              ? (value) {
                  if (value != null) onChanged(value);
                }
              : null,
        ),
      ),
    ],
  );
}
