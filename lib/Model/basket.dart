import 'package:hive/hive.dart';

part 'basket.g.dart';

@HiveType(typeId: 0)
class Basket extends HiveObject {
  @HiveField(0)
  late String name;
  @HiveField(1)
  List<int> redAvgsA = [];
  @HiveField(2)
  List<int> greenAvgsA = [];
  @HiveField(3)
  List<int> blueAvgsA = [];
  @HiveField(4)
  List<int> redAvgsB = [];
  @HiveField(5)
  List<int> greenAvgsB = [];
  @HiveField(6)
  List<int> blueAvgsB = [];
}
