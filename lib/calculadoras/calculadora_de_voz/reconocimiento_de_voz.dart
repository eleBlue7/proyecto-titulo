import 'package:speech_to_text/speech_to_text.dart';
import 'modelo_producto.dart'; // Importa el modelo de producto

SpeechToText speechToText = SpeechToText();

// Variable para almacenar el supermercado seleccionado, pásala desde tu lógica principal
String selectedSupermarket = "Lider"; // Cambia esto por el supermercado seleccionado en tu app

// Función para comenzar a escuchar
Future<void> startListening(Function(Product?) onProductRecognized) async {
  bool available = await speechToText.initialize();
  if (available) {
    // Escuchar continuamente
    speechToText.listen(onResult: (result) {
      if (result.recognizedWords.isNotEmpty) {
        List<String> words = result.recognizedWords.split(" ");
        if (words.length == 2) {
          String productName = words[0];
          String processedPrice = processRecognizedWords(words[1]);
          int productPrice = int.tryParse(processedPrice) ?? 0;

          if (productPrice > 0) {
            // Llamamos a la función de callback con el producto reconocido, incluyendo el supermercado
            onProductRecognized(Product(productName, productPrice, selectedSupermarket));
            stopListening(); // Detener la escucha una vez que se reconoce un producto válido
          } else {
            // No se reconoció un producto válido
            onProductRecognized(null);
          }
        } else {
          // No se reconoció correctamente un nombre y un precio
          onProductRecognized(null);
        }
      }
    });
  }
}

// Función para detener la escucha
void stopListening() {
  speechToText.stop();
}

// Procesar las palabras reconocidas
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
