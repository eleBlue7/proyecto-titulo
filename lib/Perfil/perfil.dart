import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:supcalculadora/logins-registros/login_screen.dart';

// Asegúrate de importar la pantalla de inicio de sesión

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario actual
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del Usuario"),
      ),
      body: Center(
        child: user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Bienvenido,",
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.displayName ?? "Usuario sin nombre", // Mostrar el nombre o un mensaje si no tiene nombre
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Correo: ${user.email}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      // Cerrar sesión
                      await FirebaseAuth.instance.signOut();

                      // Redirigir a la pantalla de inicio de sesión
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text("Cerrar Sesión"),
                  ),
                ],
              )
            : const Text("No se ha iniciado sesión"),
      ),
    );
  }
}

