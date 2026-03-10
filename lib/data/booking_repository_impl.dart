import '../domain/entities/booking.dart';
import '../domain/repositories/i_booking_repository.dart';

class BookingRepositoryImpl implements IBookingRepository {
  final List<Booking> _bookings = [];

  @override
  Future<bool> saveBooking({
    required String tripId,
    required String passengerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _bookings.add(Booking(
      bookingId: DateTime.now().millisecondsSinceEpoch.toString(),
      tripId: tripId,
      passengerId: passengerId,
      createdAt: DateTime.now(),
      totalSeats: 1,
      availableSeats: 1,
    ));
    return true;
  }

  @override
  Future<List<Booking>> getBookingsForPassenger(String passengerId) async {
    return _bookings.where((b) => b.passengerId == passengerId).toList();
  }
}