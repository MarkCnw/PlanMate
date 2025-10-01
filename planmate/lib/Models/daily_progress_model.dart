class DailyProgress {
  final String day;
  final int dayIndex;
  final double planned;
  final double completed;
  final DateTime date;

  const DailyProgress({
    required this.day,
    required this.dayIndex,
    required this.planned,
    required this.completed,
    required this.date,
  });
}
