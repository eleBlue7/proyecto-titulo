import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supcalculadora/logins-registros/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _email = "";
  String _password = "";
  String _name = "";

  bool _isPasswordVisible = false; // Controla si la contraseña es visible

  Future<void> _checkAndSignUp() async {
    try {
      // Verificar si el nombre de usuario ya está en uso
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Usuarios') // Cambié de 'users' a 'usuarios'
          .where('nombre', isEqualTo: _name) // Cambié 'username' por 'nombre'
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Si el nombre ya está en uso, mostrar una alerta
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Nombre de usuario no disponible"),
              content: const Text(
                  "El nombre de usuario ingresado ya está en uso. Por favor, elige otro."),
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
        return; // Detener el flujo aquí si el nombre ya está en uso
      }

      // Si el nombre no está en uso, proceder con el registro
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // Guardar información adicional en Firestore en la colección 'usuarios'
      await _firestore.collection('Usuarios').doc(_name).set({
        'nombre': _name, // Guardar el nombre de usuario
        'email': _email,
        'uid': userCredential.user!.uid, // Guardar UID del usuario
      });

      // Actualizar nombre del usuario en Firebase Authentication
      await userCredential.user!.updateDisplayName(_name);

      // Mostrar éxito y redirigir al inicio de sesión
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("¡Registro exitoso!"),
            content: const Text("Bienvenido a AddUpFast!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al registrarse: ${e.toString()}"),
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
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4B0082),
                Color.fromARGB(255, 197, 235, 248),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const Text(
                  "Regístrate",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
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
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Color(0xFF4B0082),),
                              border: OutlineInputBorder(),
                              labelText: "Email",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingrese su email";
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
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person, color: Color(0xFF4B0082),),
                              border: OutlineInputBorder(),
                              labelText: "Nombre de Usuario",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingrese su nombre de usuario";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _name = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passController,
                            obscureText: !_isPasswordVisible, // Controla si el texto es visible
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock, color: Color(0xFF4B0082),),
                              border: const OutlineInputBorder(),
                              labelText: "Contraseña",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                      color: Color(0xFF4B0082),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingrese su contraseña";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _password = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                _checkAndSignUp();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4B0082),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 32.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: const Text(
                              "Registrarse",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "¿Ya tienes una cuenta? Inicia sesión",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
