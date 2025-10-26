import 'package:hive/hive.dart';
part 'data.g.dart';

class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  // IP ESP32 (hardcoded)
  String esp32Ip = '192.168.31.114';
}

@HiveType(typeId: 0)
class ColorSet extends HiveObject{
  @HiveField(0)
  String name = "";

  @HiveField(1)
  List<int> redAvgs = [];

  @HiveField(2)
  List<int> greenAvgs = [];

  @HiveField(3)
  List<int> blueAvgs = [];
}



