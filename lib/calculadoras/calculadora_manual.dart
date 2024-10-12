import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculadoraM extends StatefulWidget {
  const CalculadoraM({Key? key}) : super(key: key);

  @override
  _CalculadoraMState createState() => _CalculadoraMState();
}

class _CalculadoraMState extends State<CalculadoraM> {
  String input = '';
  String history = '';
  bool hasError = false;
  final ScrollController _scrollController = ScrollController();
  double fontSize = 80;
  final List<String> operators = ['+', '-', 'x', '/', '%'];
  bool isDecimalUsed = false;
  bool isOperatorPressed = false;

  void buttonPressed(String buttonText) {
    if (hasError && buttonText != "AC") {
      return;
    }

    setState(() {
      if (buttonText == "AC") {
        _resetCalculator();
      } else if (buttonText == "C") {
        _deleteLastCharacter();
      } else if (buttonText == '.') {
        _handleDecimalInput();
      } else if (buttonText == '=') {
        _evaluateExpression();
      } else {
        _handleOperatorAndNumberInput(buttonText);
      }

      _adjustFontSize();
      _scrollToEnd();
    });
  }

  void _resetCalculator() {
    input = '';
    history = '';
    hasError = false;
    isDecimalUsed = false;
    isOperatorPressed = false;
  }

  void _deleteLastCharacter() {
    if (input.isNotEmpty) {
      if (input.endsWith('.')) {
        isDecimalUsed = false;
      }
      input = input.substring(0, input.length - 1);
    }
  }

  void _handleDecimalInput() {
    if (!isDecimalUsed) {
      input += '.';
      isDecimalUsed = true;
    }
  }

  void _handleOperatorAndNumberInput(String buttonText) {
    if (operators.contains(buttonText)) {
      if (input.isEmpty || isOperatorPressed) {
        return;
      }
      _evaluateExpression();
      input += buttonText;
      isOperatorPressed = true;
      isDecimalUsed = false;
    } else {
      input += buttonText;
      isOperatorPressed = false;
    }
  }

  void _evaluateExpression() {
    try {
      String finalInput = input.replaceAll('x', '*').replaceAll('%', '/100');
      Parser parser = Parser();
      Expression exp = parser.parse(finalInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        history = input;
        input = _formatResult(eval);
        if (input.endsWith(".0")) {
          input = input.substring(0, input.length - 2);
        }
        isOperatorPressed = false;
      });
    } catch (e) {
      setState(() {
        input = "Error";
        hasError = true;
      });
    }
  }

  String _formatResult(double result) {
    if (result.toString().contains('e')) {
      return result.toStringAsExponential(2);
    } else if (result == result.toInt()) {
      return result.toInt().toString();
    } else {
      return result.toStringAsFixed(8);
    }
  }

  void _adjustFontSize() {
    if (input.length > 10) {
      fontSize = 80 - (input.length - 10) * 2;
      if (fontSize < 20) fontSize = 20;
    } else {
      fontSize = 80;
    }
  }

  void _scrollToEnd() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Widget calcButton(String btntxt, Color btncolor, Color txtcolor,
      {double btnWidth = 70, double fontSize = 28}) {
    return SizedBox(
      width: btnWidth,
      child: ElevatedButton(
        onPressed: () => buttonPressed(btntxt),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: btncolor,
          elevation: 5,
          shadowColor: Colors.grey,
        ),
        child: Text(
          btntxt,
          style: TextStyle(fontSize: fontSize, color: txtcolor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 197, 235, 248),
      appBar: AppBar(
        title: const Text('Calculadora Pro Estilo iOS'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/logo-v2.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    history,
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.bottomRight,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            input.isEmpty ? '0' : input,
                            style: TextStyle(
                                fontSize: fontSize, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    calcButton('AC', Colors.redAccent, Colors.white,
                        fontSize:
                            20), // Ajusté el tamaño de la fuente para "AC"
                    calcButton('C', Colors.grey.shade700, Colors.white),
                    calcButton('/', Colors.blueAccent, Colors.white),
                    calcButton('x', Colors.blueAccent, Colors.white),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    calcButton('7', Colors.grey.shade800, Colors.white),
                    calcButton('8', Colors.grey.shade800, Colors.white),
                    calcButton('9', Colors.grey.shade800, Colors.white),
                    calcButton('%', Colors.blueAccent, Colors.white),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    calcButton('4', Colors.grey.shade800, Colors.white),
                    calcButton('5', Colors.grey.shade800, Colors.white),
                    calcButton('6', Colors.grey.shade800, Colors.white),
                    calcButton('-', Colors.blueAccent, Colors.white),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    calcButton('1', Colors.grey.shade800, Colors.white),
                    calcButton('2', Colors.grey.shade800, Colors.white),
                    calcButton('3', Colors.grey.shade800, Colors.white),
                    calcButton('+', Colors.blueAccent, Colors.white),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    calcButton('0', Colors.grey.shade800, Colors.white,
                        btnWidth: 160),
                    calcButton('.', Colors.grey.shade800, Colors.white),
                    calcButton('=', Colors.greenAccent, Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
