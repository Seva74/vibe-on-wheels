import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/driver.dart';
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
  })  : _searchUseCase = searchUseCase,
        _joinUseCase = joinUseCase,
        _tripRepository = tripRepository;

  ViewState _searchState = ViewState.idle;
  List<Trip> _trips = [];
  String _searchError = '';

  ViewState _bookingState = ViewState.idle;
  String _bookingError = '';

  BookingConfirmationStatus _confirmationStatus = BookingConfirmationStatus.none;
  Trip? _confirmedTrip;
  Driver? _confirmedDriver;

  final Map<String, Driver> _driversCache = {};
  final Set<String> _driverFetchInProgress = {};
  Timer? _confirmationTimer;
  bool _isDisposed = false;

  ViewState get searchState => _searchState;
  List<Trip> get trips => _trips;
  String get searchError => _searchError;

  ViewState get bookingState => _bookingState;
  String get bookingError => _bookingError;

  BookingConfirmationStatus get confirmationStatus => _confirmationStatus;
  Trip? get confirmedTrip => _confirmedTrip;
  Driver? get confirmedDriver => _confirmedDriver;

  Future<void> fetchTrips({required String from, required String to, DateTime? date}) async {
    final normalizedFrom = from.trim();
    final normalizedTo = to.trim();
    final latinOnly = RegExp(r'^[a-zA-Z\s]+$');

    if (normalizedFrom.isEmpty || normalizedTo.isEmpty) {
      _searchState = ViewState.error;
      _searchError = 'Заполните пункты "Откуда" и "Куда".';
      _trips = [];
      _safeNotifyListeners();
      return;
    }

    if (latinOnly.hasMatch(normalizedFrom) || latinOnly.hasMatch(normalizedTo)) {
      _searchState = ViewState.error;
      _searchError = 'Пожалуйста, введите название города на русском языке.';
      _trips = [];
      _safeNotifyListeners();
      return;
    }

    _searchState = ViewState.loading;
    _searchError = '';
    _trips = [];
    _safeNotifyListeners();

    try {
      _trips = await _searchUseCase.execute(
        from: normalizedFrom,
        to: normalizedTo,
        time: date,
      );
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

  Future<bool> handleJoinRequest(Trip trip) async {
    _bookingState = ViewState.loading;
    _bookingError = '';
    _safeNotifyListeners();

    try {
      final result = await _joinUseCase.execute(
        tripId: trip.tripId,
        passengerId: 'p1',
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
      _confirmedDriver = _driversCache[trip.driverId];
      _safeNotifyListeners();

      _confirmationTimer?.cancel();
      _confirmationTimer = Timer(const Duration(seconds: 3), () {
        if (_confirmationStatus != BookingConfirmationStatus.booked ||
            _confirmedTrip?.tripId != trip.tripId) {
          return;
        }
        _confirmationStatus = BookingConfirmationStatus.driverAccepted;
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

  @override
  void dispose() {
    _isDisposed = true;
    _confirmationTimer?.cancel();
    super.dispose();
  }
}