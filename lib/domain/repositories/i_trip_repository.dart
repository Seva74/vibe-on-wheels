import '../entities/trip.dart';
import '../entities/driver.dart';

abstract class ITripRepository {
  Future<List<Trip>> findTrips({
    required String from,
    required String to,
    DateTime? time,
  });

  Future<Driver?> getDriverById(String id);

  Future<bool> bookTrip({
    required String tripId,
    required String passengerId,
  });
}
