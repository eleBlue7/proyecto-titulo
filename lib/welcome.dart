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
        title: Text(
            "Bienvenido a AddUpFast❗$userName"), // Solo se muestra el nombre aquí
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/logo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Elimina o comenta este widget si no quieres mostrar el nombre en el centro
                // Text(
                //   'Bienvenido, $userName', // Removido para evitar redundancia en el centro
                //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                // ),
                // Otros widgets o contenido que desees mantener
              ],
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
            label: 'Calculadoras',
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
