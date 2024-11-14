import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modelo_producto.dart';
import 'package:intl/intl.dart';

// Función para guardar los productos en Firestore con el usuario autenticado
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

    // Referencia al documento del usuario en Firestore
    DocumentReference userDoc = firestore.collection('Usuarios').doc(userName);

    // Verificar si el documento del usuario ya existe; si no, crearlo
    await userDoc.set({
      'nombre': user.displayName ?? 'NombreDesconocido',
      'email': user.email ?? 'CorreoDesconocido',
      'uid': user.uid,
    }, SetOptions(merge: true));

    // Obtener la fecha y hora actual
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    String formattedTime = DateFormat('HH:mm').format(now);

    // Definir el ID personalizado para el historial
    String customId = "Día $formattedDate a las $formattedTime";

    // Agregar supermarket como un atributo de cada producto
    List<Map<String, dynamic>> productosConSupermercado = products.map((product) => {
      'Producto': product.nombre,
      'Precio': product.precio,
    }).toList();

    // Guardar el historial en Firestore
    await userDoc.collection('Historiales').doc(customId).set({
      'Fecha': FieldValue.serverTimestamp(),
      'Productos': productosConSupermercado,
      'Supermercado': supermarket,
      'Total': products.fold(0, (total, product) => total + product.precio),
    });

    print("Historial guardado en Firestore!");
  } catch (e) {
    print("Error al guardar productos en Firestore: $e");
  }
}
