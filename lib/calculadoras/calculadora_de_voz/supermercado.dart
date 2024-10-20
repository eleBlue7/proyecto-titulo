import 'package:flutter/material.dart';
import 'main_calculadora.dart'; // Asegúrate de tener esta pantalla

class SupermarketSelection extends StatefulWidget {
  const SupermarketSelection({super.key});

  @override
  _SupermarketSelectionState createState() => _SupermarketSelectionState();
}

class _SupermarketSelectionState extends State<SupermarketSelection> {
  String? selectedSupermarket; // Almacena el supermercado seleccionado

  // Función para seleccionar un supermercado
  void selectSupermarket(String supermarket) {
    setState(() {
      selectedSupermarket = supermarket;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Supermercado'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿A qué supermercado vas a ir?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              buildSupermarketOption('Jumbo', 'assets/jumbo.png'),
              buildSupermarketOption('Líder', 'assets/lider.png'),
              buildSupermarketOption('Santa Isabel', 'assets/santa_isabel.png'),
              buildSupermarketOption('Unimarc', 'assets/unimarc.png'),
              buildSupermarketOption('Goku', 'assets/goku.png'),
              buildSupermarketOption('Perro', 'assets/perro.png'),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: selectedSupermarket != null
                ? () {
                    // Redirigir a la calculadora de voz pasando el supermercado seleccionado
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalDeVoz(supermarket: selectedSupermarket!),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Color del botón OK
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ), // Deshabilitar si no se ha seleccionado un supermercado
            child: const Icon(Icons.check, size: 30),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar cada supermercado con una imagen
  Widget buildSupermarketOption(String name, String assetPath) {
    return GestureDetector(
      onTap: () => selectSupermarket(name),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedSupermarket == name ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.asset(assetPath, width: 100, height: 100), // Imagen del supermercado
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
