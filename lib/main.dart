// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supcalculadora/calculadoras/calculadora_voz.dart';
import 'package:supcalculadora/logins-registros/login_screen.dart';
import 'firebase/firebase_options.dart';
import 'package:supcalculadora/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      home: ChequeoAutentificacion(), // Usa ChequeoAutentuficacion para verificar el estado de autenticación

     

    );
  }
}

class ChequeoAutentificacion extends StatelessWidget {
  const ChequeoAutentificacion({super.key});

  @override
  Widget build(BuildContext context) {
    // Verificar si el usuario ya está autenticado
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Si hay un usuario autenticado, redirigir al menú principal
      return const Welcome();  // Cambia esto por tu pantalla de menú principal
    } else {
      // Si no hay usuario autenticado, redirigir a la pantalla de login
      return const LoginScreen();
    }
  }
}
