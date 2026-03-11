import 'package:flutter/foundation.dart';
import '../../domain/entities/passenger.dart';
import '../../data/mock_data.dart';

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