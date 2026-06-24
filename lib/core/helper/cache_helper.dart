import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;
  CacheHelper._internal();
  static final CacheHelper _instance = CacheHelper._internal();
  factory CacheHelper() => _instance;

  Future<SharedPreferences> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences;
  }

  Future<bool> saveData({required String key, required value}) async {
    if (value is int) {
      return await sharedPreferences.setInt(key, value);
    } else if (value is String) {
      return await sharedPreferences.setString(key, value);
    } else if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    } else if (value is double) {
      return await sharedPreferences.setDouble(key, value);
    } else {
      return await sharedPreferences.setStringList(key, value);
    }
  }

  Object? getData(String key) => sharedPreferences.get(key);

  Future<bool> removeData(String key) async =>
      await sharedPreferences.remove(key);
}

// class ObjectBoxServices {
//   late final Store store;
//   late final Box<TripDetailsModel> detailsBox;
//   late final Box<RouteModel> routeBox;
//   late final Box<StationModel> stationsBox;

//   Future<void> init() async {
//     store = await openStore();
//     detailsBox = store.box<TripDetailsModel>();
//     routeBox = store.box<RouteModel>();
//     stationsBox = store.box<StationModel>();
//   }
// }
