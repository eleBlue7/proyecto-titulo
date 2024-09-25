import 'package:flutter/material.dart';
import 'package:supcalculadora/calculadoras/calculadora_manual.dart';
import 'package:supcalculadora/calculadoras/calculadoraDeVoz.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 1) {
      // Muestra el modal solo cuando se selecciona la opción de "Settings"
      _showModal();
    }
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'Calculadora':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CalculadoraM(),
          ),
        );
        break;
      case 'CalVoz':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CalDeVoz(),
          ),
        );
        break;
      // Agrega más casos según sea necesario
    }
  }

  void _showModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _onMenuItemSelected(""),
                child: const Text('Calculadora Camara'),
              ),
              ElevatedButton(
                onPressed: () => _onMenuItemSelected('Calculadora'),
                child: const Text('Calculadora Manual'),
              ),
              ElevatedButton(
                onPressed: () => _onMenuItemSelected('CalVoz'),
                child: const Text('Calculadora de voz'),
              ),
              // Agrega más opciones según sea necesario
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
        title: const Text("Bienvenido..."),
      ),
      body: Container(
        
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/logo.png"), // Reemplaza con la ruta de tu imagen
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
            label: 'Calculadoras',
          ),
          // Cambiado a un IconButton en lugar de BottomNavigationBarItem
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
