import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supcalculadora/Perfil/perfil.dart';
import 'package:supcalculadora/calculadoras/calculadora_voz.dart';
import 'package:supcalculadora/calculadoras/calculadora_manual.dart';

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

    _fadeController.repeat(
        reverse:
            true); // Repetir la animación hacia adelante y hacia atrás 3 veces
    Future.delayed(const Duration(seconds: 9), () {
      _fadeController.stop(); // Detener la animación después de 3 repeticiones
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
    }
  }

  // Función para mostrar el modal con las opciones
  void _showCalculatorOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalDeVoz(),
                    ),
                  );
                },
                child: const Text('🗣️ Calculadora de voz'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CalculadoraM(), // La otra calculadora
                    ),
                  );
                },
                child: const Text('🧮 Calculadora manual'),
              ),
            ],
          ),
        );
      },
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
              Text(
                "Bienvenido a AddUpFast❗",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Color negro para las letras
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
                    color: Color.fromARGB(
                        255, 146, 217, 255), // Color cubierto por el brillo
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Fondo de pantalla que se ajusta correctamente
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/logo-v2.png"),
                fit: BoxFit
                    .cover, // Aseguramos que la imagen cubra toda la pantalla sin desplazarse
              ),
            ),
          ),
          // Centrar el nombre del usuario en la parte superior
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 80.0), // Ajuste del espacio desde el AppBar
              child: Text(
                userName, // Mostrar el nombre del usuario
                style: const TextStyle(
                  fontSize: 36, // Tamaño de la fuente más grande
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Color del texto principal
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Color.fromRGBO(
                          179, 254, 255, 1), // Color brillante para el borde
                      offset: Offset(0, 0), // Posición de la sombra (borde)
                    ),
                    Shadow(
                      blurRadius: 20.0,
                      color: Color.fromARGB(
                          255, 207, 255, 241), // Doble borde brillante
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center, // Centrar el texto
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: const Color.fromARGB(
            0, 84, 212, 240), // Fondo transparente para el diseño macOS
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
  Widget _buildMacOSButton(
      {required IconData icon,
      required Color color,
      required int index,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: _activeButtonIndex == index
            ? 2.0
            : 1.0, // Ampliación del icono al hacer tap
        duration:
            const Duration(milliseconds: 370), // Ajuste de duración más notoria
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(0.25), // Sombra para el efecto 3D
                offset: const Offset(5, 5), // Desplazamiento de la sombra
                blurRadius: 10, // Borrado para dar efecto de profundidad
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 30, // Tamaño del ícono
            ),
          ),
        ),
      ),
      onTapDown: (_) {
        setState(() {
          _activeButtonIndex = index; // Cambiar al botón activo
        });
      },
      onTapUp: (_) {
        setState(() {
          _activeButtonIndex = -1; // Restaurar el estado después del "tap"
        });
      },
    );
  }
}
