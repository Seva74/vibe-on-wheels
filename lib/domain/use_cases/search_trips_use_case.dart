import '../entities/trip.dart';
import '../repositories/i_trip_repository.dart';

class SearchTripsUseCase {
  final ITripRepository repository;

  const SearchTripsUseCase(this.repository);

  Future<List<Trip>> execute({
    required String from,
    required String to,
    DateTime? time,
  }) {
    return repository.findTrips(from: from, to: to, time: time);
  }
}
