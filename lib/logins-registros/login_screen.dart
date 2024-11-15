// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supcalculadora/welcome.dart';
import 'package:supcalculadora/logins-registros/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _obscureText = true; // Variable donde escondemos la contraseña
  String _email = "";
  String _password = "";
  String _errorMessage = ""; // Variable para el mensaje de error

  void _handleLogin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Welcome(),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage =
            "Error: No se pudo iniciar sesión. Verifica tu correo y contraseña.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AddUpFast!',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6D6DFF),
        centerTitle: true,
      ),
      body: SizedBox.expand(
        // Asegura que el gradiente abarque toda la pantalla
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4B0082), // Morado oscuro en la parte superior
                Color.fromARGB(255, 197, 235, 248), // Azul claro en la parte inferior
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth * 0.7,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Espacio entre el AppBar y el título
                      const SizedBox(height: 80),
                      // Título Login
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          "Inicio Sesión",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Card con fondo sólido (sin gradiente)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Fondo blanco para el Card
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6.0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              children: [
                                // Campo de email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.email, color: Color(0xFF4B0082)),
                                    border: OutlineInputBorder(),
                                    labelText: "Email",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Por favor, ingrese su email correctamente";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _email = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Campo de contraseña
                                TextFormField(
                                  controller: _passController,
                                  obscureText: _obscureText,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.password,color: Color(0xFF4B0082)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                            color: Color(0xFF4B0082),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                    border: const OutlineInputBorder(),
                                    labelText: "Contraseña",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Por favor, ingrese su contraseña correctamente";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _password = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 15),
                                // Botón de iniciar sesión
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formkey.currentState!.validate()) {
                                      _handleLogin();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF4B0082), // Morado oscuro
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                      horizontal: 32.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  child: const Text(
                                    "Iniciar Sesión",
                                    style: TextStyle(
                                      color: Colors.white, // Texto blanco
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Enlace de registro
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                      "¿No tienes una cuenta? ¡Regístrate!"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
