class MenuItem {
  final int id;
  final String name;
  final double price;
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'category': category,
  };
}
