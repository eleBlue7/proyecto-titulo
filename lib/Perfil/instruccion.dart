import 'package:flutter/material.dart';

class InstructionScreen extends StatefulWidget {
  const InstructionScreen({super.key});

  @override
  _InstructionScreenState createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instrucciones de Uso"),
      ),
      body: const Padding(
       padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Instrucciones de Uso",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20), // Espacio entre el título y el contenido

            // Puedes agregar aquí más instrucciones o widgets
            Text(
              "1. Para empezar a usar la aplicación, primero inicia sesión con tu cuenta.\n"
              "2. Navega por el menú principal para acceder a las diferentes funcionalidades.\n"
              "3. Cambia tu perfil desde la sección de ajustes.\n"
              "4. Sigue las instrucciones de cada pantalla para completar tus acciones.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Si tienes alguna duda, consulta la sección de ayuda o contacta con el soporte técnico.",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
