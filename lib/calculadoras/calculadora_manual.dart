import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa esta librería

class CalculadoraM extends StatefulWidget {
  const CalculadoraM({super.key});

  @override
  _CalculadoraMState createState() => _CalculadoraMState();
}

class _CalculadoraMState extends State<CalculadoraM> {
  String input = '0';
  String result = '0';
  String operation = '';
  String history = ''; // Para mostrar el historial de la operación
  double num1 = 0;
  double num2 = 0;

  // Función para manejar los botones de la calculadora
  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "AC") {
        input = '0';
        result = '0';
        history = ''; // Limpia el historial
        operation = '';
        num1 = 0;
        num2 = 0;
      } else if (buttonText == '1' ||
          buttonText == '2' ||
          buttonText == '3' ||
          buttonText == '4' ||
          buttonText == '5' ||
          buttonText == '6' ||
          buttonText == '7' ||
          buttonText == '8' ||
          buttonText == '9' ||
          buttonText == '0') {
        if (input == '0') {
          input = buttonText;
        } else {
          input += buttonText;
        }
      } else if (buttonText == '+' ||
          buttonText == '-' ||
          buttonText == 'x' ||
          buttonText == '/') {
        num1 = double.parse(input);
        operation = buttonText;
        history =
            _formatNumber(num1) + ' ' + operation; // Guarda el historial sin .0
        input = '0';
      } else if (buttonText == '=') {
        num2 = double.parse(input);

        if (operation == '+') {
          result = (num1 + num2).toString();
        } else if (operation == '-') {
          result = (num1 - num2).toString();
        } else if (operation == 'x') {
          result = (num1 * num2).toString();
        } else if (operation == '/') {
          result = (num1 / num2).toString();
        }

        // Formatear el resultado para que solo muestre decimales cuando sea necesario
        result = _formatNumber(double.parse(result));

        history += ' ' +
            _formatNumber(num2) +
            ' = ' +
            result; // Actualiza el historial
        input = result;
        num1 = 0;
        num2 = 0;
        operation = '';
      }
    });
  }

  // Función para formatear los números correctamente
  String _formatNumber(double number) {
    NumberFormat formatter;

    // Si el número es entero, no mostrar decimales
    if (number == number.toInt()) {
      formatter = NumberFormat('#,##0'); // Sin decimales
    } else {
      formatter = NumberFormat('#,##0.####'); // Hasta 4 decimales
    }

    return formatter.format(number);
  }

  Widget calcbutton(String btntxt, Color btncolor, Color txtcolor) {
    return ElevatedButton(
      onPressed: () => buttonPressed(btntxt),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: btncolor,
        padding: const EdgeInsets.all(20),
      ),
      child: Text(
        btntxt,
        style: TextStyle(fontSize: 35, color: txtcolor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Calculadora'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Muestra el historial de la operación
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    history,
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                  ),
                ),
              ],
            ),
            // Muestra el valor actual en pantalla
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    input,
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.white, fontSize: 100),
                  ),
                ),
              ],
            ),
            // Botones de la calculadora
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                calcbutton('AC', Colors.grey, Colors.black),
                calcbutton('+/-', Colors.grey, Colors.black),
                calcbutton('%', Colors.grey, Colors.black),
                calcbutton('/', Colors.amber, Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                calcbutton('7', Colors.grey, Colors.black),
                calcbutton('8', Colors.grey, Colors.black),
                calcbutton('9', Colors.grey, Colors.black),
                calcbutton('x', Colors.amber, Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                calcbutton('4', Colors.grey, Colors.black),
                calcbutton('5', Colors.grey, Colors.black),
                calcbutton('6', Colors.grey, Colors.black),
                calcbutton('-', Colors.amber, Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                calcbutton('1', Colors.grey, Colors.black),
                calcbutton('2', Colors.grey, Colors.black),
                calcbutton('3', Colors.grey, Colors.black),
                calcbutton('+', Colors.amber, Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                calcbutton('0', Colors.grey, Colors.black),
                calcbutton('=', Colors.amber, Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
