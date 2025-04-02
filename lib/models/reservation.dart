class Reservation {
  final int? id; // Optional, as it’s returned by the backend
  final String name;
  final int people;
  final String phone;
  final String? status; // Optional, defaults to 'pending' on backend

  Reservation({
    this.id,
    required this.name,
    required this.people,
    required this.phone,
    this.status,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'people': people,
        'phone': phone,
      };

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      name: json['name'],
      people: json['people'],
      phone: json['phone'],
      status: json['status'],
    );
  }
}
