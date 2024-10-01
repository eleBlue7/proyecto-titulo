import 'dart:io'; // Importa para usar File
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supcalculadora/Perfil/change_password.dart';
import 'package:supcalculadora/Perfil/change_profile.dart';
import 'package:supcalculadora/logins-registros/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  User? user;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    // Obtener el usuario actual
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile; // Actualizar la imagen seleccionada
      });
      // Aquí puedes agregar la lógica para subir la imagen a Firebase Storage si es necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del Usuario"),
      ),
      body: user != null
          ? Column(
              children: [
                const SizedBox(height: 20),

                // Marco para la foto de perfil
                Center(
                  child: GestureDetector(
                    onTap: _pickImage, // Permitir selección de imagen al tocar
                    child: CircleAvatar(
                      radius: 60, // Tamaño del círculo
                      backgroundColor: Colors.grey.shade300, // Color del marco
                      child: ClipOval(
                        child: _imageFile != null
                            ? Image.file(
                                File(_imageFile!.path),
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              )
                            : (user!.photoURL != null
                                ? Image.network(
                                    user!.photoURL!,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey, // Color del ícono predeterminado
                                  )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Mostrar los detalles del usuario
                Text(
                  "Bienvenido, ${user!.displayName ?? "Usuario sin nombre"}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Lista de opciones del perfil
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(19),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Cambiar Perfil'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangeProfile(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Cambiar Contraseña'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePassword(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                    ],
                  ),
                ),

                // Botón de Cerrar Sesión
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Has cerrado sesión correctamente"),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                // Texto de agradecimiento
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Gracias por usar nuestra aplicación.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45, // Estilo transparente
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : const Center(child: Text("No se ha iniciado sesión")),
    );
  }
}
