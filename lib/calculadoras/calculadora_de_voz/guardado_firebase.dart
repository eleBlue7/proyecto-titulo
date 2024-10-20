import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modelo_producto.dart';
import 'package:intl/intl.dart';

// Función para guardar los productos en Firestore con el usuario autenticado y el supermercado
Future<void> saveProductsToFirestore(List<Product> products, String supermarket) async {
  try {
    // Obtener el usuario autenticado
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No hay ningún usuario autenticado.");
    }

    // Obtener el nombre de usuario
    String userName = user.displayName ?? 'UsuarioDesconocido';

    // Referencia a la instancia de Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Referencia a la colección del usuario autenticado
    DocumentReference userDoc = firestore.collection('Usuarios').doc(userName);

   // Obtener la fecha y hora actual
    DateTime now = DateTime.now();

    // Formatear la fecha y hora como "día-mes-año" y "hora:minutos"
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    String formattedTime = DateFormat('HH:mm').format(now);

    // Definir el ID personalizado para el historial
    String customId = "Día $formattedDate a las $formattedTime";
    // Crear una nueva colección para el supermercado si no existe y añadir el historial
    CollectionReference productsCollection = userDoc.collection(supermarket);

    // Guardar el historial en Firestore dentro de la colección del supermercado
    await productsCollection.doc(customId).set({
      'Hora de guardado': FieldValue.serverTimestamp(),
      'Total': products.fold(0, (total, product) => total + product.precio),
      'Productos guardados': products.map((p) => p.toJson()).toList(),
    });

    print("Historial guardado en $supermarket!");
  } catch (e) {
    print("Error al guardar productos en Firestore: $e");
  }
}
