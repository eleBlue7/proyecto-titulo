// ignore_for_file: use_build_context_synchronously, unused_local_variable, depend_on_referenced_packages, unused_import, sort_child_properties_last

import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firebase Firestore
import 'package:path_provider/path_provider.dart'; // Para guardar en local
import 'dart:io'; // Para trabajar con archivos
import 'dart:convert'; // Para la conversión a JSON
import 'package:supcalculadora/historial/historial.dart';

void requestPermissions() async {
  await Permission.microphone.request();
}

class Product {
  String nombre;
  int precio;

  Product(this.nombre, this.precio);

  Map<String, dynamic> toJson() => {
        'Nombre del producto': nombre,
        'Precio': precio,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(json['Nombre del producto'], json['Precio']);
  }
}

class CalDeVoz extends StatefulWidget {
  const CalDeVoz({super.key});

  @override
  State<CalDeVoz> createState() => _CalDeVozState();
}

class _CalDeVozState extends State<CalDeVoz> {
  SpeechToText speechToText = SpeechToText();
  List<Product> products = [];  var text = "Presiona el botón para dictar productos y precios";
  var isListening = false;
  bool isSpeechProcessed = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _setFullScreenMode();
  }

  void _setFullScreenMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  int getTotal() {
    return products.isEmpty
        ? 0
        : products.map((p) => p.precio).reduce((a, b) => a + b);
  }

  void stopListeningInternally() {
    setState(() {
      isListening = false;
      isSpeechProcessed = false;
    });
    speechToText.stop();
  }

  String processRecognizedWords(String recognizedWords) {
    return recognizedWords
        .toLowerCase()
        .replaceAll(',', '')
        .replaceAll('por', '*')
        .replaceAll('luca', '1000')
        .replaceAll('lucas', '000')
        .replaceAll('mil', '1000')
        .replaceAll('cero', '0')
        .replaceAll('uno', '1')
        .replaceAll('una', '1')
        .replaceAll('dos', '2')
        .replaceAll('tres', '3')
        .replaceAll('cuatro', '4')
        .replaceAll('cinco', '5')
        .replaceAll('seis', '6')
        .replaceAll('siete', '7')
        .replaceAll('ocho', '8')
        .replaceAll('nueve', '9')
        .replaceAll('diez', '10');
  }

// Función para eliminar productos localmente y mover a la papelera en Firebase
  Future<void> deleteProductLocallyAndMoveToTrash(
      String productId, Map<String, dynamic> productData) async {
    try {
      // Eliminar del almacenamiento local
      await deleteProductFromLocalStorage(productId);

      // Mover el producto eliminado a la papelera en Firebase
      await moveProductToTrashInFirestore(productId, productData);

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Producto eliminado localmente y movido a la papelera en Firebase')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar producto: $e')),
      );
    }
  }

// Función para eliminar del almacenamiento local
  Future<void> deleteProductFromLocalStorage(String productId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/historial.json');

    if (await file.exists()) {
      // Leer el contenido del archivo local
      String contents = await file.readAsString();
      List<dynamic> jsonData = jsonDecode(contents);

      // Eliminar el producto con el productId
      jsonData.removeWhere((product) => product['id'] == productId);

      // Guardar de nuevo el archivo actualizado
      await file.writeAsString(jsonEncode(jsonData));
    }
  }

