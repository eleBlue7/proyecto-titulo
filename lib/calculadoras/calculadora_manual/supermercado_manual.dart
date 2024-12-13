import 'package:flutter/material.dart';
import 'package:supcalculadora/calculadoras/calculadora_manual/calculadora_manual.dart';

class SupermarketSelectionManual extends StatefulWidget {
  const SupermarketSelectionManual({super.key});

  @override
  _SupermarketSelectionManualState createState() =>
      _SupermarketSelectionManualState();
}

class _SupermarketSelectionManualState
    extends State<SupermarketSelectionManual> {
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
        backgroundColor: const Color(0xFF36bfed),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: true,
        title: const Text(
          '¿A qué supermercado vas a ir?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF36bfed), // Picton Blue
              Color(0xFFFFFFFF), // Blanco
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    buildSupermarketOption('Jumbo', 'assets/jumbo.png'),
                    buildSupermarketOption('Lider', 'assets/lider.png'),
                    buildSupermarketOption(
                        'Santa Isabel', 'assets/santa_isabel.png'),
                    buildSupermarketOption('Unimarc', 'assets/unimarc.png'),
                    buildSupermarketOption('Tottus', 'assets/tottus.png'),
                    buildSupermarketOption('Acuenta', 'assets/acuenta.png'),
                    buildSupermarketOption('Otros', 'assets/designer.png'),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: selectedSupermarket != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CalculadoraM(
                                    supermarket: selectedSupermarket!),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 0, 221, 255), // Color del botón OK
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 30,
                      color: Colors.white,
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

  Widget buildSupermarketOption(String name, String assetPath) {
    double width =
        MediaQuery.of(context).size.width * 0.4; // Responsivo al ancho

    return GestureDetector(
      onTap: () => selectSupermarket(name),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selectedSupermarket == name
                ? const Color.fromARGB(255, 0, 255, 34)
                : const Color.fromARGB(255, 105, 105, 105),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.asset(
              assetPath,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
