class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  // Default kosong → supaya hanya terisi ketika user memilih ESP32
  String esp32Ip = '';
}
