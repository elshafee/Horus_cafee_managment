import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  // Box names
  static const String _userBoxName = 'userBox';
  static const String _settingsBoxName = 'settingsBox';
  static const String _ordersBoxName = 'ordersBox';

  late Box _userBox;
  late Box _settingsBox;
  late Box _ordersBox;

  /// Initialize all Hive boxes
  Future<void> init() async {
    _userBox = await Hive.openBox(_userBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _ordersBox = await Hive.openBox(_ordersBoxName);
  }

  // --- Auth & User Storage ---

  /// Save user data as a Map
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _userBox.put('current_user', userData);
  }

  /// Get saved user data
  Map<String, dynamic>? getUser() {
    final data = _userBox.get('current_user');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Delete user data on logout
  Future<void> clearUser() async {
    await _userBox.delete('current_user');
  }

  // --- App Settings ---

  /// Save app settings (e.g., Theme mode, IP address override)
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get app setting
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  // --- Offline Orders Storage ---

  /// Cache orders for offline viewing
  Future<void> cacheOrders(List<Map<String, dynamic>> orders) async {
    await _ordersBox.put('cached_orders', orders);
  }

  /// Get cached orders
  List<Map<String, dynamic>> getCachedOrders() {
    final data = _ordersBox.get('cached_orders');
    if (data == null) return [];
    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Clear all local data
  Future<void> clearAll() async {
    await _userBox.clear();
    await _settingsBox.clear();
    await _ordersBox.clear();
  }
}
