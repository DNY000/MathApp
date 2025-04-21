import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPrefs? _instance;
  static SharedPreferences? _prefs;

  SharedPrefs._();

  static SharedPrefs get instance {
    _instance ??= SharedPrefs._();
    return _instance!;
  }

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> saveData<T>(String key, T value) async {
    if (_prefs == null) return false;

    switch (T) {
      case String:
        return await _prefs!.setString(key, value as String);
      case int:
        return await _prefs!.setInt(key, value as int);
      case double:
        return await _prefs!.setDouble(key, value as double);
      case bool:
        return await _prefs!.setBool(key, value as bool);
      case const (List<String>):
        return await _prefs!.setStringList(key, value as List<String>);
      default:
        // For complex objects, convert to JSON string
        if (value != null) {
          return await _prefs!.setString(key, json.encode(value));
        }
        return false;
    }
  }

  // Generic method to get data
  T? getData<T>(String key) {
    if (_prefs == null) return null;

    switch (T) {
      case String:
        return _prefs!.getString(key) as T?;
      case int:
        return _prefs!.getInt(key) as T?;
      case double:
        return _prefs!.getDouble(key) as T?;
      case bool:
        return _prefs!.getBool(key) as T?;
      case const (List<String>):
        return _prefs!.getStringList(key) as T?;
      default:
        // For complex objects, decode from JSON string
        final String? jsonString = _prefs!.getString(key);
        if (jsonString != null) {
          return json.decode(jsonString) as T?;
        }
        return null;
    }
  }

  // Generic method to save object
  Future<bool> saveObject<T>(
    String key,
    T value,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (_prefs == null) return false;

    try {
      final String jsonString = json.encode(value);
      return await _prefs!.setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }

  // Generic method to get object
  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    if (_prefs == null) return null;

    try {
      final String? jsonString = _prefs!.getString(key);
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return fromJson(jsonMap);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Remove data
  Future<bool> removeData(String key) async {
    if (_prefs == null) return false;
    return await _prefs!.remove(key);
  }

  // Clear all data
  Future<bool> clearAll() async {
    if (_prefs == null) return false;
    return await _prefs!.clear();
  }

  // Check if key exists
  bool hasKey(String key) {
    if (_prefs == null) return false;
    return _prefs!.containsKey(key);
  }
}
