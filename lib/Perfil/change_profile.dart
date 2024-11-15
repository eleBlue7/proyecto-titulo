import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeProfile extends StatefulWidget {
  const ChangeProfile({super.key});

  @override
  _ChangeProfileState createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false; // Para controlar la visibilidad de la contraseña

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para cambiar el nombre de usuario
  Future<void> _changeDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Reautenticación del usuario
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        // Verificar si el nombre de usuario ya está en uso
        final QuerySnapshot querySnapshot = await _firestore
            .collection('Usuarios')
            .where('nombre', isEqualTo: _nameController.text)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Si el nombre ya está en uso, mostrar una alerta
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El nombre de usuario ya está en uso, elige otro.'),
              backgroundColor: Colors.red,
            ),
          );
          return; // Detener flujo
        }

        // Obtener el nombre antiguo (antes de la actualización)
        String oldDisplayName = user.displayName ?? '';

        // Actualizar nombre en Firebase Authentication
        await user.updateDisplayName(_nameController.text);

        // Referencia al nuevo documento en Firestore
        DocumentReference userDoc = _firestore.collection('Usuarios').doc(_nameController.text);

        // Actualizar nombre en Firestore para el nuevo nombre
        await userDoc.set({
          'nombre': _nameController.text,
          'email': user.email ?? 'CorreoDesconocido',
          'uid': user.uid,
        }, SetOptions(merge: true));

        // Copiar los documentos de la colección 'Historiales' del documento antiguo al nuevo
        QuerySnapshot histQuerySnapshot = await _firestore
            .collection('Usuarios')
            .doc(oldDisplayName)
            .collection('Historiales')
            .get();

        // Recorrer los documentos y copiarlos al nuevo documento
        for (var doc in histQuerySnapshot.docs) {
          var docData = doc.data() as Map<String, dynamic>;

          // Asegurarse de que los tipos sean correctos (por ejemplo, convertir DateTime a Timestamp)
          docData.forEach((key, value) {
            if (value is DateTime) {
              docData[key] = Timestamp.fromDate(value);
            }
          });

          // Asegurarse de que el ID no sea nulo o vacío
          var newDocRef = userDoc.collection('Historiales').doc(doc.id.isEmpty
              ? userDoc.collection('Historiales').doc().id
              : doc.id);
          await newDocRef.set(docData, SetOptions(merge: true));
        }

        // Eliminar los documentos antiguos de la colección 'Historiales'
        for (var doc in histQuerySnapshot.docs) {
          await doc.reference.delete(); // Eliminar documento viejo
        }

        // Eliminar el documento antiguo de 'Usuarios' si el nombre ha cambiado
        if (oldDisplayName.isNotEmpty && oldDisplayName != _nameController.text) {
          DocumentReference oldUserDoc = _firestore.collection('Usuarios').doc(oldDisplayName);
          await oldUserDoc.delete(); // Eliminar documento viejo
        }

        // Mostrar éxito y regresar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nombre actualizado correctamente.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar el nombre: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se ha iniciado sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Perfil',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
        backgroundColor: const Color(0xFF6D6DFF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4B0082),
              Color.fromARGB(255, 197, 235, 248),
            ],
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Campo para el nuevo nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Color(0xFF4B0082),),
                        labelText: 'Nuevo nombre de usuario',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un nombre válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo para la contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible, // Controlar si la contraseña es visible u oculta
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF4B0082),),
                        labelText: 'Contraseña actual',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                                color: Color(0xFF4B0082),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Botón para cambiar el nombre
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _changeDisplayName();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B0082),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text(
                        'Cambiar Nombre',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
