import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _userId = '';
  String _username = '';

  String get userId => _userId;
  String get username => _username;

  void setUserInfo(String id, String name) {
    _userId = id;
    _username = name;
    notifyListeners();
  }
}
