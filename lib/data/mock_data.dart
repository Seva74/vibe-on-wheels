import '../domain/entities/driver.dart';
import '../domain/entities/passenger.dart';
import '../domain/entities/trip.dart';
import '../domain/entities/booking.dart';
import '../domain/entities/location.dart';
import '../domain/enums.dart';

/// Имитация базы водителей на сервере
/// Эндпоинт: GET /api/drivers
final List<Driver> mockDrivers = [
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

/// Имитация базы пользователей на сервере
/// Эндпоинт: POST /api/auth/login  { phone } → Passenger
/// Ключ — нормализованный номер телефона (только цифры)
final Map<String, Passenger> mockUsers = {
  '79991234567': Passenger(
    id: 'p1',
    name: 'Алексей Смирнов',
    phone: '79991234567',
    mail: 'alex.student@tsu.ru',
    rating: 4.9,
    registeredAt: DateTime(2024, 3, 10),
    isStudent: true,
  ),
  '79990000001': Passenger(
    id: 'p2',
    name: 'Мария Иванова',
    phone: '79990000001',
    mail: 'maria@mail.ru',
    rating: 4.7,
    registeredAt: DateTime(2024, 5, 1),
    isStudent: false,
  ),
};

/// Генерация поездок по маршруту
/// Эндпоинт: GET /api/trips?from=...&to=...&date=...  → List<Trip>
List<Trip> generateMockTrips({
  required String from,
  required String to,
  DateTime? date,
}) {
  final sourceDate = date ?? DateTime.now();
  final baseDeparture = DateTime(
    sourceDate.year,
    sourceDate.month,
    sourceDate.day,
    sourceDate.hour,
    sourceDate.minute,
  );

  return [
    Trip(
      tripId: 't1',
      startTime: baseDeparture.add(const Duration(hours: 2)),
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
      startTime: baseDeparture.add(const Duration(hours: 3, minutes: 30)),
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
      startTime: baseDeparture.add(const Duration(hours: 5)),
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
      startTime: baseDeparture.add(const Duration(hours: 6, minutes: 15)),
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

/// Имитация создания бронирования
/// Эндпоинт: POST /api/bookings  { tripId, passengerId } → Booking
Booking createMockBooking({
  required String tripId,
  required String passengerId,
}) {
  return Booking(
    bookingId: DateTime.now().millisecondsSinceEpoch.toString(),
    tripId: tripId,
    passengerId: passengerId,
    createdAt: DateTime.now(),
    totalSeats: 1,
    availableSeats: 1,
  );
}
