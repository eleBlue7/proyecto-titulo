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
  bool _showQuantity = true;

  @override
  void initState() {
    super.initState();
    _addProduct();
  }

  void _addProduct() {
    setState(() {
      _productControllers.add({
        'name': TextEditingController(),
        'price': TextEditingController(),
        'quantity': TextEditingController(text: '1'),
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
      final priceString = controllers['price']!.text.trim();
      final quantityString = controllers['quantity']!.text;

      final price = priceString.isNotEmpty && int.tryParse(priceString) != null
          ? int.parse(priceString)
          : 0;

      final quantity = int.tryParse(quantityString) ?? 1;

      total += price * quantity;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  void _updateQuantity(int index, int change) {
    final controllers = _productControllers[index];
    int quantity = int.tryParse(controllers['quantity']!.text) ?? 1;
    quantity += change;

    if (quantity < 1) quantity = 1;

    controllers['quantity']!.text = quantity.toString();
    _calculateTotalPrice();
  }

  String _capitalize(String input) {
    if (input.isEmpty) return '';
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  void _saveProducts() async {
    List<Product> products = _productControllers.map((controllers) {
      return Product(
        _capitalize(controllers['name']!.text), // Capitalizar el nombre
        int.tryParse(controllers['price']!.text) ?? 0,
        widget.supermarket,
      );
    }).toList();

    await saveProductsToFirestore(products, widget.supermarket);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Productos guardados en Firestore')),
    );

    _clearProductControllers(); // Limpiar después de guardar
  }

  void _clearProductControllers() {
    setState(() {
      _productControllers.clear();
      _totalPrice = 0;
      _addProduct(); // Agregar una fila inicial vacía
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4B0082),
            Color.fromARGB(255, 197, 235, 248),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Ingresa tus productos en ${widget.supermarket}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6D6DFF),
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveProducts,
              tooltip: 'Guardar productos',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Precio Total: \$${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _productControllers.length,
                  itemBuilder: (context, index) {
                    final controllers = _productControllers[index];
                    return Card(
                      margin: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 4.0 : 8.0,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: TextFormField(
                                controller: controllers['name'],
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.shopping_cart),
                                  labelText: 'Producto',
                                  border: OutlineInputBorder(),
                                ),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: controllers['price'],
                                decoration: const InputDecoration(
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
                            const SizedBox(width: 2),
                            SizedBox(
                              width: 120,
                              child: Row(
                                children: [
                                  if (_showQuantity) ...[
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => _updateQuantity(index, -1),
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                        controller: controllers['quantity'],
                                        textAlign: TextAlign.center,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(vertical: 2),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _updateQuantity(index, 1),
                                    ),
                                  ],
                                  if (_showDeleteButtons)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      onPressed: () => _removeProduct(index),
                                      tooltip: 'Eliminar producto',
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Stack(
  children: [
    // Botón de agregar en el centro de la pantalla
    Align(
      alignment: Alignment.center,
      child: CircleAvatar(
        backgroundColor: const Color(0xFF6D6DFF),
        radius: 35,
        child: IconButton(
          onPressed: _addProduct,
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28.0,
          ),
          tooltip: 'Agregar producto',
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
        ),
      ),
    ),

    // Botón de eliminar en la parte inferior derecha
    Positioned(
      bottom: 16.0, // Margen desde el fondo
      right: 16.0,  // Margen desde la derecha
      child: IconButton(
        onPressed: () {
          setState(() {
            _showDeleteButtons = !_showDeleteButtons;
            _showQuantity = !_showQuantity;
          });
        },
        icon: Icon(
          _showDeleteButtons ? Icons.cancel : Icons.delete,
          color: Colors.red,
          size: 28.0,
        ),
        tooltip: _showDeleteButtons ? 'Cancelar' : 'Eliminar producto',
      ),
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
