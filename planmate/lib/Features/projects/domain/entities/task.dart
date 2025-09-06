
// =====================================================
// features/projects/domain/entities/task.dart
// =====================================================

enum TaskPriority { high, medium, low }

class Task {
  final String id; // may be '' before persisted
  final String title;
  final String? description;
  final bool isDone;
  final String projectId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final TaskPriority priority;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.isDone,
    required this.projectId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.priority = TaskPriority.medium,
  });

  factory Task.newTask({
    required String title,
    required String projectId,
    required String userId,
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) {
    final now = DateTime.now();
    return Task(
      id: '',
      title: title.trim(),
      description: description?.trim(),
      isDone: false,
      projectId: projectId,
      userId: userId,
      createdAt: now,
      updatedAt: null,
      dueDate: dueDate,
      completedAt: null,
      priority: priority,
    );
  }

  // Validation
  bool get isValid =>
      title.trim().isNotEmpty && projectId.isNotEmpty && userId.isNotEmpty;

  String? validateTitle() {
    final t = title.trim();
    if (t.isEmpty) return 'Task title is required';
    if (t.length > 100) return 'Task title is too long (max 100)';
    return null;
  }

  String? validateDescription() {
    final d = description?.trim();
    if (d != null && d.length > 500) return 'Description too long (max 500)';
    return null;
  }

  // Helpers
  bool get hasDescription => (description?.trim().isNotEmpty ?? false);
  bool get hasDueDate => dueDate != null;
  bool get isOverdue => dueDate != null && !isDone && DateTime.now().isAfter(dueDate!);

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return now.year == dueDate!.year && now.month == dueDate!.month && now.day == dueDate!.day;
  }

  String get priorityText => switch (priority) {
        TaskPriority.high => 'High',
        TaskPriority.medium => 'Medium',
        TaskPriority.low => 'Low',
      };

  String get statusText => isDone ? 'Completed' : 'Pending';

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    String? projectId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? completedAt,
    TaskPriority? priority,
  }) => Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isDone: isDone ?? this.isDone,
        projectId: projectId ?? this.projectId,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        dueDate: dueDate ?? this.dueDate,
        completedAt: completedAt ?? this.completedAt,
        priority: priority ?? this.priority,
      );

  Task toggleComplete({DateTime? now}) {
    final t = now ?? DateTime.now();
    return isDone
        ? copyWith(isDone: false, completedAt: null, updatedAt: t)
        : copyWith(isDone: true, completedAt: t, updatedAt: t);
  }

  Task updateInfo({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    DateTime? now,
  }) {
    final t = now ?? DateTime.now();
    return copyWith(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      updatedAt: t,
    );
  }

  @override
  String toString() => 'Task(id: $id, title: $title, isDone: $isDone, projectId: $projectId)';

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Task && other.id == id);
  @override
  int get hashCode => id.hashCode;
}














// =====================================================
// wiring example (put in a setup/di file or in Provider setup)
// =====================================================

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'features/projects/data/datasources/task_remote_ds.dart';
import 'features/projects/data/repositories/task_repository_impl.dart';
import 'features/projects/domain/usecases/create_task.dart';
import 'features/projects/domain/usecases/watch_tasks_by_project.dart';
import 'features/projects/domain/usecases/toggle_complete.dart';
import 'features/projects/domain/usecases/update_task.dart';
import 'features/projects/domain/usecases/delete_task.dart';
import 'features/projects/domain/usecases/delete_all_project_tasks.dart';
import 'features/projects/domain/usecases/get_task_stats.dart';
import 'features/projects/presentation/controllers/task_controller.dart';

MultiProvider(
  providers: [
    Provider((_) => FirebaseFirestore.instance),
    Provider((_) => FirebaseAuth.instance),
    Provider((ctx) => TaskRemoteDataSource(ctx.read<FirebaseFirestore>(), ctx.read<FirebaseAuth>())),
    Provider((ctx) => TaskRepositoryImpl(ctx.read<TaskRemoteDataSource>())),

    // UseCases
    Provider((ctx) => CreateTask(ctx.read<TaskRepositoryImpl>())),
    Provider((ctx) => WatchTasksByProject(ctx.read<TaskRepositoryImpl>())),
    Provider((ctx) => ToggleTaskComplete(ctx.read<TaskRepositoryImpl>())),
    Provider((ctx) => UpdateTask(ctx.read<TaskRepositoryImpl>())),
    Provider((ctx) => DeleteTask(ctx.read<TaskRepositoryImpl>())),
    Provider((ctx) => DeleteAllProjectTasks(ctx.read<TaskRepositoryImpl>())),
    Provider((ctx) => GetTaskStats(ctx.read<TaskRepositoryImpl>())),

    ChangeNotifierProvider((ctx) => TaskController(
          createTask: ctx.read<CreateTask>(),
          watch: ctx.read<WatchTasksByProject>(),
          toggle: ctx.read<ToggleTaskComplete>(),
          update: ctx.read<UpdateTask>(),
          delete: ctx.read<DeleteTask>(),
          deleteAll: ctx.read<DeleteAllProjectTasks>(),
          stats: ctx.read<GetTaskStats>(),
        )),
  ],
  child: const App(),
);
*/


// =====================================================
// Notes & Migration
// =====================================================
// 1) วางไฟล์ตาม path ด้านบน (core/, domain/, data/, presentation/)
// 2) UI ควรคุยกับ TaskController (ไม่คุย Firestore ตรง)
// 3) เมื่อเจอ error จาก Firestore เช่น need index หรือ missing field 'createdAt':
//    - สร้าง index ตามลิงก์ error ที่ Firestore แจ้ง หรือ
//    - ให้ทุกเอกสารมี 'createdAt' ครบก่อน แล้วค่อยเปิด .orderBy('createdAt') ใน data source
// 4) createdAt/updatedAt ใช้ serverTimestamp เพื่อกันเวลาเครื่องเพี้ยน
// 5) ถ้าต้องการ Riverpod/Bloc สามารถย้าย TaskController เป็น StateNotifier/Cubit ได้ไม่กระทบ layers
