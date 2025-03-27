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
      final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
      final ConnectivityResult result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectionStatus([result]);
    } catch (e) {
      _isConnected = false;
    }
  }
  
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }
  
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isConnected = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
    notifyListeners();
  }
}

