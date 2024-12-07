import 'package:flutter/material.dart';
import 'package:supcalculadora/calculadoras/calculadora_de_voz/modelo_producto.dart';
import 'package:supcalculadora/calculadoras/calculadora_de_voz/guardado_firebase.dart';

class CalculadoraM extends StatefulWidget {
  final String supermarket;

  const CalculadoraM({super.key, required this.supermarket});

  @override
  _CalculadoraMState createState() => _CalculadoraMState();
}

class _CalculadoraMState extends State<CalculadoraM> {
  final List<Map<String, TextEditingController>> _productControllers = [];
  double _totalPrice = 0;

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
      final price =
          priceString.isNotEmpty && double.tryParse(priceString) != null
              ? double.parse(priceString)
              : 0;
      total += price;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  void _saveProducts() async {
    // Filtrar productos válidos (nombre no vacío y precio mayor a 0)
    List<Product> products = _productControllers
        .where((controllers) =>
            controllers['name']!.text.trim().isNotEmpty &&
            int.tryParse(controllers['price']!.text.trim()) != null &&
            int.parse(controllers['price']!.text.trim()) > 0)
        .map((controllers) {
      return Product(
        controllers['name']!.text.trim(),
        int.parse(controllers['price']!.text.trim()),
        widget.supermarket,
      );
    }).toList();

    // Validar si hay productos válidos
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos para guardar')),
      );
      return; // No continuar si no hay productos válidos
    }

    // Guardar los productos en Firestore
    await saveProductsToFirestore(products, widget.supermarket);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Productos guardados en Firestore')),
    );

    // Limpiar los campos
    _clearProductControllers();
  }

  void _clearProductControllers() {
    setState(() {
      _productControllers.clear();
      _totalPrice = 0;
      _addProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Calculadora manual',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF36BFED),
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save,
              size: 30.0,
              color: Colors.white,
            ),
            onPressed: _saveProducts,
            tooltip: 'Guardar productos',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF36BFED), // Picton Blue
              Color.fromARGB(255, 250, 250, 250), // Blanco
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Precio Total: \$${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _productControllers.length,
                  itemBuilder: (context, index) {
                    final controllers = _productControllers[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controllers['name'],
                                decoration: const InputDecoration(
                                  labelText: 'Producto',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.shopping_cart),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: controllers['price'],
                                decoration: const InputDecoration(
                                  labelText: 'Precio',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.price_change),
                                ),
                                onChanged: (value) {
                                  _calculateTotalPrice();
                                },
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeProduct(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                backgroundColor: const Color(0xFF36BFED),
                radius: 35,
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 30.0,
                    color: Colors.white,
                  ),
                  onPressed: _addProduct,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
