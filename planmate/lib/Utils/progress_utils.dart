import 'package:planmate/Utils/date_utils.dart';
import 'package:planmate/models/daily_progress_model.dart';
import 'package:planmate/models/task_model.dart';


List<DailyProgress> generateWeeklyData(List<TaskModel> tasks) {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

  List<DailyProgress> data = [];

  for (int i = 0; i < 7; i++) {
    final date = startOfWeek.add(Duration(days: i));
    final dayName = _getDayName(i);

    int planned = 0;
    int completed = 0;

    for (final task in tasks) {
      if (task.hasDueDate && task.dueDate!.isSameDay(date)) {
        planned++;
        if (task.isDone) completed++;
      } else if (!task.hasDueDate && task.createdAt.isSameDay(date)) {
        planned++;
        if (task.isDone) completed++;
      }
    }

    data.add(
      DailyProgress(
        day: dayName,
        dayIndex: i,
        planned: planned.toDouble(),
        completed: completed.toDouble(),
        date: date,
      ),
    );
  }

  return data;
}

List<DailyProgress> getSampleData() {
  return [
    DailyProgress(day: 'Mo', dayIndex: 0, planned: 4, completed: 3, date: DateTime.now()),
    DailyProgress(day: 'Tu', dayIndex: 1, planned: 3, completed: 2, date: DateTime.now()),
    DailyProgress(day: 'We', dayIndex: 2, planned: 5, completed: 4, date: DateTime.now()),
    DailyProgress(day: 'Th', dayIndex: 3, planned: 2, completed: 2, date: DateTime.now()),
    DailyProgress(day: 'Fr', dayIndex: 4, planned: 6, completed: 4, date: DateTime.now()),
    DailyProgress(day: 'Sa', dayIndex: 5, planned: 3, completed: 1, date: DateTime.now()),
    DailyProgress(day: 'Su', dayIndex: 6, planned: 2, completed: 1, date: DateTime.now()),
  ];
}

String _getDayName(int index) {
  const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  return days[index];
}
