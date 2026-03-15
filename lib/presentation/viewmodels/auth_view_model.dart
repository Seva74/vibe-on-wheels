import 'package:flutter/foundation.dart';
import '../../domain/entities/passenger.dart';
import '../../data/mock_data.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  static const String _defaultUserId = 'p1';

  AuthState _state = AuthState.idle;
  String _errorMessage = '';
  Passenger? _currentUser;
  bool _isLoggedIn = false;

  final Map<String, int> _baseTripsByUserId = {_defaultUserId: 83};
  final Map<String, int> _reviewsByUserId = {_defaultUserId: 42};

  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  Passenger? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  int get currentBaseTripsCount {
    final userId = _currentUser?.id;
    if (userId == null) return 0;
    return _baseTripsByUserId[userId] ?? 0;
  }

  int get currentReviewsCount {
    final userId = _currentUser?.id;
    if (userId == null) return 0;
    return _reviewsByUserId[userId] ?? 0;
  }

  Future<void> login(String phone) async {
    final normalized = _normalizePhone(phone);

    if (normalized.length < 11) {
      _state = AuthState.error;
      _errorMessage = 'Введите корректный номер телефона';
      notifyListeners();
      return;
    }

    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    // Имитируем POST /api/auth/login
    await Future.delayed(const Duration(milliseconds: 800));

    final user = mockUsers[normalized];
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      _state = AuthState.success;
    } else {
      _state = AuthState.error;
      _errorMessage = 'Пользователь не найден.\nПопробуйте: +7 999 123-45-67';
    }
    notifyListeners();
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final normalized = _normalizePhone(phone);
    final first = firstName.trim();
    final last = lastName.trim();

    if (first.isEmpty || last.isEmpty) {
      _state = AuthState.error;
      _errorMessage = 'Введите имя и фамилию';
      notifyListeners();
      return false;
    }

    if (normalized.length < 11) {
      _state = AuthState.error;
      _errorMessage = 'Введите корректный номер телефона';
      notifyListeners();
      return false;
    }

    if (mockUsers.containsKey(normalized)) {
      _state = AuthState.error;
      _errorMessage = 'Пользователь с таким номером уже существует';
      notifyListeners();
      return false;
    }

    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final userId = _nextPassengerId();
    final user = Passenger(
      id: userId,
      name: '$first $last',
      phone: normalized,
      mail: '$userId@vaib.local',
      rating: 0.0,
      registeredAt: DateTime.now(),
      isStudent: false,
    );

    mockUsers[normalized] = user;
    _baseTripsByUserId[userId] = 0;
    _reviewsByUserId[userId] = 0;

    _currentUser = user;
    _isLoggedIn = true;
    _state = AuthState.success;
    notifyListeners();
    return true;
  }

  String? updateCurrentUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) {
    final user = _currentUser;
    if (user == null) {
      return 'Пользователь не авторизован';
    }

    final first = firstName.trim();
    final last = lastName.trim();
    final normalized = _normalizePhone(phone);

    if (first.isEmpty || last.isEmpty) {
      return 'Имя и фамилия не должны быть пустыми';
    }

    if (normalized.length < 11) {
      return 'Введите корректный номер телефона';
    }

    final existedUser = mockUsers[normalized];
    if (existedUser != null && existedUser.id != user.id) {
      return 'Этот номер уже используется другим пользователем';
    }

    final previousPhoneKey = _findPhoneKeyByUserId(user.id);
    if (previousPhoneKey != null && previousPhoneKey != normalized) {
      mockUsers.remove(previousPhoneKey);
    }

    user.name = '$first $last';
    user.phone = normalized;
    mockUsers[normalized] = user;

    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    _state = AuthState.idle;
    _errorMessage = '';
    notifyListeners();
  }

  void resetError() {
    if (_state == AuthState.error) {
      _state = AuthState.idle;
      _errorMessage = '';
      notifyListeners();
    }
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  String _nextPassengerId() {
    final usedIds = mockUsers.values.map((user) => user.id).toSet();
    var index = 1;
    while (usedIds.contains('p$index')) {
      index++;
    }
    return 'p$index';
  }

  String? _findPhoneKeyByUserId(String userId) {
    for (final entry in mockUsers.entries) {
      if (entry.value.id == userId) {
        return entry.key;
      }
    }
    return null;
  }
}