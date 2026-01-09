import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static SharedPreferences? _prefs;
  
  static const String _historyKey = 'calculation_history';
  static const String _darkModeKey = 'dark_mode';
  static const String _hapticKey = 'haptic_enabled';
  static const String _soundKey = 'sound_enabled';
  
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  // History Methods
  static Future<bool> setHistory(List<String> history) {
    return _prefs!.setStringList(_historyKey, history);
  }
  
  static List<String> getHistory() {
    return _prefs?.getStringList(_historyKey) ?? [];
  }
  
  static Future<bool> addToHistory(String entry) async {
    final history = getHistory();
    history.add(entry);
    // Keep only last 100 entries
    if (history.length > 100) {
      history.removeAt(0);
    }
    return setHistory(history);
  }
  
  static Future<bool> clearHistory() {
    return _prefs!.remove(_historyKey);
  }
  
  static Future<bool> removeHistoryAt(int index) async {
    final history = getHistory();
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      return setHistory(history);
    }
    return false;
  }
  
  // Theme Methods
  static Future<bool> setDarkMode(bool isDark) {
    return _prefs!.setBool(_darkModeKey, isDark);
  }
  
  static bool isDarkMode() {
    return _prefs?.getBool(_darkModeKey) ?? false;
  }
  
  // Settings Methods
  static Future<bool> setHapticEnabled(bool enabled) {
    return _prefs!.setBool(_hapticKey, enabled);
  }
  
  static bool isHapticEnabled() {
    return _prefs?.getBool(_hapticKey) ?? true;
  }
  
  static Future<bool> setSoundEnabled(bool enabled) {
    return _prefs!.setBool(_soundKey, enabled);
  }
  
  static bool isSoundEnabled() {
    return _prefs?.getBool(_soundKey) ?? false;
  }
}
