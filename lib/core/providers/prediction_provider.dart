import 'package:flutter/foundation.dart';

import '../services/service_locator.dart';

class PredictionProvider with ChangeNotifier {
  List<Map<String, dynamic>> _predictionData = [];
  List<Map<String, dynamic>> _predictionFactors = [];
  
  double _currentPrice = 0;
  double _predictedPrice = 0;
  double _predictedChangePercentage = 0;
  
  bool _isLoading = false;
  
  List<Map<String, dynamic>> get predictionData => _predictionData;
  List<Map<String, dynamic>> get predictionFactors => _predictionFactors;
  
  double get currentPrice => _currentPrice;
  double get predictedPrice => _predictedPrice;
  double get predictedChangePercentage => _predictedChangePercentage;
  
  bool get isLoading => _isLoading;
  
  Future<void> generatePrediction(String product, String market, String timeframe) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await serviceLocator.apiService.predictPrice(product, market, timeframe);
      
      _predictionData = List<Map<String, dynamic>>.from(result['predictionData'] ?? []);
      _predictionFactors = List<Map<String, dynamic>>.from(result['factors'] ?? []);
      
      _currentPrice = result['currentPrice']?.toDouble() ?? 0;
      _predictedPrice = result['predictedPrice']?.toDouble() ?? 0;
      
      if (_currentPrice > 0) {
        _predictedChangePercentage = ((_predictedPrice - _currentPrice) / _currentPrice) * 100;
      } else {
        _predictedChangePercentage = 0;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  void reset() {
    _predictionData = [];
    _predictionFactors = [];
    _currentPrice = 0;
    _predictedPrice = 0;
    _predictedChangePercentage = 0;
    notifyListeners();
  }
}

