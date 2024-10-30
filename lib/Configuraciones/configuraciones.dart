// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supcalculadora/Perfil/perfil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supcalculadora/historial/historial.dart';
import 'package:supcalculadora/logins-registros/login_screen.dart';

class Configuraciones extends StatelessWidget {
  const Configuraciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF36bfed), // Color de la marca
        title: const Text(
          "Configuraciones",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                // Sección de cuenta
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    "Cuenta",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF36bfed), // Color de la marca
                    ),
                  ),
                ),
                ListTile(
                  title: const Text("Perfil"),
                  leading: Icon(
                    Icons.account_circle_outlined,
                    color: Color(0xFF36bfed), // Color de la marca
                  ),
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

                // Sección de historial
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    "Historial",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF36bfed), // Color de la marca
                    ),
                  ),
                ),
                ListTile(
                  title: const Text("Mis Compras"),
                  leading: Icon(
                    Icons.shopping_cart_outlined,
                    color: Color(0xFF36bfed), // Icono con color de la marca
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Historial(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text("Otros registros"),
                  leading: Icon(
                    Icons.list_alt,
                    color: Colors.grey, // Color neutro para indicar vacío
                  ),
                  onTap: () {},
                ),
                const Divider(),

                // Sección de otros
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    "Otros",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF36bfed), // Color de la marca
                    ),
                  ),
                ),
                ListTile(
                  title: const Text("Versión 0.17"),
                  leading: const Icon(Icons.update, color: Colors.grey),
                  onTap: () {
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
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  onTap: () async {
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
