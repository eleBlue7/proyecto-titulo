class Product {
  String nombre;
  int precio;
  String supermarket;  // Agregar el campo de supermercado

  Product(this.nombre, this.precio, this.supermarket);

  Map<String, dynamic> toJson() => {
        'Nombre del producto': nombre,
        'Precio': precio,
        'Supermercado': supermarket,  // Asegurarse de que se incluya el supermercado al convertir a JSON
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      json['Nombre del producto'],
      json['Precio'],
      json['Supermercado'],  // Recuperar el supermercado al crear desde JSON
    );
  }
}
