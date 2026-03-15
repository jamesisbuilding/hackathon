import 'package:shared_preferences/shared_preferences.dart';

class UserState {
  UserState._();

  static String? _uid;
  static const _uidKey = 'user_uid';

  static String? get uid => _uid;

  static set uid(String? value) {
    final normalized =
        value?.trim().isEmpty == true ? null : value?.trim();
    _uid = normalized;
    _persistUid(normalized);
  }

  static Future<void> _persistUid(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_uidKey);
    } else {
      await prefs.setString(_uidKey, value);
    }
  }

  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_uidKey);
    _uid = stored;
  }
}

