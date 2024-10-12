// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supcalculadora/welcome.dart';
import 'package:supcalculadora/logins-registros/login_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Configuramos el controlador de la animación
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Definimos una animación curva para suavizar el efecto
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Iniciamos la animación
    _animationController.forward();

    // Crea una instancia de AudioPlayer
    final player = AudioPlayer();

    // Ajusta el volumen del sonido
    player.setVolume(
        1.0); // 1.0 es el volumen máximo, ajusta según tus necesidades.
    //Puedes poner valores intermedios para ajustar, 0.5 sería la mitad del volumen.

    // Reproduce el sonido
    player.play(AssetSource('sounds/splash_sound.mp3'));

    // Navegamos a la siguiente pantalla después de 3 segundos
    Timer(const Duration(seconds: 3), _checkAuthState);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Verifica el estado de autenticación del usuario
  void _checkAuthState() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Welcome()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double logoSize = 400.0;

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Image.asset(
              'assets/logo-v2.png',
              width: logoSize,
              height: logoSize,
            ),
          ),
        ),
      ),
    );
  }
}
