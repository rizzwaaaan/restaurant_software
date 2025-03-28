class Reservation {
  final String name;
  final int people;
  final String phone;

  Reservation({required this.name, required this.people, required this.phone});

  Map<String, dynamic> toJson() => {
    'name': name,
    'people': people,
    'phone': phone,
  };
}
