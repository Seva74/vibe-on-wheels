import '../domain/entities/trip.dart';
import '../domain/entities/driver.dart';
import '../domain/entities/location.dart';
import '../domain/enums.dart';
import '../domain/repositories/i_trip_repository.dart';

class TripRepositoryImpl implements ITripRepository {
  final List<Driver> _drivers = [
    Driver(
      id: 'd1',
      name: 'Максим',
      phone: '79000000001',
      mail: 'max.driver@mail.ru',
      rating: 4.8,
      driverRating: 4.9,
      registeredAt: DateTime(2023, 1, 1),
      carModel: 'Hyundai Solaris',
      carPlate: 'А123АА 70',
      isVerified: true,
    ),
    Driver(
      id: 'd2',
      name: 'Роман',
      phone: '79000000002',
      mail: 'roman.drive@mail.ru',
      rating: 4.9,
      driverRating: 5.0,
      registeredAt: DateTime(2023, 6, 1),
      carModel: 'Kia Rio',
      carPlate: 'В456ВВ 70',
      isVerified: true,
    ),
    Driver(
      id: 'd3',
      name: 'Данияр',
      phone: '79000000003',
      mail: 'daniyar@mail.ru',
      rating: 4.7,
      driverRating: 4.7,
      registeredAt: DateTime(2023, 9, 1),
      carModel: 'Toyota Camry',
      carPlate: 'С789СС 70',
      isVerified: false,
    ),
    Driver(
      id: 'd4',
      name: 'Лаура',
      phone: '79000000004',
      mail: 'laura@mail.ru',
      rating: 4.6,
      driverRating: 4.6,
      registeredAt: DateTime(2023, 3, 1),
      carModel: 'Volkswagen Polo',
      carPlate: 'Д012ДД 70',
      isVerified: true,
    ),
  ];

  @override
  Future<List<Trip>> findTrips({
    required String from,
    required String to,
    DateTime? time,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      Trip(
        tripId: 't1',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        price: 480,
        totalSeats: 4,
        status: TripStatus.planned,
        startLocation: LocationModel(address: from, lat: 56.4977, lng: 84.9744),
        endLocation: LocationModel(address: to, lat: 55.0302, lng: 82.9204),
        driverId: 'd1',
        bookings: [],
      ),
      Trip(
        tripId: 't2',
        startTime: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
        price: 650,
        totalSeats: 3,
        status: TripStatus.planned,
        startLocation: LocationModel(address: from, lat: 56.4977, lng: 84.9744),
        endLocation: LocationModel(address: to, lat: 55.0302, lng: 82.9204),
        driverId: 'd2',
        bookings: [],
      ),
      Trip(
        tripId: 't3',
        startTime: DateTime.now().add(const Duration(hours: 5)),
        price: 730,
        totalSeats: 4,
        status: TripStatus.planned,
        startLocation: LocationModel(address: from, lat: 56.4977, lng: 84.9744),
        endLocation: LocationModel(address: to, lat: 55.0302, lng: 82.9204),
        driverId: 'd3',
        bookings: [],
      ),
      Trip(
        tripId: 't4',
        startTime: DateTime.now().add(const Duration(hours: 6, minutes: 15)),
        price: 350,
        totalSeats: 2,
        status: TripStatus.planned,
        startLocation: LocationModel(address: from, lat: 56.4977, lng: 84.9744),
        endLocation: LocationModel(address: to, lat: 55.0302, lng: 82.9204),
        driverId: 'd4',
        bookings: [],
      ),
    ];
  }

  @override
  Future<Driver?> getDriverById(String id) async {
    try {
      return _drivers.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> bookTrip({
    required String tripId,
    required String passengerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}