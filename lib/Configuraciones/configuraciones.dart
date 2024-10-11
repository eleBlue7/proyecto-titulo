// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supcalculadora/Perfil/perfil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supcalculadora/historial%20/historial.dart';
import 'package:supcalculadora/logins-registros/login_screen.dart';

class Configuraciones extends StatelessWidget {
  const Configuraciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuraciones"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                const ListTile(
                  title: Text("Cuenta"),
                ),
                ListTile(
                  title: const Text("Perfil"),
                  leading: const Icon(Icons.account_circle_outlined),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                const ListTile(
                  title: Text("Historial"),
                ),
                ListTile(
                  title: const Text("Historiales"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistorialScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text("vacio"),
                  onTap: () {},
                ),
                const Divider(),
                const ListTile(
                  title: Text("Otros"),
                ),
                ListTile(
                  title: const Text("Versión 0.17"),
                  leading: const Icon(Icons.update),
                  onTap: () {
                    // Mostrar AlertDialog con la versión
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Versión de AddUpFast!"),
                          content: const Text("Versión 0.17"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(
                      color: Colors.red, // Cambia el texto a color rojo
                    ),
                  ),
                  onTap: () async {
                    // Mostrar diálogo de confirmación antes de cerrar sesión
                    bool? confirmSignOut = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Cerrar sesión"),
                          content: const Text(
                              "¿Estás seguro de que deseas cerrar sesión?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // Cancelar
                              },
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // Confirmar
                              },
                              child: const Text("Sí"),
                            ),
                          ],
                        );
                      },
                    );

                    // Si el usuario confirmó, cerrar sesión
                    if (confirmSignOut == true) {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
