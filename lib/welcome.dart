import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supcalculadora/Perfil/perfil.dart';
import 'package:supcalculadora/calculadoras/calculadora_de_voz/supermercado.dart';
import 'package:supcalculadora/Configuraciones/configuraciones.dart';
import 'package:supcalculadora/calculadoras/calculadora_manual/supermercado_manual.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String userName = 'Usuario'; // Nombre por defecto
  int _activeButtonIndex = -1; // Indica cuál icono está siendo presionado

  late AnimationController
      _controller; // Controlador de animación para el brillo
  late AnimationController _fadeController; // Controlador para el parpadeo
  late Animation<double> _fadeAnimation; // Animación de opacidad

  @override
  void initState() {
    super.initState();
    _loadUserNameFromFirebase(); // Cargar el nombre del usuario desde Firebase

    // Inicializamos el controlador de animación para el brillo
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Duración de la animación
      vsync: this,
    )..repeat(reverse: false); // Repetir la animación de forma continua

    // Inicializamos el controlador para el parpadeo
    _fadeController = AnimationController(
      duration: const Duration(seconds: 3), // Duración total del parpadeo
      vsync: this,
    );

    // Configuramos la animación de opacidad (parpadeo)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut, // Animación suave
      ),
    );

    _fadeController.repeat(reverse: true); // Repetir animación
    Future.delayed(const Duration(seconds: 9), () {
      _fadeController.stop(); // Detener la animación después de 9 segundos
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Función para cargar el nombre del usuario desde Firebase
  void _loadUserNameFromFirebase() {
    User? user =
        FirebaseAuth.instance.currentUser; // Obtener el usuario autenticado
    setState(() {
      if (user != null) {
        userName = user.displayName ??
            user.email ??
            'Usuario'; // Mostrar el nombre o correo
      }
    });
  }

  // Función para manejar la interacción con los íconos de navegación
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserProfileScreen(),
        ),
      );
    } else if (_selectedIndex == 1) {
      _showCalculatorOptions();
    } else if (_selectedIndex == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Configuraciones(),
          ));
    }
  }

  // Función para mostrar el modal con las opciones de calculadoras
  void _showCalculatorOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, -10),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Seleccione una opción",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: <Color>[
                          Colors.purple,
                          Colors.blue,
                          Colors.green,
                        ],
                      ).createShader(
                        const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                      ),
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 2),
                        blurRadius: 4.0,
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFancyOptionCard(
                    icon: Icons.mic,
                    label: "Calculadora de voz",
                    startColor: Colors.blueAccent,
                    endColor: Colors.cyanAccent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupermarketSelection(),
                        ),
                      );
                    },
                  ),
                  _buildFancyOptionCard(
                    icon: Icons.calculate,
                    label: "Calculadora manual",
                    startColor: Colors.orangeAccent,
                    endColor: Colors.deepOrangeAccent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SupermarketSelection_manual(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Función para crear tarjetas con gradientes y animación de hover
  Widget _buildFancyOptionCard({
    required IconData icon,
    required String label,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 50),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Centramos el título en el AppBar
        title: FadeTransition(
          opacity: _fadeAnimation, // Aplicar la animación de parpadeo
          child: Stack(
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Bienvenido a AddUpFast❗",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      Colors.transparent,
                      Colors.white,
                      Colors.transparent
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    transform: GradientRotation(_controller.value * 2 * 3.1416),
                  ).createShader(bounds);
                },
                child: const Text(
                  "Bienvenido a AddUpFast❗",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 146, 217, 255),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/logo-v2.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Text(
                userName,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Color.fromRGBO(179, 254, 255, 1),
                      offset: Offset(0, 0),
                    ),
                    Shadow(
                      blurRadius: 20.0,
                      color: Color.fromARGB(255, 207, 255, 241),
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: const Color.fromARGB(0, 84, 212, 240),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMacOSButton(
              icon: Icons.person,
              color: Colors.purple.withOpacity(0.8),
              index: 0,
              onTap: () => _onItemTapped(0),
            ),
            _buildMacOSButton(
              icon: Icons.calculate,
              color: Colors.blue.withOpacity(0.8),
              index: 1,
              onTap: () => _onItemTapped(1),
            ),
            _buildMacOSButton(
              icon: Icons.settings,
              color: Colors.green.withOpacity(0.8),
              index: 2,
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }

  // Función para crear botones estilo macOS con animación de "tap"
  Widget _buildMacOSButton({
    required IconData icon,
    required Color color,
    required int index,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: _activeButtonIndex == index ? 2.0 : 1.0,
        duration: const Duration(milliseconds: 370),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(5, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
      onTapDown: (_) {
        setState(() {
          _activeButtonIndex = index;
        });
      },
      onTapUp: (_) {
        setState(() {
          _activeButtonIndex = -1;
        });
      },
    );
  }
}
