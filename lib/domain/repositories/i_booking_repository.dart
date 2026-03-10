import '../entities/booking.dart';

abstract class IBookingRepository {
  Future<bool> saveBooking({
    required String tripId,
    required String passengerId,
  });

  Future<List<Booking>> getBookingsForPassenger(String passengerId);
}
