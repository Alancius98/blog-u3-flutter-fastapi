import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/widgets/blog_theme.dart';
import 'package:flutter_application_1/widgets/usuario_form_fields.dart';

void main() {
  for (final esEdicion in [true, false]) {
    testWidgets(
      'Campos separados en ${esEdicion ? 'edición' : 'registro'} a 390 px',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controllers = List.generate(4, (_) => TextEditingController());
        controllers[0].text = 'Usuario General';
        controllers[1].text = 'lector.blog@example.com';
        controllers[2].text = 'Querétaro';
        await tester.pumpWidget(
          MaterialApp(
            theme: buildBlogTheme(),
            home: Scaffold(
              body: AlertDialog(
                title: Text(esEdicion ? 'Editar usuario' : 'Nuevo usuario'),
                content: SizedBox(
                  width: 440,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: UsuarioFormFields(
                      nombre: controllers[0],
                      correo: controllers[1],
                      direccion: controllers[2],
                      password: controllers[3],
                      esEdicion: esEdicion,
                      guardando: false,
                      tipo: 2,
                      onTipoChanged: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final fields = find.byType(TextField);
        expect(fields, findsNWidgets(esEdicion ? 3 : 4));
        for (var i = 1; i < (esEdicion ? 3 : 4); i++) {
          expect(
            tester.getTopLeft(fields.at(i)).dy -
                tester.getBottomLeft(fields.at(i - 1)).dy,
            greaterThanOrEqualTo(20),
          );
        }
        await tester.ensureVisible(find.byType(DropdownButtonFormField<int>));
        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await tester.pumpAndSettle();
        expect(find.text('Administrador'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        for (final controller in controllers) {
          controller.dispose();
        }
      },
    );
  }
}
