import '../enums.dart';

class Booking {
  final String bookingId;
  final String tripId;
  final String passengerId;
  final DateTime createdAt;
  BookingStatus status;
  final int totalSeats;
  final int availableSeats;

  Booking({
    required this.bookingId,
    required this.tripId,
    required this.passengerId,
    required this.createdAt,
    this.status = BookingStatus.pending,
    required this.totalSeats,
    required this.availableSeats,
  });

  void approve() => status = BookingStatus.accepted;
  void reject() => status = BookingStatus.rejected;
  void cancelByPassenger() => status = BookingStatus.cancelled;

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'tripId': tripId,
        'passengerId': passengerId,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'totalSeats': totalSeats,
        'availableSeats': availableSeats,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        bookingId: json['bookingId'],
        tripId: json['tripId'],
        passengerId: json['passengerId'],
        createdAt: DateTime.parse(json['createdAt']),
        status: BookingStatus.values.byName(json['status']),
        totalSeats: json['totalSeats'],
        availableSeats: json['availableSeats'],
      );
}
