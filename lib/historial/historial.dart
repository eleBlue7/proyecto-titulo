import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share/share.dart';

class Historial extends StatefulWidget {
  @override
  _HistorialState createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  String? selectedSupermarket;
  String? userName;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userName = user.displayName ?? 'UsuarioDesconocido';
    } else {
      print("No hay usuario autenticado.");
    }
  }

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
          ? buildSupermarketSelection()
          : buildHistorialList(selectedSupermarket!),
    );
  }

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
            buildSupermarketOption('Lider', 'assets/lider.png'),
            buildSupermarketOption('Jumbo', 'assets/jumbo.png'),
            buildSupermarketOption('Santa Isabel', 'assets/santa_isabel.png'),
            buildSupermarketOption('Unimarc', 'assets/unimarc.png'),
            buildSupermarketOption('Tottus', 'assets/tottus.png'),
            buildSupermarketOption('Acuenta', 'assets/acuenta.png'),
          ],
        ),
      ],
    );
  }

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
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.asset(assetPath, width: 100, height: 100),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget buildHistorialList(String supermarket) {
    if (userName == null) {
      return const Center(
          child: Text('No se pudo obtener el usuario autenticado.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userName)
          .collection('Historiales')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filtrar los documentos para mostrar solo los historiales del supermercado seleccionado
        var filteredDocs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>?; 
          return data != null && data['Supermercado'] == supermarket;
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(
              child: Text(
                  'No hay historiales disponibles para este supermercado.'));
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var historial = filteredDocs[index];
            var total = historial['Total'] ?? 0;
            var fecha = historial['Fecha'] as Timestamp?;

            return Card(
              child: ListTile(
                title: Text(
                  'Fecha: ${formatTimestamp(fecha)}',
                ),
                subtitle: Text('Total: \$${total.toString()}'),
                onTap: () {
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

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Fecha no disponible';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }

  Widget buildHistorialModal(QueryDocumentSnapshot historial) {
  var productos = historial['Productos'] as List<dynamic>;
  var total = historial['Total'] ?? 0;
  var fecha = historial['Fecha'] as Timestamp?;

  return Container(
    padding: const EdgeInsets.all(16),
    height: 400,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de ingreso: ${formatTimestamp(fecha)}',
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
                title: Text(producto['Producto'] ?? 'Sin nombre'),
                trailing: Text('\$${producto['Precio']?.toString() ?? '0'}'),
              );
            },
          ),
        ),
        const SizedBox(height: 16), // Espacio entre la lista y los botones
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Extremos
          children: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: const Text(
                          '¿Estás seguro de que deseas eliminar este historial?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Cerrar diálogo
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _eliminarHistorial(historial.id);
                            Navigator.of(context).pop(); // Cerrar diálogo
                            Navigator.of(context).pop(); // Cerrar modal
                          },
                          child: const Text('Confirmar'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Eliminar historial',
            ),
            IconButton(
              onPressed: () => _downloadOrShareHistorial(historial),
              icon: const Icon(Icons.share, color: Colors.blue),
              tooltip: 'Compartir historial',
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _eliminarHistorial(String historialId) async {
  try {
    await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userName)
        .collection('Historiales')
        .doc(historialId)
        .delete();
    print('Historial eliminado exitosamente.');
  } catch (e) {
    print('Error al eliminar el historial: $e');
  }
}

  Future<void> _downloadOrShareHistorial(QueryDocumentSnapshot historial) async {
    var productos = historial['Productos'] as List<dynamic>;
    var total = historial['Total'] ?? 0;
    var fecha = historial['Fecha'] as Timestamp?;

    // Crear contenido del archivo .txt
    String content = 'Historial de Compra\n';
    content += 'Fecha: ${formatTimestamp(fecha)}\n';
    content += 'Total: \$${total.toString()}\n\n';
    content += 'Productos:\n';
    for (var producto in productos) {
      content += '${producto['Producto'] ?? 'Sin nombre'} - \$${producto['Precio']?.toString() ?? '0'}\n';
    }

    // Obtener la ruta del directorio temporal
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/historial_compras.txt';
    final file = File(path);

    // Escribir el contenido en el archivo
    await file.writeAsString(content);

    // Compartir el archivo
    Share.shareFiles([path], text: 'Historial de Compras');
  }
}
