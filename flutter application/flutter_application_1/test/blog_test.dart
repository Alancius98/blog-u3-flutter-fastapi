import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/services/api_client.dart';

void main() {
  tearDown(ApiClient.limpiar);

  testWidgets('El registro público no muestra selector de administrador', (tester) async {
    await tester.pumpWidget(const LoginApp());
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Registrarse'));
    await tester.tap(find.text('Registrarse'));
    await tester.pumpAndSettle();
    expect(find.text('CREAR CUENTA'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<int>), findsNothing);
  });

  testWidgets('La sesión conserva usuario y rol sin persistir el token', (tester) async {
    ApiClient.iniciar({'access_token': 'token-prueba', 'usuario': {'id_usr': 1, 'nom_usr': 'Administrador', 'tip_usu': 1}});
    expect(ApiClient.autenticado, isTrue);
    expect(ApiClient.esAdmin, isTrue);
    ApiClient.limpiar();
    expect(ApiClient.autenticado, isFalse);
    expect(ApiClient.usuario, isNull);
  });

  testWidgets('El login se adapta a 390 px sin desbordamientos', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const LoginApp());
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('INGRESAR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('La portada permite crear cuenta a 390 px', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const LoginApp());
    await tester.pumpAndSettle();
    final crear = find.text('Crear mi cuenta');
    await tester.ensureVisible(crear);
    await tester.tap(crear);
    await tester.pumpAndSettle();
    expect(find.text('CREAR CUENTA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('La portada admite texto ampliado sin cortarlo', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const LoginApp());
    await tester.pumpAndSettle();
    expect(find.text('Comparte lo que\nte inspira.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
