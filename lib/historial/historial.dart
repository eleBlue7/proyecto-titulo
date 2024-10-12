// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String searchQuery = ""; // Variable para almacenar el texto de búsqueda
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario actual autenticado
    User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? 'UsuarioDesconocido';

    // Referencia a la colección "Historiales" del usuario actual en Firestore
    CollectionReference historial = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userName)
        .collection('Historiales');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historiales"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Mostrar el campo de búsqueda cuando se presiona la lupa
              showSearchDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: historial.snapshots(), // Escuchar cambios en tiempo real
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Mostrar error si lo hay
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar el historial"),
            );
          }

          // Mostrar indicador de carga mientras se obtienen los datos
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si no hay productos en el historial
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay historiales."));
          }

          // Filtrar los historiales según el texto de búsqueda
          var filteredDocs = snapshot.data!.docs.where((doc) {
            String historialName = doc.id.toLowerCase();
            return historialName.contains(searchQuery.toLowerCase());
          }).toList();

          // Mostrar lista de historiales
          return ListView(
            children: filteredDocs.map((DocumentSnapshot document) {
              // Obtener los datos del documento
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              // Nombre del historial, por ejemplo, "Historial 1"
              String historialName = document.id;

              return ListTile(
                title: Text(historialName),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    // Confirmar eliminación
                    bool? confirmDelete = await showDeleteConfirmation(context);
                    if (confirmDelete == true) {
                      // Eliminar historial de Firestore
                      await historial.doc(document.id).delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Historial eliminado')),
                      );
                    }
                  },
                ),
                onTap: () {
                  // Mostrar detalles del historial en un modal
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              historialName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text("Hora de guardado: ${data['Hora de guardado']?.toDate()}"),
                            const SizedBox(height: 8),
                            Text("Total: ${data['Total']?.toString()}"),
                            const SizedBox(height: 16),
                            const Text(
                              "Productos:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: (data['Productos guardados'] as List).length,
                                itemBuilder: (context, index) {
                                  var product = data['Productos guardados'][index];
                                  return ListTile(
                                    title: Text(product['Nombre del producto']),
                                    subtitle: Text("Precio: ${product['Precio']}"),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // Función para mostrar el diálogo de búsqueda
  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Buscar Historial"),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Escriba el nombre del historial...",
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  // Función para confirmar la eliminación del historial
  Future<bool?> showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Está seguro de que desea eliminar este historial?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancelar eliminación
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmar eliminación
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }
}
