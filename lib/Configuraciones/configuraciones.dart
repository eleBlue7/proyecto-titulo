import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';
import 'package:supcalculadora/Perfil/perfil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supcalculadora/historial/historial.dart';
import 'package:supcalculadora/logins-registros/login_screen.dart';

class Configuraciones extends StatefulWidget {
  const Configuraciones({super.key});

  @override
  _ConfiguracionesState createState() => _ConfiguracionesState();
}

class _ConfiguracionesState extends State<Configuraciones> {
  int _tapCount = 0;
  DateTime? _lastTapTime;
  bool _easterEggActivated = false;
  Offset _logoPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerLogo(); // Centrar el logo al inicio
    });
  }

  void _centerLogo() {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      _logoPosition =
          Offset(screenSize.width / 2 - 75, screenSize.height / 2 - 75);
    });
  }

  void _onSmartSolutionsTap() async {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 1)) {
      _tapCount = 0;
    }
    _lastTapTime = now;
    _tapCount++;

    if (_tapCount <= 3) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50);
      }

      int remainingTaps = 3 - _tapCount;
      if (remainingTaps > 0) {
        Fluttertoast.showToast(
          msg: "Estás a $remainingTaps pasos de un easter egg",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
      } else if (_tapCount == 3) {
        _tapCount = 0;
        _showEasterEgg();
      }
    }
  }

  void _showEasterEgg() {
    setState(() {
      _easterEggActivated = true;
    });
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Draggable(
              feedback: _buildLogo(),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                setState(() {
                  _logoPosition = details.offset;
                });
              },
              onDragUpdate: (details) {
                if (_easterEggActivated) {
                  Vibration.vibrate(
                      duration: 50); // Vibración mientras se arrastra
                }
                setState(() {
                  _logoPosition += details.delta;
                });
              },
              child: _buildLogo(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _logoPosition += details.delta;
        });
      },
      child: Container(
        width: 300,
        height: 300,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/logo-v2.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _showVersionDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Detalles de la Versión"),
          content: const Text(
            "Versión: 0.17 Beta\n"
            "Fecha de Actualización: 30 de Octubre de 2024\n\n"
            "Características:\n"
            "- Calculadora de voz mejorada\n"
            "- Integración con Firebase\n"
            "- Corrección de errores en historial\n\n"
            "Compatibilidad:\n"
            "- Android 5.0 o superior\n"
            "- iOS 12.0 o superior\n\n"
            "Desarrollador:\n"
            "Desarrollado por el Equipo Smart💡Solutions\n\n"
            "Contacto de soporte:\n"
            "Para consultas o soporte, comunícate a: email@inacap.cl\n\n"
            "Licencia y Términos:\n"
            "Al utilizar esta aplicación, aceptas nuestros términos de uso. "
            "La app AddUpFast! es una herramienta diseñada para facilitar el cálculo de compras en supermercados. "
            "Los datos ingresados y generados son de uso exclusivo del usuario. "
            "Smart💡Solutions no se responsabiliza por errores de cálculo que puedan ocurrir debido a datos incorrectos.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
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
        backgroundColor: const Color(0xFF36bfed), // Color de la marca
        title: const Text(
          "Configuraciones",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Cuenta",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF36bfed),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text("Perfil"),
                  leading: const Icon(
                    Icons.account_circle_outlined,
                    color: Color(0xFF36bfed),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Historial",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF36bfed),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text("Mis Compras"),
                  leading: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Color(0xFF36bfed),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Historial(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text("Otros registros"),
                  leading: const Icon(
                    Icons.list_alt,
                    color: Colors.grey,
                  ),
                  onTap: () {},
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Otros",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF36bfed),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text("Detalles de la Versión"),
                  leading: const Icon(Icons.update, color: Colors.grey),
                  onTap: _showVersionDetails,
                ),
                ListTile(
                  title: const Text(
                    "Smart 💡Solutions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading:
                      const Icon(Icons.lightbulb, color: Color(0xFF36bfed)),
                  onTap: _onSmartSolutionsTap,
                ),
                ListTile(
                  title: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  onTap: () async {
                    bool? confirmSignOut = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Cerrar sesión"),
                          content: const Text(
                              "¿Estás seguro de que deseas cerrar sesión?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text("Sí"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmSignOut == true) {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
