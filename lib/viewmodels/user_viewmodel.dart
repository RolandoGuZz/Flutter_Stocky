import 'package:flutter/foundation.dart';
import '../services/hive_service.dart';

class UserViewModel extends ChangeNotifier {
  final HiveService _hiveService;
  String? _userName;
  bool _isFirstLaunch = true;

  String? get userName => _userName;
  bool get isFirstLaunch => _isFirstLaunch;

  UserViewModel({required HiveService hiveService})
    : _hiveService = hiveService {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userName = _hiveService.getUserName();
    _isFirstLaunch = _hiveService.isFirstLaunch();
    notifyListeners();
  }

  Future<void> saveUserName(String name) async {
    await _hiveService.saveUserName(name);
    _userName = name;
    _isFirstLaunch = false;
    notifyListeners();
  }
}
