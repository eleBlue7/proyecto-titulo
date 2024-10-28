import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth para obtener el usuario autenticado

class Historial extends StatefulWidget {
  @override
  _HistorialState createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  String? selectedSupermarket;
  String? userName; // Para almacenar el displayName del usuario autenticado

  @override
  void initState() {
    super.initState();
    // Obtener el displayName del usuario autenticado
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userName = user.displayName ?? 'UsuarioDesconocido'; // Guardamos el displayName del usuario
    } else {
      // Manejar el caso en que no haya usuario autenticado
      print("No hay usuario autenticado.");
    }
  }

  // Función para seleccionar un supermercado y mostrar sus historiales
  void selectSupermarket(String supermarket) {
    setState(() {
      selectedSupermarket = supermarket;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Compras'),
        centerTitle: true,
      ),
      body: selectedSupermarket == null
          ? buildSupermarketSelection() // Mostrar selección de supermercados si aún no se seleccionó uno
          : buildHistorialList(selectedSupermarket!), // Mostrar los historiales de un supermercado
    );
  }

  // Construir la pantalla de selección de supermercados
  Widget buildSupermarketSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Seleccione un supermercado para ver los historiales:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: [
            buildSupermarketOption('Líder', 'assets/lider.png'),
            buildSupermarketOption('Jumbo', 'assets/jumbo.png'),
            buildSupermarketOption('Santa Isabel', 'assets/santa_isabel.png'),
            buildSupermarketOption('Unimarc', 'assets/unimarc.png'),
          ],
        ),
      ],
    );
  }

  // Widget para construir las opciones de supermercado
  Widget buildSupermarketOption(String name, String assetPath) {
    return GestureDetector(
      onTap: () => selectSupermarket(name),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedSupermarket == name ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Image.asset(assetPath, width: 100, height: 100), // Imagen del supermercado
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 16)),
          ],
        ),
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  // Construir la lista de historiales de un supermercado seleccionado
  Widget buildHistorialList(String supermarket) {
    if (userName == null) {
      return const Center(child: Text('No se pudo obtener el usuario autenticado.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userName) // Usamos el displayName del usuario autenticado
          .collection(supermarket) // Seleccionamos la colección del supermercado
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay historiales disponibles para este supermercado.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var historial = snapshot.data!.docs[index];
            var total = historial['Total'] ?? 0;
            var hora = historial['Hora de guardado'];

            return Card(
              child: ListTile(
                title: Text('Historial del día: $hora'),
                subtitle: Text('Total: \$${total.toString()}'),
                onTap: () {
                  // Mostrar el modal con el contenido del historial
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return buildHistorialModal(historial);
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // Construir el modal para mostrar los detalles del historial
  // Construir el modal para mostrar los detalles del historial
Widget buildHistorialModal(QueryDocumentSnapshot historial) {
  var productos = historial['Productos guardados'] as List<dynamic>;
  var total = historial['Total'] ?? 0;
  var hora = historial['Hora de guardado'];

  return Container(
    padding: const EdgeInsets.all(16),
    height: 400,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial del día: $hora',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Total: \$${total.toString()}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        const Text(
          'Productos:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              var producto = productos[index];
              return ListTile(
                title: Text(producto['Nombre del producto'] ?? 'Sin nombre'), // Usar el nombre correcto del campo
                trailing: Text('\$${producto['Precio']?.toString() ?? '0'}'), // Usar el nombre correcto del campo
              );
            },
          ),
        ),
      ],
    ),
  );
}

}
