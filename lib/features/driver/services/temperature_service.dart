abstract class TemperatureService {
  void Function(double temperature)? onTemperatureChanged;

  Future<void> start();

  Future<void> stop();
}