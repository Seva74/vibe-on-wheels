import '../domain/entities/trip.dart';
import '../domain/entities/driver.dart';
import '../domain/repositories/i_trip_repository.dart';
import 'mock_data.dart';

class TripRepositoryImpl implements ITripRepository {
  static const _networkDelay = Duration(milliseconds: 800);

  @override
  Future<List<Trip>> findTrips({
    required String from,
    required String to,
    DateTime? time,
  }) async {
    // Имитируем GET /api/trips?from=...&to=...
    await Future.delayed(_networkDelay);
    return generateMockTrips(from: from, to: to, date: time);
  }

  @override
  Future<Driver?> getDriverById(String id) async {
    // Имитируем GET /api/drivers/:id
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return mockDrivers.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> bookTrip({
    required String tripId,
    required String passengerId,
  }) async {
    // Имитируем POST /api/bookings
    await Future.delayed(_networkDelay);
    return true;
  }
}
