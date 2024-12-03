import 'package:speech_to_text/speech_to_text.dart';
import 'modelo_producto.dart';

SpeechToText speechToText = SpeechToText();

// Variable para almacenar el supermercado seleccionado
String selectedSupermarket = "Lider"; // Cambia esto por el supermercado seleccionado

// Función para comenzar a escuchar
Future<void> startListening(Function(Product?) onProductRecognized) async {
  bool available = await speechToText.initialize();
  if (available) {
    // Escuchar continuamente
    speechToText.listen(onResult: (result) {
      if (result.recognizedWords.isNotEmpty) {
        // Eliminar tildes de las palabras reconocidas
        String recognizedText = result.recognizedWords;
        recognizedText = removeAccents(recognizedText);  // Eliminar tildes

        // Procesamos el texto reconocido
        List<String> words = recognizedText.split(" ");

        // Buscamos el precio, que debe ser el último elemento
        String processedPrice = processRecognizedWords(words.last);
        int productPrice = int.tryParse(processedPrice) ?? 0;

        // Si encontramos un precio válido
        if (productPrice > 0 && words.length > 1) {
          // El nombre del producto es todo lo demás, excepto el último elemento (que es el precio)
          String productName = words.sublist(0, words.length - 1).join(" ");

          // Llamamos a la función de callback con el producto reconocido
          onProductRecognized(Product(productName, productPrice, selectedSupermarket));
          stopListening(); // Detener la escucha una vez que se reconoce un producto válido
        } else {
          // No se reconoció un producto válido
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

// Función para eliminar tildes
String removeAccents(String text) {
  return text
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U');
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
