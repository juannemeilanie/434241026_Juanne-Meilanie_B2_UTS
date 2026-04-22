import 'package:flutter/foundation.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  void restoreSession() {
    try {
      _currentUser = LocalStorageService.getLoggedInUser();
    } catch (_) {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    final user =
    LocalStorageService.getUserByEmail(email.trim().toLowerCase());

    if (user == null) {
      _setError('Email tidak terdaftar');
      return false;
    }

    if (user.password != password) {
      _setError('Password salah');
      return false;
    }

    _currentUser = user;
    await LocalStorageService.saveLoggedInUserId(user.id);

    _setLoading(false);
    return true;
  }

  Future<bool> register(
      String name,
      String email,
      String password,
      ) async {
    _setLoading(true);

    final existing =
    LocalStorageService.getUserByEmail(email.trim().toLowerCase());

    if (existing != null) {
      _setError('Email sudah terdaftar');
      return false;
    }

    final newUser = UserModel(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      role: 'user',
    );

    await LocalStorageService.addUser(newUser);

    _currentUser = newUser;
    await LocalStorageService.saveLoggedInUserId(newUser.id);

    _setLoading(false);
    return true;
  }

  Future<void> createUserByAdmin({
    required String name,
    required String email,
    required String password,
    required String role, // 'helpdesk' | 'admin'
  }) async {
    final newUser = UserModel(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      role: role,
    );

    await LocalStorageService.addUser(newUser);
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);

    final exists =
        LocalStorageService.getUserByEmail(email.trim()) != null;

    _setLoading(false);
    return exists;
  }

  Future<void> updateProfile(String name) async {
    if (_currentUser == null) return;

    final updated = _currentUser!.copyWith(name: name.trim());
    await LocalStorageService.updateUser(updated);

    _currentUser = updated;
    notifyListeners();
  }

  Future<void> logout() async {
    await LocalStorageService.clearLoggedInUser();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}