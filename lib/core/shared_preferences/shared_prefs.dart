import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lớp quản lý SharedPreferences với Singleton pattern
class SharedPrefs {
  // Singleton instance
  static SharedPrefs? _instance;
  static SharedPreferences? _prefs;

  // Cache để tối ưu performance
  final Map<String, dynamic> _cache = {};

  // Private constructor
  SharedPrefs._();

  /// Khởi tạo SharedPreferences
  static Future<SharedPrefs> initialize() async {
    if (_instance == null) {
      _instance = SharedPrefs._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  /// Getter để truy cập instance
  static SharedPrefs get instance {
    if (_instance == null) {
      throw StateError(
        'SharedPrefs chưa được khởi tạo. Hãy gọi initialize() trước.',
      );
    }
    return _instance!;
  }

  /// Lưu dữ liệu với kiểu generic
  Future<bool> save<T>(String key, T value) async {
    try {
      // Cập nhật cache
      _cache[key] = value;

      // Lưu xuống SharedPreferences
      if (_prefs == null) return false;

      switch (T) {
        case Type _ when T == String:
          return await _prefs!.setString(key, value as String);
        case Type _ when T == int:
          return await _prefs!.setInt(key, value as int);
        case Type _ when T == double:
          return await _prefs!.setDouble(key, value as double);
        case Type _ when T == bool:
          return await _prefs!.setBool(key, value as bool);
        case Type _ when T == List<String>:
          return await _prefs!.setStringList(key, value as List<String>);
        default:
          if (value != null) {
            final String jsonString = json.encode(value);
            return await _prefs!.setString(key, jsonString);
          }
          return false;
      }
    } catch (e) {
      _cache.remove(key); // Xóa khỏi cache nếu lưu thất bại
      return false;
    }
  }

  /// Lấy dữ liệu với kiểu generic
  T? get<T>(String key) {
    try {
      // Kiểm tra cache trước
      if (_cache.containsKey(key)) {
        final value = _cache[key];
        if (value is T) return value;
      }

      // Nếu không có trong cache, lấy từ SharedPreferences
      if (_prefs == null) return null;

      switch (T) {
        case Type _ when T == String:
          final value = _prefs!.getString(key);
          if (value != null) _cache[key] = value;
          return value as T?;
        case Type _ when T == int:
          final value = _prefs!.getInt(key);
          if (value != null) _cache[key] = value;
          return value as T?;
        case Type _ when T == double:
          final value = _prefs!.getDouble(key);
          if (value != null) _cache[key] = value;
          return value as T?;
        case Type _ when T == bool:
          final value = _prefs!.getBool(key);
          if (value != null) _cache[key] = value;
          return value as T?;
        case Type _ when T == List<String>:
          final value = _prefs!.getStringList(key);
          if (value != null) _cache[key] = value;
          return value as T?;
        default:
          final jsonString = _prefs!.getString(key);
          if (jsonString != null) {
            final value = json.decode(jsonString);
            _cache[key] = value;
            return value as T?;
          }
          return null;
      }
    } catch (e) {
      _cache.remove(key); // Xóa khỏi cache nếu có lỗi
      return null;
    }
  }

  /// Lưu object với fromJson function
  Future<bool> saveObject<T>(
    String key,
    T value,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final String jsonString = json.encode(value);
      _cache[key] = value; // Cập nhật cache
      return await _prefs?.setString(key, jsonString) ?? false;
    } catch (e) {
      _cache.remove(key);
      return false;
    }
  }

  /// Lấy object với fromJson function
  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      // Kiểm tra cache trước
      if (_cache.containsKey(key)) {
        final value = _cache[key];
        if (value is T) return value;
      }

      // Nếu không có trong cache, lấy từ SharedPreferences
      final jsonString = _prefs?.getString(key);
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        final value = fromJson(jsonMap);
        _cache[key] = value; // Cập nhật cache
        return value;
      }
    } catch (e) {
      _cache.remove(key);
    }
    return null;
  }

  /// Xóa dữ liệu theo key
  Future<bool> remove(String key) async {
    _cache.remove(key); // Xóa khỏi cache
    return await _prefs?.remove(key) ?? false;
  }

  /// Xóa tất cả dữ liệu
  Future<bool> clear() async {
    _cache.clear(); // Xóa cache
    return await _prefs?.clear() ?? false;
  }

  /// Kiểm tra key tồn tại
  bool hasKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// Lấy tất cả keys
  Set<String> getKeys() {
    return _prefs?.getKeys() ?? {};
  }

  /// Reload dữ liệu từ disk
  Future<void> reload() async {
    await _prefs?.reload();
    _cache.clear(); // Xóa cache để load lại data mới
  }
}
