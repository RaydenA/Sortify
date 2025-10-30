class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  // IP ESP32 (hardcoded)
  String esp32Ip = '192.168.31.114';
}





