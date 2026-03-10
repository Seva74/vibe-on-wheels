abstract class User {
  final String id;
  String name;
  String phone;
  String mail;
  final double rating;
  final DateTime registeredAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.mail,
    required this.rating,
    required this.registeredAt,
  });

  bool login(String phone) {
    return phone.isNotEmpty && phone.length == 11;
  }

  void updateProfile(Map<String, dynamic> data) {
    if (data.containsKey('name')) name = data['name'];
    if (data.containsKey('mail')) mail = data['mail'];
    if (data.containsKey('phone')) phone = data['phone'];
  }
}
