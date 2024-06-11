import 'package:isar/isar.dart';

part 'habit.g.dart';

@Collection()
class Habbit {
  Id id = Isar.autoIncrement;

  late String name;

  List<DateTime> completedDays = [];
}
