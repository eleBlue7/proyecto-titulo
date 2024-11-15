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
  bool _showQuantity = true; // Controla si mostrar el multiplicador o no
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
        'quantity': TextEditingController(text: '1'), // Inicializado en 1
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
          : 0; // Si no es un número válido, usa 0

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

    if (quantity < 1) quantity = 1; // Evita cantidades menores a 1

    controllers['quantity']!.text = quantity.toString();
    _calculateTotalPrice();
  }

  double _getFontSize(String text) {
    return text.length > 5 ? 12 : 14; // Ajusta el tamaño si el número es largo
  }

  void _saveProducts() async {
    List<Product> products = _productControllers.map((controllers) {
      return Product(
        controllers['name']!.text,
        int.tryParse(controllers['price']!.text) ?? 0,
        widget.supermarket, // Se pasa el supermercado que se recibe en el constructor
      );
    }).toList();

    await saveProductsToFirestore(products, widget.supermarket);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Productos guardados en Firestore')),
    );

    _clearProductControllers();
  }

  void _clearProductControllers() {
    for (final controllers in _productControllers) {
      controllers['name']!.clear();
      controllers['price']!.clear();
      controllers['quantity']!.clear();
    }
    setState(() {
      _totalPrice = 0;
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
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Color(0xFF6D6DFF),
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
              // Mostrar el total como entero, sin decimales
              Text(
                'Precio Total: \$${_totalPrice.toStringAsFixed(0)}', // Muestra el total sin decimales
                style: TextStyle(fontSize: 20, color: Colors.white),
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
                            // Reducir el tamaño del campo del nombre del producto
                            SizedBox(
                              width: 120, // Definir un tamaño más pequeño para el nombre
                              child: TextFormField(
                                controller: controllers['name'],
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.shopping_cart),
                                  labelText: 'Producto ${index + 1}',
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(fontSize: 12), // Fuente más pequeña
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 100, // Ajuste compacto para el campo de precio
                              child: TextFormField(
                                controller: controllers['price'],
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.price_change),
                                  labelText: 'Precio',
                                  labelStyle: TextStyle(fontSize: 14),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(
                                  fontSize: _getFontSize(controllers['price']!.text),
                                ),
                                onChanged: (value) {
                                  _calculateTotalPrice();
                                },
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 2), // Reducir espacio entre el precio y los multiplicadores
                            // Campo de cantidad más grande
                            SizedBox(
                              width: 120, // Aumento del ancho del campo de cantidad
                              child: Row(
                                mainAxisSize: MainAxisSize.min, // Para hacer los botones más cercanos
                                children: [
                                  if (_showQuantity) ...[
                                    IconButton(
                                      iconSize: 20,
                                      icon: Icon(Icons.remove),
                                      onPressed: () => _updateQuantity(index, -1),
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                        controller: controllers['quantity'],
                                        textAlign: TextAlign.center,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(vertical: 2),
                                        ),
                                        style: TextStyle(fontSize: 14), // Fuente más pequeña
                                      ),
                                    ),
                                    IconButton(
                                      iconSize: 20,
                                      icon: Icon(Icons.add),
                                      onPressed: () => _updateQuantity(index, 1),
                                    ),
                                  ],
                                  // El botón de eliminar al lado del precio
                                  if (_showDeleteButtons)
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: Colors.red),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _addProduct,
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        const SizedBox(width: 4),
                        const Text('Agregar Producto'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_showDeleteButtons) {
                          _showDeleteButtons = false;
                          _showQuantity = true; // Mostrar el multiplicador nuevamente
                        } else {
                          _showDeleteButtons = true;
                          _showQuantity = false; // Ocultar el multiplicador
                        }
                      });
                    },
                    child: Text(_showDeleteButtons ? 'Cancelar' : 'Eliminar Producto'),
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
