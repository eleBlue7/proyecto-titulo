// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:supcalculadora/Perfil/perfil.dart';
import 'package:supcalculadora/calculadora/calculadoraDeVoz.dart';
// Asegúrate de importar la pantalla del perfil


class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  _WelcomeState createState() => _WelcomeState();
}

 class _WelcomeState extends State<Welcome> {
  int _selectedIndex = 0;

 void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  // Lógica de navegación fuera de setState
  if (_selectedIndex == 0) {
    // Navegar a UserProfileScreen si se selecciona el índice 0 (Perfil)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserProfileScreen(),
      ),
    );
  } else if (_selectedIndex == 1) {
    // Navegar a CalDeVoz si se selecciona el índice 1 (Calculadoras)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalDeVoz(),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienvenido..."),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/logo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        ),
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