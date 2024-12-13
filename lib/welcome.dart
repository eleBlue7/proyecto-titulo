import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supcalculadora/Perfil/perfil.dart';
import 'package:supcalculadora/calculadoras/calculadora_de_voz/supermercado.dart';
import 'package:supcalculadora/Configuraciones/configuraciones.dart';
import 'package:supcalculadora/calculadoras/calculadora_manual/supermercado_manual.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

// Definición de la clase SpeechBubble
class SpeechBubble extends StatelessWidget {
  final Widget child;

  const SpeechBubble({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width *
              0.8, // 80% del ancho de la pantalla
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: child,
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    final bubble = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(20),
        ),
      )
      // Cola de la burbuja
      ..moveTo(size.width / 2 - 15, size.height)
      ..quadraticBezierTo(
          size.width / 2, size.height + 20, size.width / 2 + 15, size.height)
      ..close();

    canvas.drawShadow(bubble, Colors.black54, 4, true);
    canvas.drawPath(bubble, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Definición de la clase Welcome
class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  WelcomeState createState() => WelcomeState();
}

class WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  String userName = '';
  bool isLoadingUserName = true;
  int _activeButtonIndex = -1;

  bool isBubbleVisible = true; // Estado para controlar la visibilidad del globo

  late AnimationController _bubbleAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _iconRotationController;

  @override
  void initState() {
    super.initState();
    _loadUserNameFromFirebase();

    // Inicializar el controlador de animación para el globo
    _bubbleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Definir la animación de deslizamiento para el globo con desplazamiento reducido
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // Desplazamiento reducido hacia abajo
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bubbleAnimationController,
      curve: Curves.easeOut,
    ));

    // Definir la animación de opacidad para el globo
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_bubbleAnimationController);

    // Inicializar el controlador de animación para el ícono de flecha
    _iconRotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Iniciar las animaciones si el globo es visible
    if (isBubbleVisible) {
      _bubbleAnimationController.forward();
      _iconRotationController.forward();
    }
  }

  @override
  void dispose() {
    _bubbleAnimationController.dispose();
    _iconRotationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserNameFromFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      setState(() {
        if (user != null) {
          userName = user.displayName ?? user.email?.split('@')[0] ?? 'Usuario';
        } else {
          userName = 'Usuario';
        }
        isLoadingUserName = false;
      });
    } catch (e) {
      setState(() {
        userName = 'Usuario';
        isLoadingUserName = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserProfileScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Configuraciones()),
      );
    }
  }

  void _showCalculatorOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF36BFED).withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, -10),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Seleccione una opción",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupermarketSelection(),
                        ),
                      );
                    },
                    child: _buildCalculatorCard(
                      icon: Icons.mic,
                      label: "Calculadora de voz",
                      startColor: Colors.blueAccent,
                      endColor: Colors.cyanAccent,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SupermarketSelectionManual(),
                        ),
                      );
                    },
                    child: _buildCalculatorCard(
                      icon: Icons.calculate,
                      label: "Calculadora manual",
                      startColor: Colors.blueAccent,
                      endColor: Colors.cyanAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalculatorCard({
    required IconData icon,
    required String label,
    required Color startColor,
    required Color endColor,
  }) {
    return Container(
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
    );
  }

  Widget _buildShinyIcon({
    required IconData icon,
    required int index,
    required double iconSize,
  }) {
    final bool isActive = _activeButtonIndex == index;
    return GestureDetector(
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
      onTapCancel: () {
        setState(() {
          _activeButtonIndex = -1;
        });
      },
      onTap: () => _onItemTapped(index),
      child: AnimatedScale(
        scale: isActive ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Colors.white, Color.fromARGB(255, 230, 230, 230)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Icon(
            icon,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  // Método personalizado para manejar la vibración con intensidad
  Future<void> _handleLogoTap() async {
    // Verifica si el dispositivo soporta vibraciones
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != null && hasVibrator) {
      // Personaliza la vibración aquí:
      Vibration.vibrate(
        duration: 200, // Ajusta la duración según tu preferencia
        amplitude: 128, // Valor entre 1 y 255 (solo en Android API 26+)
      );
    }

    // Acción original al tocar el botón
    _showCalculatorOptions();
  }

  // Método para alternar la visibilidad del globo con animación
  void _toggleBubbleVisibility() {
    setState(() {
      isBubbleVisible = !isBubbleVisible;
      if (isBubbleVisible) {
        _bubbleAnimationController.forward();
        _iconRotationController.reverse(); // Rotación hacia arriba
      } else {
        _bubbleAnimationController.reverse();
        _iconRotationController.forward(); // Rotación hacia abajo
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcula el tamaño de la pantalla para ajustes responsivos
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Ocultar el AppBar si no es necesario
      ),
      body: Stack(
        children: [
          // Fondo original con logo cubriendo toda la pantalla
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.5,
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color(0xFF36BFED), // Azul Picton
                ],
              ),
              image: DecorationImage(
                image: AssetImage("assets/logo-v2.png"),
                alignment: Alignment.center,
                fit: BoxFit.contain,
              ),
            ),
            // Asegurarse de que el fondo cubra toda la pantalla
            width: double.infinity,
            height: double.infinity,
          ),
          // Botón del logo en el centro con vibración personalizada
          Center(
            child: GestureDetector(
              onTap:
                  _handleLogoTap, // Utiliza el método personalizado con vibración
              child: Container(
                width: 200, // Tamaño original del logo
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // Puedes agregar el logo aquí si lo deseas
                  // image: DecorationImage(
                  //   image: AssetImage('assets/logo-v2.png'),
                  //   fit: BoxFit.cover,
                  // ),
                ),
              ),
            ),
          ),
          // Uso de SafeArea solo para los elementos interactivos
          SafeArea(
            child: Stack(
              children: [
                // Icono de perfil en la esquina superior izquierda
                Positioned(
                  top: 10,
                  left: 10,
                  child: _buildShinyIcon(
                    icon: Icons.person,
                    index: 0,
                    iconSize: 40,
                  ),
                ),
                // Icono de configuración en la esquina superior derecha
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildShinyIcon(
                    icon: Icons.settings,
                    index: 2,
                    iconSize: 40,
                  ),
                ),
              ],
            ),
          ),
          // Globo de mensaje y botón de toggle en la parte inferior
          Positioned(
            bottom: screenHeight * 0.05, // 5% de la altura de la pantalla
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Globo de mensaje con animación
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: isLoadingUserName
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : SpeechBubble(
                            child: Text(
                              'Bienvenido a AddUpFast! $userName.\nPara usar la aplicación, haz un tap en el centro de la pantalla.',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16, // Tamaño de fuente reducido
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 13, 19, 49),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                // Botón circular para toggle con animación de rotación
                GestureDetector(
                  onTap: _toggleBubbleVisibility,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF36BFED),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _iconRotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _iconRotationController.value *
                              3.1416, // Rotación completa de 180 grados
                          child: const Icon(
                            Icons.arrow_upward, // Usar un solo icono y rotarlo
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
