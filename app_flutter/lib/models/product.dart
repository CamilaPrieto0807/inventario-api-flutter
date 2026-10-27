class Product {
  const Product({
    this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.precio,
    required this.cantidad,
    required this.categoria,
  });

  final int? id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final double precio;
  final int cantidad;
  final String categoria;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] == null ? null : int.parse(json['id'].toString()),
    nombre: json['nombre'] as String,
    codigo: json['codigo'] as String,
    descripcion: json['descripcion'] as String?,
    precio: double.parse(json['precio'].toString()),
    cantidad: int.parse(json['cantidad'].toString()),
    categoria: json['categoria'] as String,
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'codigo': codigo,
    'descripcion': descripcion,
    'precio': precio,
    'cantidad': cantidad,
    'categoria': categoria,
  };
}
