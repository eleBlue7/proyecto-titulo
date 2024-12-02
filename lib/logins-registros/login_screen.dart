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
    final size = MediaQuery.of(context).size; // Tamaño de la pantalla
    final double screenHeight = size.height;
    final double screenWidth = size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AddUpFast!',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF36bfed), // Nuevo color primario
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF36bfed), // Celeste Picton Blue
              Color.fromARGB(255, 197, 235, 248), // Azul claro
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, // 5% del ancho de la pantalla
                  vertical: screenHeight * 0.02, // 2% del alto de la pantalla
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.02), // Espaciado dinámico
                    Image.asset(
                      'assets/logo-v2.png',
                      height: screenHeight * 0.15, // 15% de la altura
                      width: screenHeight * 0.15, // Proporcional al alto
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: screenHeight * 0.02), // Espaciado dinámico
                    const Text(
                      "Inicio de Sesión",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // Espaciado dinámico
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6.0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(
                          screenWidth * 0.05), // Padding dinámico
                      child: Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                prefixIcon:
                                    Icon(Icons.email, color: Color(0xFF36bfed)),
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
                            SizedBox(height: screenHeight * 0.02),
                            TextFormField(
                              controller: _passController,
                              obscureText: _obscureText,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.password,
                                    color: Color(0xFF36bfed)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF36bfed),
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
                            SizedBox(height: screenHeight * 0.015),
                            ElevatedButton(
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  _handleLogin();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF36bfed),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.02,
                                  horizontal: screenWidth * 0.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: const Text(
                                "Iniciar Sesión",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              child: const Text(
                "Desarrollado con 💙 por Smart💡Solutions",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
