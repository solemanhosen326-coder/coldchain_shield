import 'package:flutter/foundation.dart';

import 'models/analytics_model.dart';
import 'services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _service = AnalyticsService();

  AnalyticsModel _analytics = AnalyticsModel.empty();
  AnalyticsModel get analytics => _analytics;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadAnalytics(String companyId) async {
    _isLoading = true;
    notifyListeners();

    _analytics = await _service.loadAnalytics(companyId);

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _analytics = AnalyticsModel.empty();
    notifyListeners();
  }
}