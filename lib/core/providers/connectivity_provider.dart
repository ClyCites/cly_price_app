import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  
  bool get isConnected => _isConnected;
  
  ConnectivityProvider() {
    _initConnectivity();
    _setupConnectivityListener();
  }
  
  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _isConnected = false;
    }
  }
  
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  void _updateConnectionStatus(ConnectivityResult result) {
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }
}

