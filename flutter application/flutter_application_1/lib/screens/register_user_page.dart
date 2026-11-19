import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/api_client.dart';
import '../widgets/blog_theme.dart';
import '../widgets/tipo_usuario_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();

  final TextEditingController correoController = TextEditingController();

  final TextEditingController direccionController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final UserService userService = UserService();

  bool cargando = false;

  // Si la pantalla se abre desde el menú de un administrador,
  // recibe sus datos como argumento y se muestra el selector de
  // tipo. Desde el login (registro público) no hay argumento y
  // siempre se crea un usuario general.
  Map<String, dynamic> _admin = {};
  bool _esAdmin = false;
  bool _argumentoLeido = false;

  // 1 = administrador, 2 = general
  int _tipoSeleccionado = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argumentoLeido) return;

    final argumento = ModalRoute.of(context)?.settings.arguments;

    if (argumento is Map<String, dynamic>) {
      final tipo = argumento['tip_usu'];

      if (ApiClient.esAdmin && tipo is num && tipo.toInt() == 1) {
        _admin = Map<String, dynamic>.from(argumento);
        _esAdmin = true;
      }
    }

    _argumentoLeido = true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    direccionController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // Envía el registro al backend (POST /usuarios) con los
  // mismos campos que tiene la tabla usuario.
  Future<void> registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      cargando = true;
    });

    try {
      await userService.agregarUsuario(
        UserModel(
          id: 0,
          nombre: nombreController.text.trim(),
          correo: correoController.text.trim().toLowerCase(),
          password: passwordController.text,
          direccion: direccionController.text.trim(),
          tipoUsuario: _esAdmin ? _tipoSeleccionado : 2,
        ),
      );

      if (!mounted) return;

      if (_esAdmin) {
        // El administrador se queda en la pantalla para poder
        // registrar a más usuarios.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tipoSeleccionado == 1
                  ? 'Administrador registrado correctamente'
                  : 'Usuario registrado correctamente',
            ),
          ),
        );

        limpiarFormulario();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada. Ya puedes iniciar sesión'),
          ),
        );

        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void limpiarFormulario() {
    _formKey.currentState!.reset();

    nombreController.clear();
    correoController.clear();
    direccionController.clear();
    passwordController.clear();

    setState(() {
      _tipoSeleccionado = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _esAdmin ? AppBar(title: const Text('Registrar usuario')) : null,

      drawer: _esAdmin
          ? AdminDrawer(usuario: _admin, rutaActual: '/register')
          : null,

      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: AuthCard(
              child: Form(
                key: _formKey,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const BlogBrand(),

                    const SizedBox(height: 15),

                    Text(
                      _esAdmin ? 'REGISTRAR USUARIO' : 'CREAR CUENTA',

                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: blogInk,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Un lugar para tus ideas y conversaciones.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: blogMuted, height: 1.5),
                    ),

                    const SizedBox(height: 25),

                    // NOMBRE
                    CustomTextField(
                      controller: nombreController,

                      label: 'Nombre completo',

                      prefixIcon: Icons.person,

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }

                        return null;
                      },

                      keyboardType: TextInputType.name,
                    ),

                    const SizedBox(height: 15),

                    // CORREO
                    CustomTextField(
                      controller: correoController,

                      label: 'Correo electrónico',

                      prefixIcon: Icons.email,

                      keyboardType: TextInputType.emailAddress,

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu correo';
                        }

                        if (!value.contains('@')) {
                          return 'Ingresa un correo válido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // DIRECCION
                    CustomTextField(
                      controller: direccionController,

                      label: 'Dirección',

                      prefixIcon: Icons.home,

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu dirección';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // CONTRASEÑA
                    CustomTextField(
                      controller: passwordController,

                      label: 'Contraseña',

                      prefixIcon: Icons.lock,

                      obscureText: true,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una contraseña';
                        }

                        if (value.length < 8) {
                          return 'La contraseña debe tener al menos 8 caracteres';
                        }

                        return null;
                      },
                    ),

                    // TIPO DE USUARIO (solo lo ve un administrador)
                    if (_esAdmin) ...[
                      const SizedBox(height: 15),

                      TipoUsuarioField(
                        key: ValueKey('tipo-$_tipoSeleccionado'),
                        tipo: _tipoSeleccionado,
                        enabled: !cargando,
                        onChanged: (valor) {
                          setState(() {
                            _tipoSeleccionado = valor;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 25),

                    // REGISTRAR
                    PrimaryButton(
                      text: cargando ? 'REGISTRANDO...' : 'REGISTRARME',

                      onPressed: cargando ? () {} : registrarUsuario,
                    ),

                    const SizedBox(height: 10),

                    // LIMPIAR
                    TextButton(
                      onPressed: limpiarFormulario,

                      child: const Text('Limpiar formulario'),
                    ),

                    const SizedBox(height: 5),

                    // REGRESAR (solo en el registro público)
                    if (!_esAdmin)
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },

                        child: const Text('Ya tengo una cuenta'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
