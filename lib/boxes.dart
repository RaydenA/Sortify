import 'package:hive/hive.dart';
import 'Model/basket.dart';

class Boxes {
  static Box<Basket> getBasket() => Hive.box<Basket>('basket');
}
