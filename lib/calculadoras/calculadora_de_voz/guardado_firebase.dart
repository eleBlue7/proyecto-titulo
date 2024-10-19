import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modelo_producto.dart';

// Función para guardar los productos en Firestore con el usuario autenticado
Future<void> saveProductsToFirestore(List<Product> products) async {
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

    // Verificar el número del siguiente historial
    DocumentSnapshot snapshot = await userDoc.get();
    int historialNumero = snapshot.exists && snapshot.data() != null
        ? snapshot['siguientehistorial'] ?? 1
        : 1;

    // Definir el ID personalizado para el historial
    String customId = "Historial N°$historialNumero de $userName";

    // Crear un nuevo historial con los productos actuales
    CollectionReference productsCollection = userDoc.collection('Historiales');

    // Guardar el historial en Firestore
    await productsCollection.doc(customId).set({

      'Hora de guardado': FieldValue.serverTimestamp(),
      'Total': products.fold(0, (total, product) => total + product.precio),
      'Productos guardados': products.map((p) => p.toJson()).toList(),
    });

    // Actualizar el siguiente número de historial
    await userDoc.set({
      'siguientehistorial': historialNumero + 1
    }, SetOptions(merge: true));

    print("Historial guardado!");
  } catch (e) {
    print("Error al guardar productos en Firestore: $e");
  }
}
