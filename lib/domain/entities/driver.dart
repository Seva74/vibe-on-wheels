import 'user.dart';
import '../enums.dart';
import 'location.dart';
import 'trip.dart';

class Driver extends User {
  final String carModel;
  final String carPlate;
  final bool isVerified;
  final double driverRating;

  Driver({
    required super.id,
    required super.name,
    required super.phone,
    required super.mail,
    required super.rating,
    required super.registeredAt,
    required this.carModel,
    required this.carPlate,
    required this.isVerified,
    required this.driverRating,
  });

  Trip createTrip({
    required DateTime startTime,
    required double price,
    required int totalSeats,
    required LocationModel startLocation,
    required LocationModel endLocation,
  }) {
    return Trip(
      tripId: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: startTime,
      price: price,
      totalSeats: totalSeats,
      startLocation: startLocation,
      endLocation: endLocation,
      driverId: id,
      status: TripStatus.planned,
      bookings: [],
    );
  }
}
