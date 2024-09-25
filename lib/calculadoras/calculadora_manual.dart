import 'package:flutter/material.dart' show AppBar, BuildContext, CircleBorder, Color, Colors, Column, CrossAxisAlignment, EdgeInsets, ElevatedButton, MainAxisAlignment, Padding, Row, Scaffold, SizedBox, State, StatefulWidget, Text, TextAlign, TextStyle, Widget;

class CalculadoraM extends StatefulWidget {
  const CalculadoraM({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalculadoraMState createState() => _CalculadoraMState();
}

class _CalculadoraMState extends State<CalculadoraM> {
  Widget calcbutton(String btntxt, Color btncolor, Color txtcolor) {
    return ElevatedButton(
      onPressed: () {
        // Implement your button press logic here
      },
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
            // Calculator display
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    '0',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.white, fontSize: 100),
                  ),
                ),
              ],
            ),
            // Button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add your "AC" button with color properties
                calcbutton('AC', Colors.grey, Colors.black),
                calcbutton('+/-', Colors.grey, Colors.black),
                calcbutton('%', Colors.grey, Colors.black),
                calcbutton('/', Colors.amber, Colors.white),
                // Add more buttons using calcbutton
              ],
            ),
            const SizedBox(height: 10,),
            //now we wil copy above row code and mane more rows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add your "AC" button with color properties
                calcbutton('7', Colors.grey, Colors.black),
                calcbutton('8', Colors.grey, Colors.black),
                calcbutton('9', Colors.grey, Colors.black),
                calcbutton('x', Colors.amber, Colors.white),
                // Add more buttons using calcbutton
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add your "AC" button with color properties
                calcbutton('4', Colors.grey, Colors.black),
                calcbutton('5', Colors.grey, Colors.black),
                calcbutton('6', Colors.grey, Colors.black),
                calcbutton('-', Colors.amber, Colors.white),
                // Add more buttons using calcbutton
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add your "AC" button with color properties
                calcbutton('1', Colors.grey, Colors.black),
                calcbutton('2', Colors.grey, Colors.black),
                calcbutton('3', Colors.grey, Colors.black),
                calcbutton('+', Colors.amber, Colors.white),
                // Add more buttons using calcbutton
              ],
            ),
            const SizedBox(height: 10,),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
              ],
            )
          ],
        ),
      ),
    );
  }
}
