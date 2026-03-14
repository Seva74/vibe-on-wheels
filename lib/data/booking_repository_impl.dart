import '../domain/entities/booking.dart';
import '../domain/repositories/i_booking_repository.dart';
import 'mock_data.dart';

class BookingRepositoryImpl implements IBookingRepository {
  // Локальное хранилище — имитация БД сервера
  final List<Booking> _bookings = [];

  @override
  Future<bool> saveBooking({
    required String tripId,
    required String passengerId,
  }) async {
    // Имитируем POST /api/bookings
    await Future.delayed(const Duration(milliseconds: 800));
    Booking temp = createMockBooking(tripId: tripId, passengerId: passengerId);
    if (temp.availableSeats != -1 && (temp.totalSeats != -1)) {
      _bookings.add(temp);
      return true;
    }
    else {return false;}
  }

  @override
  Future<List<Booking>> getBookingsForPassenger(String passengerId) async {
    // Имитируем GET /api/bookings?passengerId=...
    await Future.delayed(const Duration(milliseconds: 300));
    return _bookings.where((b) => b.passengerId == passengerId).toList();
  }
}
