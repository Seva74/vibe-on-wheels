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

  ViewState get searchState => _searchState;
  List<Trip> get trips => _trips;
  String get searchError => _searchError;

  ViewState get bookingState => _bookingState;
  String get bookingError => _bookingError;

  BookingConfirmationStatus get confirmationStatus => _confirmationStatus;
  Trip? get confirmedTrip => _confirmedTrip;
  Driver? get confirmedDriver => _confirmedDriver;


  Future<void> fetchTrips({required String from, required String to}) async {
    final latinOnly = RegExp(r'^[a-zA-Z\s]+$');
    if (latinOnly.hasMatch(from.trim()) || latinOnly.hasMatch(to.trim())) {
      _searchState = ViewState.error;
      _searchError = 'Пожалуйста, введите название города на русском языке.';
      _trips = [];
      notifyListeners();
      return;
    }

    _searchState = ViewState.loading;
    _trips = [];
    notifyListeners();

    try {
      _trips = await _searchUseCase.execute(from: from, to: to);
      _searchState = _trips.isEmpty ? ViewState.success : ViewState.success;
      for (final trip in _trips) {
        _prefetchDriver(trip.driverId);
      }
    } catch (e) {
      _searchState = ViewState.error;
      _searchError = 'Произошла ошибка. Попробуйте ещё раз.';
    }
    notifyListeners();
  }

  void _prefetchDriver(String driverId) async {
    if (_driversCache.containsKey(driverId)) return;
    final driver = await _tripRepository.getDriverById(driverId);
    if (driver != null) {
      _driversCache[driverId] = driver;
      notifyListeners();
    }
  }

  Driver? getDriverForTrip(String driverId) => _driversCache[driverId];


  Future<bool> handleJoinRequest(Trip trip) async {
    _bookingState = ViewState.loading;
    notifyListeners();

    try {
      final result = await _joinUseCase.execute(
        tripId: trip.tripId,
        passengerId: 'p1',
      );
      if (!result) {
        _bookingState = ViewState.error;
        _bookingError = 'Не удалось забронировать поездку.';
        notifyListeners();
        return false;
      }

      _bookingState = ViewState.success;
      _confirmationStatus = BookingConfirmationStatus.booked;
      _confirmedTrip = trip;
      _confirmedDriver = _driversCache[trip.driverId];
      notifyListeners();


      Future.delayed(const Duration(seconds: 3), () {
        _confirmationStatus = BookingConfirmationStatus.driverAccepted;
        notifyListeners();
      });

      return true;
    } catch (e) {
      _bookingState = ViewState.error;
      _bookingError = 'Ошибка подключения. Попробуйте позже.';
      notifyListeners();
      return false;
    }
  }

  void resetBookingState() {
    _bookingState = ViewState.idle;
    _bookingError = '';
    _confirmationStatus = BookingConfirmationStatus.none;
    _confirmedTrip = null;
    _confirmedDriver = null;
    notifyListeners();
  }
}