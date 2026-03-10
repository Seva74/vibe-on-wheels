import '../repositories/i_booking_repository.dart';

class JoinTripUseCase {
  final IBookingRepository repository;

  const JoinTripUseCase(this.repository);

  Future<bool> execute({
    required String tripId,
    required String passengerId,
  }) {
    return repository.saveBooking(
      tripId: tripId,
      passengerId: passengerId,
    );
  }
}
