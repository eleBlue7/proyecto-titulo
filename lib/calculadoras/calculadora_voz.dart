// ignore_for_file: use_build_context_synchronously, unused_local_variable, depend_on_referenced_packages, unused_import

import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firebase Firestore
import 'package:path_provider/path_provider.dart'; // Para guardar en local
import 'dart:io'; // Para trabajar con archivos
import 'dart:convert'; // Para la conversión a JSON
import 'package:supcalculadora/historial /historial.dart';

void requestPermissions() async {
  var status = await Permission.microphone.request();
  if (status == PermissionStatus.granted) {
    // Micrófono permitido
  } else {
    // Micrófono denegado
  }
}

class Product {
  String nombre;
  int precio;

  Product(this.nombre, this.precio);

  // Para guardar en Firebase Firestore
  Map<String, dynamic> toJson() => {
        'Nombre del producto': nombre,
        'Precio': precio,
      };

  // Para recuperar desde Firebase Firestore
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

  List<Product> products = []; // Lista de productos
  var text = "Apreta el botón para comenzar a decir los precios!";
  var isListening = false;
  bool isSpeechProcessed = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  int getTotal() {
    if (products.isEmpty) {
      return 0; // Si la lista está vacía, devuelve 0
    } else {
      return products.map((product) => product.precio).reduce((a, b) => a + b);
    }
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
        .replaceAll('diez', '10')
        .replaceAll('once', '11')
        .replaceAll('doce', '12')
        .replaceAll('trece', '13')
        .replaceAll('catorce', '14')
        .replaceAll('quince', '15')
        .replaceAll('coma', '.')
        .replaceAll('punto', '.');
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
          duration: const Duration(milliseconds: 1000),
          glowColor: Colors.blue,
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
                            String recognizedWords =
                                result.recognizedWords.toLowerCase();

                            // Dividir las palabras reconocidas en una lista
                            List<String> words = recognizedWords.split(" ");

                            if (words.length == 2) {
                              // Asegúrate de tener al menos un nombre y un precio
                              String productName = words
                                  .sublist(0, words.length - 1)
                                  .join(
                                      " "); // El nombre son todas las palabras excepto la última
                              String priceWord =
                                  words.last; // La última palabra es el precio

                              // Procesar las palabras y convertirlas a números
                              String processedPrice =
                                  processRecognizedWords(priceWord);

                              int productPrice = 0;
                              try {
                                productPrice = int.parse(processedPrice);
                              } catch (e) {
                                text =
                                    "Por favor, diga un producto y su precio válido.";
                              }

                              if (productPrice > 0) {
                                products.add(Product(productName,
                                    productPrice)); // Usa el nombre y el precio reconocidos
                              } else {
                                text =
                                    "Por favor, diga un producto y su precio válido.";
                              }
                            } else {
                              text =
                                  "Por favor, diga el nombre del producto y el precio.";
                            }

                            // Detener la escucha automáticamente después de procesar
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
            child: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 104, 166, 218),
              radius: 35,
              child: Icon(isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white),
            ),
          ),
        ),
        appBar: AppBar(
          leading: const Icon(Icons.sort_rounded, color: Colors.white),
          centerTitle: true,
          backgroundColor: Colors.blue,
          elevation: 0.0,
          title: const Text(
            "Calculadora Voz",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed:
                  saveProductsLocallyAndFirestore, // Llama a la nueva función que guarda en Firebase y localmente
            )
          ],
        ),
        body: SingleChildScrollView(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: const EdgeInsets.only(bottom: 150),
            child: Column(
              children: [
                Text(
                  text,
                  style: TextStyle(
                      fontSize: 24,
                      color: isListening ? Colors.black54 : Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  'Total: ${getTotal().toString()}',
                  style: TextStyle(
                    fontSize: 24,
                    color: isListening ? Colors.black54 : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(products[index].nombre),
                            Text(products[index].precio.toString()),
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
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
