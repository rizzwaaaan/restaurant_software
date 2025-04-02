class MenuItem {
  final int id;
  final String name;
  final double price;
  final String category;
  final String? imageUrl; // Added for image display
  final String? course; // Optional, if you plan to use it later

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
    this.course,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      category: json['category'],
      imageUrl: json['image_url'],
      course: json['course'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
        'image_url': imageUrl,
        'course': course,
      };
}
