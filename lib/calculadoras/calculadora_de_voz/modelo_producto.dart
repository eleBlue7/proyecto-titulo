class Product {
  String nombre;
  int precio;

  Product(this.nombre, this.precio);

  Map<String, dynamic> toJson() => {
        'Nombre del producto': nombre,
        'Precio': precio,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(json['Nombre del producto'], json['Precio']);
  }
}
