import 'user.dart';

class Passenger extends User {
  final bool isStudent;

  Passenger({
    required super.id,
    required super.name,
    required super.phone,
    required super.mail,
    required super.rating,
    required super.registeredAt,
    required this.isStudent,
  });
}
