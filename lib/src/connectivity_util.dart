import 'package:connectivity_plus/connectivity_plus.dart';

///
abstract final class ConnectivityUtil {
  ///
  Connectivity get connectivity => Connectivity();

  ///
  static Future<bool> isInternetAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.any(
      (element) => element != ConnectivityResult.none,
    );
  }
}
