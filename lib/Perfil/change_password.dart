import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureTextPassword = true; // Controla visibilidad de la nueva contraseña
  bool _obscureTextConfirmPassword = true; // Controla visibilidad de la confirmación de contraseña

  // Función para cambiar la contraseña
  Future<void> _changePassword() async {
    // Obtener el usuario actual
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(_passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada correctamente')),
        );
        Navigator.pop(context); // Regresar a la pantalla anterior
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar la contraseña: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha iniciado sesión')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo para la nueva contraseña
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextPassword = !_obscureTextPassword;
                      });
                    },
                  ),
                  labelText: 'Nueva contraseña',
                ),
                obscureText: _obscureTextPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una nueva contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo para confirmar la nueva contraseña
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureTextConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
                      });
                    },
                  ),
                  labelText: 'Confirmar contraseña',
                ),
                obscureText: _obscureTextConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Botón para cambiar la contraseña
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _changePassword();
                  }
                },
                child: const Text('Cambiar Contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
