class Reservation {
  final int? id; // Optional, as it’s returned by the backend
  final String name;
  final int people;
  final String phone;
  final String? status; // Optional, defaults to 'pending' on backend
  final String? present; // Optional, defaults to 'no' on backend
  final DateTime? reservationDate; // Optional, managed by backend
  final DateTime? createdAt; // Optional, managed by backend
  final DateTime? updatedAt; // Optional, managed by backend

  Reservation({
    this.id,
    required this.name,
    required this.people,
    required this.phone,
    this.status,
    this.present,
    this.reservationDate,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'people': people,
        'phone': phone,
        'present': present ?? 'no', // Default to 'no' if not provided
      };

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      name: json['name'],
      people: json['people'],
      phone: json['phone'],
      status: json['status'],
      present: json['present'],
      reservationDate: json['reservation_date'] != null
          ? DateTime.parse(json['reservation_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
