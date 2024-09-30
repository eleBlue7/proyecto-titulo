// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supcalculadora/Perfil/perfil.dart';
import 'package:supcalculadora/calculadoras/calculadora_voz.dart';
import 'package:supcalculadora/calculadoras/calculadora_manual.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int _selectedIndex = 0;
  String userName = 'Usuario'; // Nombre por defecto

  @override
  void initState() {
    super.initState();
    _loadUserNameFromFirebase(); // Cargar el nombre del usuario desde Firebase
  }

  // Función para cargar el nombre del usuario desde Firebase
  void _loadUserNameFromFirebase() {
    User? user =
        FirebaseAuth.instance.currentUser; // Obtener el usuario autenticado
    setState(() {
      if (user != null) {
        userName = user.displayName ??
            user.email ??
            'Usuario'; // Mostrar el nombre o correo
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserProfileScreen(),
        ),
      );
    } else if (_selectedIndex == 1) {
      _showCalculatorOptions();
    }
  }

  // Función para mostrar el modal con las opciones
  void _showCalculatorOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalDeVoz(),
                    ),
                  );
                },
                child: const Text('Calculadora de voz'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CalculadoraM(), // La otra calculadora
                    ),
                  );
                },
                child: const Text('Otra Calculadora (CalculadoraM)'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Centramos el título en el AppBar
        title: const Text(
            "Bienvenido a AddUpFast❗"), // El título está centrado en el AppBar
      ),
      body: Stack(
        children: [
          // Fondo de pantalla que se ajusta correctamente
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/logo.png"),
                fit: BoxFit
                    .cover, // Aseguramos que la imagen cubra toda la pantalla sin desplazarse
              ),
            ),
          ),
          // Centrar el nombre del usuario en la parte superior
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 80.0), // Ajuste del espacio desde el AppBar
              child: Text(
                userName, // Mostrar el nombre del usuario
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // Centrar el texto
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculadora',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
