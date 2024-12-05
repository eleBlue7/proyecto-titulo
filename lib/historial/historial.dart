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
  String? selectedSupermarket; // Supermercado seleccionado
  String? userName; // Nombre del usuario autenticado

  @override
  void initState() {
    super.initState();
    // Obtener el nombre del usuario autenticado
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
        title: const Text('Historial de Compras',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: const Color(0xFF36bfed),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF36bfed),
              Color.fromARGB(255, 197, 235, 248),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: selectedSupermarket == null
            ? buildSupermarketSelection()
            : buildHistorialList(selectedSupermarket!),
      ),
    );
  }

  // Selección del supermercado
  Widget buildSupermarketSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Seleccione un supermercado para ver los historiales:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            textAlign: TextAlign.center,
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
              buildSupermarketOption('Otros', 'assets/designer.png'),
            ],
          ),
        ],
      ),
    );
  }

  // Opción de supermercado con imagen
  Widget buildSupermarketOption(String name, String assetPath) {
    return GestureDetector(
      onTap: () => selectSupermarket(name),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco para evitar interferencia con el gradiente
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
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

  // Lista de historiales del supermercado seleccionado
  Widget buildHistorialList(String supermarket) {
    if (userName == null) {
      return const Center(
        child: Text('No se pudo obtener el usuario autenticado.'),
      );
    }


    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userName)
          .collection('Supermercados')
          .doc(supermarket.toLowerCase()) // Ajustar a minúsculas
          .collection('Historiales')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
              child: Text(
                  'No hay historiales disponibles para este supermercado.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var historial = docs[index];
            var total = historial['Total'] ?? 0;
            var fecha = historial['Fecha'] as Timestamp?;

            return Card(
              child: ListTile(
                title: Text('Fecha: ${formatTimestamp(fecha)}'),
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

  // Formatear fecha desde Timestamp
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Fecha no disponible';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }

  // Mostrar historial detallado
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  // Confirmar eliminación
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
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await _eliminarHistorial(historial.id);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
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
              IconButton(
                onPressed: () => _editarHistorial(historial),
                icon: const Icon(Icons.edit, color: Colors.orange),
                tooltip: 'Editar historial',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Eliminar historial
  Future<void> _eliminarHistorial(String historialId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userName)
          .collection('Supermercados')
          .doc(selectedSupermarket?.toLowerCase()) // Añadir supermercado
          .collection('Historiales')
          .doc(historialId)
          .delete();
      print('Historial eliminado exitosamente.');
    } catch (e) {
      print('Error al eliminar el historial: $e');
    }
  }

  // Descargar y compartir historial
  Future<void> _downloadOrShareHistorial(
      QueryDocumentSnapshot historial) async {
    var productos = historial['Productos'] as List<dynamic>;
    var total = historial['Total'] ?? 0;
    var fecha = historial['Fecha'] as Timestamp?;

    // Crear contenido del archivo
    String content = 'Historial de Compra\n';
    content += 'Fecha: ${formatTimestamp(fecha)}\n';
    content += 'Total: \$${total.toString()}\n\n';
    content += 'Productos:\n';
    for (var producto in productos) {
      content +=
          '${producto['Producto'] ?? 'Sin nombre'} - \$${producto['Precio']?.toString() ?? '0'}\n';
    }

    // Compartir o descargar el historial
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/historial_compra.txt');
    await file.writeAsString(content);
    Share.shareFiles([file.path], text: 'Historial de compra');
  }

  // Función de edición de historial
  void _editarHistorial(QueryDocumentSnapshot historial) {
    List<dynamic> productos = List.from(historial['Productos']);
    TextEditingController totalController = TextEditingController();

    void calcularTotal() {
      double total = productos.fold(0, (sum, producto) {
        double precio = double.tryParse(producto['Precio'].toString()) ?? 0;
        return sum + precio;
      });
      totalController.text = total.toStringAsFixed(2);
    }

    calcularTotal(); // Calcular el total inicial

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Historial'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          TextEditingController productoController =
                              TextEditingController(
                                  text: productos[index]['Producto']);
                          TextEditingController precioController =
                              TextEditingController(
                                  text: productos[index]['Precio'].toString());

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                // Campo para el nombre del producto
                                Expanded(
                                  child: TextField(
                                    controller: productoController,
                                    decoration: const InputDecoration(
                                      labelText: 'Producto',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        productos[index]['Producto'] = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Campo para el precio del producto
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: precioController,
                                    decoration: const InputDecoration(
                                      labelText: 'Precio',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        productos[index]['Precio'] =
                                            double.tryParse(value) ?? 0;
                                        calcularTotal(); // Recalcular el total
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Mostrar el total calculado
                    Text(
                      'Total: \$${totalController.text}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    // Guardar los cambios en Firestore
                    await FirebaseFirestore.instance
                        .collection('Usuarios')
                        .doc(userName)
                        .collection('Supermercados')
                        .doc(selectedSupermarket?.toLowerCase())
                        .collection('Historiales')
                        .doc(historial.id)
                        .update({
                      'Productos': productos,
                      'Total': double.tryParse(totalController.text),
                    });

                    Navigator.pop(context); // Cerrar el diálogo
                  },
                  child: const Text('Guardar Cambios'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
