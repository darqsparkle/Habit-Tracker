// import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:habbit_tracker/models/app_settings.dart';
import 'package:habbit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [HabbitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  Future<void> saveFirstLauncheDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  final List<Habbit> currentHabits = [];

  Future<void> addHabit(String habitName) async {
    final newHabit = Habbit()..name = habitName;

    await isar.writeTxn(() => isar.habbits.put(newHabit));

    readHabits();
  }

  Future<void> readHabits() async {
    List<Habbit> fetchedHabits = await isar.habbits.where().findAll();

    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    notifyListeners();
  }

  Future<void> updateHabitCompletetion(int id, bool isCompleted) async {
    final habit = await isar.habbits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          final today = DateTime.now();

          habit.completedDays.add(DateTime(
            today.year,
            today.month,
            today.day,
          ));
        } else {
          habit.completedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }
        await isar.habbits.put(habit);
      });
    }

    readHabits();
  }

  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habbits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;

        await isar.habbits.put(habit);
      });
    }

    readHabits();
  }

  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habbits.delete(id);
    });

    readHabits();
  }
}
