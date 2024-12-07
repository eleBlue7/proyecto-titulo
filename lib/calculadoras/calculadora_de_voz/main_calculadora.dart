import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'reconocimiento_de_voz.dart';
import 'modelo_producto.dart';
import 'guardado_firebase.dart';

class CalDeVoz extends StatefulWidget {
  final String supermarket; // Añadimos el supermercado como parámetro

  const CalDeVoz({super.key, required this.supermarket});

  @override
  State<CalDeVoz> createState() => _CalDeVozState();
}

class _CalDeVozState extends State<CalDeVoz> {
  List<Product> products = [];
  var text = "Presiona el botón para dictar productos y precios";
  bool isListening = false;

  // Función para capitalizar la primera letra de una cadena
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text; // Si el texto está vacío, lo devuelve sin cambios
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        glowColor: const Color(0xFF36BFED),
        duration: const Duration(milliseconds: 2000),
        child: GestureDetector(
          onTapDown: (details) async {
            if (!isListening) {
              setState(() {
                isListening = true; // Activamos la animación de escucha
              });

              // Inicia la escucha y reconoce productos
              await startListening((product) {
                if (product != null) {
                  setState(() {
                    // Capitaliza la primera letra del nombre del producto
                    product.nombre = capitalizeFirstLetter(product.nombre);
                    products.add(product);
                    text = "Producto ingresado!";
                  });
                } else {
                  setState(() {
                    text =
                        "No se reconoció un producto válido. Intente nuevamente.";
                  });
                }
              });
            }
          },
          onTapUp: (details) {
            // Opción para detener la escucha si el usuario suelta el botón
            setState(() {
              isListening = false;
            });
            stopListening();
          },
          child: CircleAvatar(
            backgroundColor: const Color(0xFF36BFED),
            radius: 35,
            child: Icon(isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF36BFED),
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              size: 30.0, //tamaño el icono flecha
              color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Calculadora Voz",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 30.0, //tamaño del icono disket
            ),
            onPressed: () {
              if (products.isNotEmpty) {
                saveProductsToFirestore(products,
                    widget.supermarket); // Pasamos el supermercado al guardar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Historial guardado!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('No hay productos para guardar')),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF36BFED), // Picton Blue
                    Color.fromARGB(255, 250, 250,
                        250), // Indigo para un efecto de contraste
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/logo-v2.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: isListening ? Colors.white70 : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total sumado: \$${products.fold(0, (total, product) => total + product.precio)}',
                    style: TextStyle(
                      fontSize: 24,
                      color: isListening ? Colors.white70 : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(products[index].nombre),
                                Text('\$${products[index].precio.toString()}'),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      products.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
