import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeProfile extends StatefulWidget {
  const ChangeProfile({super.key});

  @override
  _ChangeProfileState createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  // Función para cambiar el nombre de usuario
  Future<void> _changeDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(_nameController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre actualizado correctamente')),
        );
        Navigator.pop(context); // Regresar a la pantalla anterior
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar el nombre: $error')),
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
        title: const Text('Cambiar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo para el nuevo nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Nuevo nombre',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Botón para cambiar el nombre
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _changeDisplayName();
                  }
                },
                child: const Text('Cambiar Nombre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
