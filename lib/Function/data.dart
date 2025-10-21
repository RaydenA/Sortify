// data.dart
class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  // IP ESP32 (hardcoded)
  String esp32Ip = '10.234.21.234';

  // List warna rata-rata
  List<int> redAvgs = [];
  List<int> greenAvgs = [];
  List<int> blueAvgs = [];
}

