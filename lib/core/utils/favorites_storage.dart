import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const String _keyFavoriteDepartments = 'favorite_department_ids';

  static Future<List<String>> getFavoriteDepartmentIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavoriteDepartments) ?? <String>[];
  }

  static Future<void> setFavoriteDepartmentIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavoriteDepartments, ids);
  }

  static Future<bool> toggleFavoriteDepartment(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keyFavoriteDepartments) ?? <String>[];
    if (current.contains(id)) {
      current.remove(id);
      await prefs.setStringList(_keyFavoriteDepartments, current);
      return false;
    } else {
      current.add(id);
      await prefs.setStringList(_keyFavoriteDepartments, current);
      return true;
    }
  }
}


