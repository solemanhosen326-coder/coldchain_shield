import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_chart_model.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_charts_service.dart';
import 'package:flutter/foundation.dart';



class AnalyticsChartsProvider extends ChangeNotifier {
  final AnalyticsChartsService _service =
      AnalyticsChartsService();

  AnalyticsChartModel _charts =
      AnalyticsChartModel.empty();

  AnalyticsChartModel get charts => _charts;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadCharts(
    String companyId,
  ) async {
    _isLoading = true;

    notifyListeners();

    _charts = await _service.loadCharts(companyId);

    _isLoading = false;

    notifyListeners();
  }

  void clear() {
    _charts = AnalyticsChartModel.empty();

    notifyListeners();
  }
}