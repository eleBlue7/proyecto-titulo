// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supcalculadora/logins-registros/login_screen.dart';
import 'package:supcalculadora/screens/splash_screen.dart'; // Asegúrate de usar la pantalla de carga
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
      // Cambiar a SplashScreen como primera pantalla
      home: SplashScreen(), // Primero muestra la pantalla de carga
    );
  }
}

// Chequeo de autenticación después de la pantalla de carga
class ChequeoAutentificacion extends StatelessWidget {
  const ChequeoAutentificacion({super.key});

  @override
  Widget build(BuildContext context) {
    // Verificar si el usuario ya está autenticado
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Si hay un usuario autenticado, redirigir al menú principal
      return const Welcome(); // Cambia esto por tu pantalla de menú principal
    } else {
      // Si no hay usuario autenticado, redirigir a la pantalla de login
      return const LoginScreen();
    }
  }
}
