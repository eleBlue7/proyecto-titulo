import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<Product> products = [];
  var text = "Presiona el botón para dictar productos y precios";
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

  Future<void> saveProductsToFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? 'UsuarioDesconocido';

    DocumentReference userDoc = firestore.collection('Usuarios').doc(userName);
    DocumentSnapshot snapshot = await userDoc.get();
    int historialNumero = snapshot.exists && snapshot.data() != null
        ? snapshot['siguientehistorial'] ?? 1
        : 1;

    String customId = "Historial N°$historialNumero de $userName";

    CollectionReference productsCollection = userDoc.collection('Historiales');
    await productsCollection.doc(customId).set({
      'Usuario': userName,
      'Hora de guardado': FieldValue.serverTimestamp(),
      'Total': getTotal(),
      'Productos guardados': products.map((p) => p.toJson()).toList(),
    });

    await userDoc.set(
        {'siguientehistorial': historialNumero + 1}, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Productos guardados en Firebase')),
    );
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
                          List<String> words =
                              result.recognizedWords.split(" ");
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
            onPressed: saveProductsToFirestore,
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
