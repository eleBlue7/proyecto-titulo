import 'package:flutter/material.dart';
import 'package:supcalculadora/calculadoras/calculadora_de_voz/modelo_producto.dart';
import 'package:supcalculadora/calculadoras/calculadora_de_voz/guardado_firebase.dart';

class CalculadoraM extends StatefulWidget {
  final String supermarket;

  const CalculadoraM({super.key, required this.supermarket});

  @override
  _CalculadoraMState createState() => _CalculadoraMState();
}

class _CalculadoraMState extends State<CalculadoraM>
    with SingleTickerProviderStateMixin {
  final List<Map<String, TextEditingController>> _productControllers = [];
  double _totalPrice = 0;
  bool _showDeleteButtons = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _addProduct();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -2, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addProduct() {
    setState(() {
      _productControllers.add({
        'name': TextEditingController(),
        'price': TextEditingController(),
      });
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _productControllers.removeAt(index);
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    double total = 0;
    for (final controllers in _productControllers) {
      final priceString = controllers['price']!.text;
      if (priceString.isNotEmpty) {
        final price = double.tryParse(priceString) ?? 0.0;
        total += price;
      }
    }
    setState(() {
      _totalPrice = total;
    });
  }

void _saveProducts() async {
  List<Product> products = _productControllers.map((controllers) {
    return Product(
      controllers['name']!.text,
      int.tryParse(controllers['price']!.text) ?? 0,
      widget.supermarket,  // Asignar el supermercado aquí
    );
  }).toList();

  await saveProductsToFirestore(products,widget.supermarket);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Productos guardados en Firestore')),
  );

  _clearProductControllers();
}



  void _clearProductControllers() {
    for (final controllers in _productControllers) {
      controllers['name']!.clear();
      controllers['price']!.clear();
    }
    setState(() {
      _totalPrice = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4B0082),
            Color.fromARGB(255, 197, 235, 248), // Azul más claro en la parte inferior
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Ingresa tus productos en ${widget.supermarket}',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Color(0xFF4B0082),
          actions: [
            IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: _saveProducts,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Precio Total: \$${_totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _productControllers.length,
                  itemBuilder: (context, index) {
                    final controllers = _productControllers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controllers['name'],
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.shopping_cart),
                                  labelText: 'Nombre del Producto ${index + 1}',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: controllers['price'],
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.price_change),
                                  labelText: 'Precio',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  _calculateTotalPrice();
                                },
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            if (_showDeleteButtons)
                              AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _animation.value),
                                    child: IconButton(
                                      icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: Color.fromARGB(255, 255, 0, 0)),
                                      onPressed: () => _removeProduct(index),
                                      tooltip: 'Eliminar producto',
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _addProduct,
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        const SizedBox(width: 8),
                        const Text('Agregar Producto'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showDeleteButtons = !_showDeleteButtons;
                      });
                    },
                    child: Text(_showDeleteButtons
                        ? 'Cancelar Eliminación'
                        : 'Eliminar Productos'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
