class Order {
  final int id;
  final String? phone; // Made nullable
  final List<Map<String, dynamic>> items;
  final double total;
  final String? status; // Made nullable

  Order({
    required this.id,
    this.phone,
    required this.items,
    required this.total,
    this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      phone: json['phone'],
      items: List<Map<String, dynamic>>.from(json['items']),
      total: json['total'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (phone != null) 'phone': phone,
        'items': items,
        'total': total,
        if (status != null) 'status': status,
      };
}
