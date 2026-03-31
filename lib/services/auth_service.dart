// services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLoginTime = 'login_time';

  // Simpan data login setelah sukses
  Future<void> saveLoginData(String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyLoginTime, DateTime.now().millisecondsSinceEpoch);
  }

  // Ambil data login yang tersimpan
  Future<Map<String, dynamic>?> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (!isLoggedIn) return null;

    return {
      'userId': prefs.getString(_keyUserId),
      'email': prefs.getString(_keyUserEmail),
      'loginTime': prefs.getInt(_keyLoginTime),
    };
  }

  // Cek status login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Logout - hapus semua data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyLoginTime);
  }

  // Opsional: Auto logout setelah beberapa waktu (misal 7 hari)
  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(_keyLoginTime);

    if (loginTime == null) return false;

    const sevenDaysInMillis = 7 * 24 * 60 * 60 * 1000;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    return (currentTime - loginTime) < sevenDaysInMillis;
  }
}