// Función para mover el producto a la "Papelera" en Firebase
  Future<void> moveProductToTrashInFirestore(
      String productId, Map<String, dynamic> productData) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? 'UsuarioDesconocido';

    // Mover el producto a la colección 'Papelera'
    await firestore
        .collection('Usuarios')
        .doc(userName)
        .collection('Papelera')
        .doc(productId)
        .set(productData);

    // Eliminar el producto del historial original
    await firestore
        .collection('Usuarios')
        .doc(userName)
        .collection('Historiales')
        .doc(productId)
        .delete();
  }

  Future<void> saveProductsLocallyAndFirestore() async {
    try {
      // Primero, guardar los productos en Firebase
      await saveProductsToFirestore();

      // Después, guardar los productos localmente
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/historial.json');

      // Convertir los productos a JSON
      List<Map<String, dynamic>> productList =
          products.map((product) => product.toJson()).toList();
      String jsonProducts = jsonEncode(productList);

      // Guardar el archivo localmente
      await file.writeAsString(jsonProducts);

      // Mostrar solo un mensaje de éxito después de completar ambas funciones
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardado!')),
      );
    } catch (e) {
      // Mostrar un mensaje de error si ocurre algún problema en cualquiera de las operaciones
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  Future<void> saveProductsToFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Obtener el usuario autenticado y su nombre
      User? user = FirebaseAuth.instance.currentUser;
      String userName = user?.displayName ??
          'UsuarioDesconocido'; // Si no hay nombre, usar un valor por defecto
      String userId = user?.uid ??
          'uidDesconocido'; // Obtener el UID del usuario para referencias únicas

      // Referencia al documento del usuario en Firestore
      DocumentReference userDoc = firestore
          .collection('Usuarios')
          .doc(userName); // Usa el nombre del usuario como ID

      // Leer el número de historial actual para este usuario
      DocumentSnapshot snapshot = await userDoc.get();

      int historialNumero =
          1; // Valor por defecto si no existe el contador para el usuario

      if (snapshot.exists && snapshot.data() != null) {
        historialNumero = snapshot['siguientehistorial'] ??
            1; // Lee el último número de historial del usuario
      }

      // Crear el nuevo ID para el historial en la subcolección "Historiales" del usuario
      String customId = "Historial N°$historialNumero de $userName";

      // Guardar el nuevo historial en la subcolección "Historiales" dentro del documento del usuario
      CollectionReference productsCollection =
          userDoc.collection('Historiales'); // Subcolección
      await productsCollection.doc(customId).set({
        'Usuario': userName, // Guardar el nombre del usuario
        'Hora de guardado': FieldValue.serverTimestamp(),
        'Total': getTotal(),
        'Productos guardados':
            products.map((product) => product.toJson()).toList(),
      });

      // Incrementar el número del historial solo para este usuario y actualizar el valor en Firestore
      await userDoc.set({
        'siguientehistorial': historialNumero +
            1, // Incrementar el contador solo para este usuario
      }, SetOptions(merge: true));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar productos en Firebase: $e')),
      );
    }
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        glowColor: const Color(0xFF6D6DFF),
        duration: const Duration(milliseconds: 2000),
        child: GestureDetector(
          onTapDown: (details) async {
            if (!isListening && !isSpeechProcessed) {
              var available = await speechToText.initialize();
              if (available) {
                setState(() {
                  isListening = true;
                  isSpeechProcessed = true;
                  speechToText.listen(
                    onResult: (result) {
                      setState(() {
                        if (result.recognizedWords.isNotEmpty) {
                          List<String> words = result.recognizedWords.split(" ");
                          if (words.length == 2) {
                            String productName =
                                words.sublist(0, words.length - 1).join(" ");
                            String priceWord = words.last;

                            String processedPrice =
                                processRecognizedWords(priceWord);
                            int productPrice =
                                int.tryParse(processedPrice) ?? 0;

                            if (productPrice > 0) {
                              products.add(Product(productName, productPrice));
                            } else {
                              text = "Indique un producto y su precio";
                            }
                          } else {
                            text = "Indique el nombre y precio del producto";
                          }
                          stopListeningInternally();
                        }
                      });
                    },
                  );
                });
              }
            }
          },
          onTapUp: (details) {
            stopListeningInternally();
          },
          child: AnimatedScale(
            scale: isListening ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF6D6DFF),
              radius: 35,
              child: Icon(isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: const Icon(Icons.sort_rounded, color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color(0xFF6D6DFF),
        elevation: 0.0,
        title: const Text(
          "AddUpFast❗🗣️Voz",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveProductsLocallyAndFirestore,
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4B0082),
                    Color.fromARGB(255, 197, 235, 248),
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
                    'Total sumado: ${getTotal().toString()}',
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