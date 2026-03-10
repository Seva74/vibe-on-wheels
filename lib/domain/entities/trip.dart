import '../enums.dart';
import 'booking.dart';
import 'location.dart';

class Trip {
  final String tripId;
  final DateTime startTime;
  final double price;
  final int totalSeats;
  TripStatus status;
  final LocationModel startLocation;
  final LocationModel endLocation;
  final String driverId;
  final List<Booking> bookings;

  Trip({
    required this.tripId,
    required this.startTime,
    required this.price,
    required this.totalSeats,
    this.status = TripStatus.planned,
    required this.startLocation,
    required this.endLocation,
    required this.driverId,
    required this.bookings,
  });

  void updateStatus(TripStatus newStatus) => status = newStatus;

  int getAvailableSeats() {
    final occupied = bookings
        .where((b) => b.status == BookingStatus.accepted)
        .fold(0, (sum, b) => sum + b.totalSeats);
    final available = totalSeats - occupied;
    return available > 0 ? available : 0;
  }

  void cancelTrip() => status = TripStatus.cancelled;
}
