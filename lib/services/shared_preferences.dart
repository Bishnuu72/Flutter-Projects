import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  late SharedPreferences prefs;

  Future<void> initSharedPrefs() async =>
      prefs = await SharedPreferences.getInstance();

  void setString(String key, String value) async {
    await initSharedPrefs();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await initSharedPrefs();
    return prefs.getString(key);
  }
}

final SharedPrefsService sharedPrefs = SharedPrefsService();