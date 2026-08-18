import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static const String _passwordKey = 'user_password';
  static const String _fingerprintKey = 'fingerprint_enabled';

  final LocalAuthentication _localAuth = LocalAuthentication();

  // ===== ذخیره رمز عبور =====
  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, password);
  }

  // ===== دریافت رمز عبور =====
  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  // ===== بررسی وجود رمز =====
  Future<bool> hasPassword() async {
    final pass = await getPassword();
    return pass != null && pass.isNotEmpty;
  }

  // ===== وریفای رمز =====
  Future<bool> verifyPassword(String input) async {
    final saved = await getPassword();
    return saved == input;
  }

  // ===== حذف رمز =====
  Future<void> removePassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordKey);
  }

  // ===== فعال/غیرفعال کردن اثر انگشت =====
  Future<void> setFingerprintEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fingerprintKey, enabled);
  }

  // ===== وضعیت اثر انگشت =====
  Future<bool> isFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fingerprintKey) ?? false;
  }

  // ===== بررسی قابلیت اثر انگشت =====
  Future<bool> isFingerprintAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      return isAvailable;
    } catch (e) {
      return false;
    }
  }

  // ===== احراز هویت با اثر انگشت =====
  Future<bool> authenticateWithFingerprint() async {
    try {
      final isAvailable = await isFingerprintAvailable();
      if (!isAvailable) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'برای دسترسی به برنامه، اثر انگشت خود را قرار دهید',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  // ===== احراز هویت با رمز (و اثر انگشت به‌عنوان جایگزین) =====
  Future<bool> authenticate({
    required BuildContext context,
    required String enteredPassword,
  }) async {
    // اگر رمز نداریم
    if (!await hasPassword()) return false;

    // اول چک کن رمز درسته
    final isPasswordValid = await verifyPassword(enteredPassword);
    if (isPasswordValid) return true;

    // اگر اثر انگشت فعال و در دسترس باشه
    final fingerprintEnabled = await isFingerprintEnabled();
    if (fingerprintEnabled && await isFingerprintAvailable()) {
      final authenticated = await authenticateWithFingerprint();
      if (authenticated) return true;
    }

    return false;
  }

  // ===== احراز هویت با اثر انگشت (بدون رمز) =====
  Future<bool> authenticateWithBiometricsOnly() async {
    if (!await isFingerprintEnabled()) return false;
    if (!await isFingerprintAvailable()) return false;
    return await authenticateWithFingerprint();
  }
}