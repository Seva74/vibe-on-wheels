import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/driver.dart';
import '../../domain/entities/location.dart';
import '../../domain/enums.dart';
import '../../domain/use_cases/search_trips_use_case.dart';
import '../../domain/use_cases/join_trip_use_case.dart';
import '../../domain/repositories/i_trip_repository.dart';

enum ViewState { idle, loading, success, error }

class TripViewModel extends ChangeNotifier {
  final SearchTripsUseCase _searchUseCase;
  final JoinTripUseCase _joinUseCase;
  final ITripRepository _tripRepository;

  TripViewModel({
    required SearchTripsUseCase searchUseCase,
    required JoinTripUseCase joinUseCase,
    required ITripRepository tripRepository,
  }) : _searchUseCase = searchUseCase,
       _joinUseCase = joinUseCase,
       _tripRepository = tripRepository;

  ViewState _searchState = ViewState.idle;
  List<Trip> _trips = [];
  String _searchError = '';

  ViewState _bookingState = ViewState.idle;
  String _bookingError = '';

  BookingConfirmationStatus _confirmationStatus =
      BookingConfirmationStatus.none;
  Trip? _confirmedTrip;
  Driver? _confirmedDriver;
  final List<Trip> _publishedTrips = [];
  final Map<String, List<Trip>> _myTripsByPassenger = {};
  final Map<String, List<Driver>> _chatDriversByPassenger = {};

  final Map<String, Driver> _driversCache = {};
  final Set<String> _driverFetchInProgress = {};
  Timer? _confirmationTimer;
  final bool _isDisposed = false;

  ViewState get searchState => _searchState;
  List<Trip> get trips => _trips;
  String get searchError => _searchError;

  ViewState get bookingState => _bookingState;
  String get bookingError => _bookingError;

  BookingConfirmationStatus get confirmationStatus => _confirmationStatus;
  Trip? get confirmedTrip => _confirmedTrip;
  Driver? get confirmedDriver => _confirmedDriver;
  List<Trip> get myTrips => myTripsFor('p1');
  List<Driver> get chatDrivers => chatDriversFor('p1');

  List<Trip> myTripsFor(String passengerId) {
    return List.unmodifiable(_myTripsByPassenger[passengerId] ?? const <Trip>[]);
  }

  List<Driver> chatDriversFor(String passengerId) {
    return List.unmodifiable(
      _chatDriversByPassenger[passengerId] ?? const <Driver>[],
    );
  }

  Future<void> fetchTrips({
    required String from,
    required String to,
    DateTime? time,
  }) async {
    final fromTrimmed = from.trim();
    final toTrimmed = to.trim();

    if (fromTrimmed.isEmpty || toTrimmed.isEmpty) {
      _searchState = ViewState.error;
      _searchError = 'Заполните поля "Откуда" и "Куда".';
      _trips = [];
      notifyListeners();
      return;
    }

    _searchState = ViewState.loading;
    _searchError = '';
    _trips = [];
    _safeNotifyListeners();

    try {
      final foundTrips = await _searchUseCase.execute(
        from: fromTrimmed,
        to: toTrimmed,
        time: time,
      );
      final publishedMatches = _publishedTrips
          .where(
            (trip) => _matchesSearchFilter(
              trip,
              from: fromTrimmed,
              to: toTrimmed,
              time: time,
            ),
          )
          .toList();

      _trips = [...publishedMatches, ...foundTrips];
      _searchState = ViewState.success;
      unawaited(_prefetchDrivers(_trips.map((trip) => trip.driverId)));
    } catch (e) {
      _searchState = ViewState.error;
      _searchError = 'Произошла ошибка. Попробуйте ещё раз.';
    }
    _safeNotifyListeners();
  }

  Future<void> _prefetchDrivers(Iterable<String> driverIds) async {
    final idsToFetch = driverIds
        .toSet()
        .where(
          (driverId) =>
              !_driversCache.containsKey(driverId) &&
              !_driverFetchInProgress.contains(driverId),
        )
        .toList();

    if (idsToFetch.isEmpty) return;

    _driverFetchInProgress.addAll(idsToFetch);

    try {
      final drivers = await Future.wait(idsToFetch.map(_tripRepository.getDriverById));

      var cacheUpdated = false;
      for (var i = 0; i < idsToFetch.length; i++) {
        final driver = drivers[i];
        if (driver != null) {
          _driversCache[idsToFetch[i]] = driver;
          cacheUpdated = true;
        }
      }

      if (cacheUpdated) {
        _safeNotifyListeners();
      }
    } finally {
      _driverFetchInProgress.removeAll(idsToFetch);
    }
  }

  Driver? getDriverForTrip(String driverId) => _driversCache[driverId];

