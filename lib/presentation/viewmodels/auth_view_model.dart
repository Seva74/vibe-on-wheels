import 'package:flutter/foundation.dart';
import '../../domain/entities/passenger.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthState _state = AuthState.idle;
  String _errorMessage = '';
  Passenger? _currentUser;
  bool _isLoggedIn = false;

  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  Passenger? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;


  static final Map<String, Passenger> _mockUsers = {
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

  Future<void> login(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (normalized.length < 11) {
      _state = AuthState.error;
      _errorMessage = 'Введите корректный номер телефона';
      notifyListeners();
      return;
    }

    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final user = _mockUsers[normalized];
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      _state = AuthState.success;
    } else {
      _state = AuthState.error;
      _errorMessage = 'Пользователь с таким номером не найден.\nПопробуйте: +7 999 123-45-67';
    }
    notifyListeners();
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
}