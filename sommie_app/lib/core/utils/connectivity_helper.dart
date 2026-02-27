import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static Future<bool> hasInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<void> checkConnection() async {
    if (!await hasInternet()) {
      throw Exception(
        'Sem conexão com a internet. Verifique sua rede.\n\n'
        'No internet connection. Please check your network.'
      );
    }
  }
}