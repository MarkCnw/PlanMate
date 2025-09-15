class ProjectOption {
  final String? id;
  final String title;

  ProjectOption({this.id, required this.title});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() => title;
}