  Future<void> publishDriverTripOffer({
    required String passengerId,
    required String driverName,
    required String driverPhone,
    required String from,
    required String to,
    required DateTime startTime,
    required int seats,
    double? fromLat,
    double? fromLng,
    double? toLat,
    double? toLng,
  }) async {
    final normalizedPassengerId = passengerId.trim().isEmpty
        ? 'p1'
        : passengerId.trim();
    final driverId = 'user_driver_$normalizedPassengerId';

    final driver = _driversCache.putIfAbsent(
      driverId,
      () => Driver(
        id: driverId,
        name: driverName.trim().isEmpty ? 'Водитель' : driverName.trim(),
        phone: driverPhone,
        mail: '$driverId@vibe.local',
        rating: 0,
        driverRating: 0,
        registeredAt: DateTime.now(),
        carModel: 'Личный автомобиль',
        carPlate: 'Не указано',
        isVerified: false,
      ),
    );

    final normalizedSeats = seats.clamp(1, 6).toInt();

    final trip = Trip(
      tripId: 'ud_${DateTime.now().millisecondsSinceEpoch}',
      startTime: startTime,
      price: _estimateDriverTripPrice(normalizedSeats),
      totalSeats: normalizedSeats,
      status: TripStatus.planned,
      startLocation: LocationModel(
        address: from.trim(),
        lat: fromLat ?? 56.4977,
        lng: fromLng ?? 84.9744,
      ),
      endLocation: LocationModel(
        address: to.trim(),
        lat: toLat ?? 55.0302,
        lng: toLng ?? 82.9204,
      ),
      driverId: driver.id,
      bookings: const [],
    );

    _publishedTrips.insert(0, trip);
    _trips = [trip, ..._trips.where((existing) => existing.tripId != trip.tripId)];
    _searchState = ViewState.success;
    _safeNotifyListeners();
  }

  Future<bool> handleJoinRequest(
    Trip trip, {
    Driver? driver,
    String passengerId = 'p1',
  }) async {
    _bookingState = ViewState.loading;
    _bookingError = '';
    _safeNotifyListeners();

    try {
      final result = await _joinUseCase.execute(
        tripId: trip.tripId,
        passengerId: passengerId,
      );

      if (!result) {
        _bookingState = ViewState.error;
        _bookingError = 'Не удалось забронировать поездку.';
        _safeNotifyListeners();
        return false;
      }

      _bookingState = ViewState.success;
      _confirmationStatus = BookingConfirmationStatus.booked;
      _confirmedTrip = trip;
      _confirmedDriver = driver ?? _driversCache[trip.driverId];
      _safeNotifyListeners();

      _confirmationTimer?.cancel();
      _confirmationTimer = Timer(const Duration(seconds: 3), () {
        if (_confirmationStatus != BookingConfirmationStatus.booked ||
            _confirmedTrip?.tripId != trip.tripId) {
          return;
        }
        _confirmationStatus = BookingConfirmationStatus.driverAccepted;
        _addTripToHistoryIfNeeded(trip, passengerId: passengerId);
        final acceptedDriver = _confirmedDriver;
        if (acceptedDriver != null) {
          _addDriverToChatsIfNeeded(
            acceptedDriver,
            passengerId: passengerId,
          );
        }
        _safeNotifyListeners();
      });

      return true;
    } catch (e) {
      _bookingState = ViewState.error;
      _bookingError = 'Ошибка подключения. Попробуйте позже.';
      _safeNotifyListeners();
      return false;
    }
  }

  void resetBookingState() {
    _confirmationTimer?.cancel();
    _bookingState = ViewState.idle;
    _bookingError = '';
    _confirmationStatus = BookingConfirmationStatus.none;
    _confirmedTrip = null;
    _confirmedDriver = null;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  void _addTripToHistoryIfNeeded(
    Trip trip, {
    required String passengerId,
  }) {
    final trips = _myTripsByPassenger.putIfAbsent(passengerId, () => []);
    final exists = trips.any((stored) => stored.tripId == trip.tripId);
    if (exists) return;
    trips.insert(0, trip);
  }

  void _addDriverToChatsIfNeeded(
    Driver driver, {
    required String passengerId,
  }) {
    final drivers = _chatDriversByPassenger.putIfAbsent(
      passengerId,
      () => [],
    );
    final exists = drivers.any((stored) => stored.id == driver.id);
    if (exists) return;
    drivers.insert(0, driver);
  }

  bool _matchesSearchFilter(
    Trip trip, {
    required String from,
    required String to,
    DateTime? time,
  }) {
    final requestedFrom = _normalizeSearchText(from);
    final requestedTo = _normalizeSearchText(to);
    final tripFrom = _normalizeSearchText(trip.startLocation.address);
    final tripTo = _normalizeSearchText(trip.endLocation.address);

    final fromMatches =
        tripFrom.contains(requestedFrom) || requestedFrom.contains(tripFrom);
    final toMatches = tripTo.contains(requestedTo) || requestedTo.contains(tripTo);
    if (!fromMatches || !toMatches) {
      return false;
    }

    if (time == null) {
      return true;
    }

    return trip.startTime.year == time.year &&
        trip.startTime.month == time.month &&
        trip.startTime.day == time.day;
  }

  String _normalizeSearchText(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  double _estimateDriverTripPrice(int seats) {
    final normalizedSeats = seats.clamp(1, 6).toInt();
    return (300 + normalizedSeats * 90).toDouble();
  }
}
