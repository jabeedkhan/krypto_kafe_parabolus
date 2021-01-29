import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class KryptoSharedPreferences {
  static final KryptoSharedPreferences _instance =
      KryptoSharedPreferences._ctor();

  factory KryptoSharedPreferences() {
    return _instance;
  }
  KryptoSharedPreferences._ctor();

  SharedPreferences preferences;

  Future setString(String key, String value) async {
    preferences = await SharedPreferences.getInstance();
    return preferences.setString(key, value);
  }

  Future<String> getString(String key) async {
    preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

   read(String key) async {
     preferences = await SharedPreferences.getInstance();
    return json.decode(preferences.getString(key));
  }

 Future<bool> save(String key, value) async {
     preferences = await SharedPreferences.getInstance();
   return preferences.setString(key, json.encode(value));
  }

  remove(String key) async {
     preferences = await SharedPreferences.getInstance();
    preferences.remove(key);
  }

 

  clearAll() {
    return preferences.clear();
  }
}
