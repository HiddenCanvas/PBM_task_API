class ProductModel {
  final int id;
  final String name;
  final int price;
  final String description;
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      price: int.tryParse(json['price']?.toString() ?? '') ?? 0,
      description: json['description'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}