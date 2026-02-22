import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 0)
class UserPreferences {
  @HiveField(0)
  String? userName;

  @HiveField(1)
  bool isFirstLaunch;

  UserPreferences({this.userName, this.isFirstLaunch = true});
}
