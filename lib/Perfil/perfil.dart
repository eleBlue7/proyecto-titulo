import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supcalculadora/Perfil/change_password.dart';
import 'package:supcalculadora/Perfil/change_profile.dart';
import 'package:supcalculadora/logins-registros/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  User? user;
  XFile? _imageFile;
  String? _storedImagePath;

  @override
  void initState() {
    super.initState();
    // Obtener el usuario actual
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadStoredImage(); // Cargar la imagen guardada al iniciar
    }
  }

  Future<void> _loadStoredImage() async {
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        // Buscar la ruta de la imagen guardada asociada al UID del usuario
        _storedImagePath = prefs.getString('profile_image_${user!.uid}');
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && user != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          '${user!.uid}_${pickedFile.name}'; // Usar el UID del usuario
      final String savedImagePath = '${appDir.path}/$fileName';

      // Guardar la imagen en el directorio local
      File imageFile = File(pickedFile.path);
      await imageFile.copy(savedImagePath);

      // Guardar la ruta de la imagen en SharedPreferences asociada al UID del usuario
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_${user!.uid}', savedImagePath);

      setState(() {
        _imageFile = pickedFile; // Actualizar la imagen seleccionada
        _storedImagePath = savedImagePath; // Actualizar la ruta almacenada
      });
    }
  }

  // Método para mostrar el diálogo modal con la versión
  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Como Usar AddUpFast!'),
          content: const SingleChildScrollView(
            child: Text("Instrucciones De Uso:\n"
            "1. Para empezar a usar la aplicación, primero inicia sesión con tu cuenta.\n"
              "2. Navega por el menú principal para acceder a las diferentes funcionalidades.\n"
              "3. Cambia tu perfil desde la sección de ajustes.\n"
              "4. Para ocupar las distintas calculadoras porfavor elige la de tu preferencia (Calculadora de voz o Calculadora Manual).\n"
              "5. Indicar el supermercado el cual estas visitando para poder guardar el historial de tu compra.\n"
              "6. Si vas a utilizar la calculadora de voz porfavor acepta los permisos para utilizar tu microfono para poder utilizar esta funcion.\n"
              "7. Apreta el boton del microfono en la vista, Luego Indica el producto y el precio correspondiente a este.\n"
              "8. Apreta el boton de guardado en la parte superior derecha para poder guardar tu historial de compra.\n"
              "9. Si ocuparas la calculadora Manual en su primer campo va el nombre del producto, segundo el precio de este para posterior de ese campo aumentar o disminuir la cantdidad de los productos.\n\n"
            "Desarrollador:\n"
            "Desarrollado por el Equipo Smart💡Solutions\n\n"
            "Contacto de soporte:\n"
            "Para consultas o soporte, comunícate a: soporte@gmail.com\n\n"
            "Licencia y Términos:\n"
            "Al utilizar esta aplicación, aceptas nuestros términos de uso. "
            "La app AddUpFast! es una herramienta diseñada para facilitar el cálculo de compras en supermercados. "
            "Los datos ingresados y generados son de uso exclusivo del usuario. "
            "Smart💡Solutions no se responsabiliza por errores de cálculo que puedan ocurrir debido a datos incorrectos.")),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del Usuario", style:TextStyle(fontWeight: FontWeight.w600,color: Color.fromARGB(255, 0, 0, 0))),
        backgroundColor: const Color.fromARGB(255, 255, 255,255),
        actions: [
          // Ícono que al ser presionado mostrará el diálogo
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: _showVersionDialog, // Llama al método que muestra el diálogo
          ),
          
        ],
        centerTitle: false,
      ),
      body: user != null
          ? Column(
              children: [
                const SizedBox(height: 20),

                // Marco para la foto de perfil con ícono de cámara
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight, // Posiciona el ícono en la esquina inferior derecha
                    children: [
                      // Círculo para la foto de perfil
                      CircleAvatar(
                        radius: 60, // Tamaño del círculo
                        backgroundColor: Colors.grey.shade300, // Color del marco
                        child: ClipOval(
                          child: _storedImagePath != null
                              ? Image.file(
                                  File(_storedImagePath!), // Mostrar la imagen almacenada
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )
                              : (user!.photoURL != null
                                  ? Image.network(
                                      user!.photoURL!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey, // Color del ícono predeterminado
                                    )),
                        ),
                      ),
                      // Ícono de cámara
                      GestureDetector(
                        onTap: _pickImage, // Permitir selección de imagen al tocar el ícono
                        child: CircleAvatar(
                          radius: 20, // Tamaño del ícono
                          backgroundColor: Colors.blueAccent, // Fondo del ícono
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white, // Color del ícono
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Mostrar los detalles del usuario
                Text(
                  "Bienvenido, ${user!.displayName ?? "Usuario sin nombre"}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold,color: Color(0xFF36bfed)),
                ),
                const SizedBox(height: 10),

                // Lista de opciones del perfil con único subtítulo
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(19),
                    children: [
                      // Subtítulo para configuración de cuenta
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Configuración de cuenta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF36bfed),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                        child: Text(
                          'Administra tu información personal y tu contraseña de seguridad.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person,color: Color(0xFF36bfed),),
                        title: const Text('Cambiar Perfil'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangeProfile(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.lock, color: Color(0xFF36bfed),),
                        title: const Text('Cambiar Contraseña'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePassword(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Botón de Cerrar Sesión
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Has cerrado sesión correctamente"),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                // Texto de derechos
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Desarrollado por SmartSolutions.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45, // Estilo transparente
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : const Center(child: Text("No se ha iniciado sesión")),
    );
  }
}
