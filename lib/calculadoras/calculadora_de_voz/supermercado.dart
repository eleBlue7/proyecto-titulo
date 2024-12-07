import 'package:flutter/material.dart';
import 'package:supcalculadora/calculadoras/calculadora_de_voz/main_calculadora.dart'; // Asegúrate de tener esta pantalla

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
      // Eliminamos el AppBar predeterminado y lo personalizamos
      appBar: AppBar(
        backgroundColor: const Color(0xFF36bfed),
        elevation: 0, // Quita la sombra debajo del AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              size: 30.0, //tamaño el icono flecha
              color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: true, // Muestra el botón de retroceso
        title: const Text(
          '¿A qué supermercado vas a ir?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true, // Alinea el título a la izquierda
      ),
      body: Container(
        // Asegura que el Container ocupe toda la pantalla
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF36bfed), // Picton Blue
              Color(0xFFFFFFFF), // Blanco
            ],
            begin: Alignment.topCenter, // De arriba hacia abajo
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.all(16.0), // Espaciado para evitar recortes
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Eliminamos el Text duplicado del título
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
                            // Redirigir a la calculadora de voz pasando el supermercado seleccionado
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CalDeVoz(supermarket: selectedSupermarket!),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 0, 221, 255), // Color del botón OK
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ), // Deshabilitar si no se ha seleccionado un supermercado
                    child: const Icon(
                      Icons.check,
                      size: 30,
                      color: Color.fromARGB(255, 255, 255, 255),
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

  // Widget para mostrar cada supermercado con una imagen
  Widget buildSupermarketOption(String name, String assetPath) {
    double width =
        MediaQuery.of(context).size.width * 0.4; // Responsivo al ancho

    return GestureDetector(
      onTap: () => selectSupermarket(name),
      child: Container(
        width: width, // Ajusta el ancho basado en el tamaño de la pantalla
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco para los contenedores
          border: Border.all(
            color: selectedSupermarket == name
                ? const Color.fromARGB(255, 0, 238, 255)
                : const Color.fromARGB(255, 105, 105, 105),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10), // Bordes redondeados
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.asset(
              assetPath,
              width: 80, // Tamaño responsivo para imágenes
              height: 80,
              fit: BoxFit.contain,
            ), // Imagen del supermercado
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
