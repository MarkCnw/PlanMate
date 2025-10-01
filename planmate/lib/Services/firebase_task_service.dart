import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class FirebaseTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get taskRef => _firestore.collection('tasks');
  CollectionReference get projectRef => _firestore.collection('projects');

  // Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// สร้าง Task ใหม่ (Simplified version)
  Future<String> createTaskEnhanced({
    required String title,
    required String projectId,
    String? description,
    DateTime? dueDate,
    int priority = 2,
    Duration? estimatedDuration, // เก็บไว้เพื่อ compatibility แต่จะ ignore
    double initialProgress = 0.0,
  }) async {
    try {
      debugPrint('🔄 Creating task for project: $projectId');
      debugPrint(
        '📊 Initial progress: ${(initialProgress * 100).round()}%',
      );

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // ตรวจสอบว่า project นี้เป็นของ user หรือไม่
      await _verifyProjectOwnership(projectId);

      // สร้าง TaskModel แบบง่าย (ไม่มี time estimation)
      final task = TaskModel(
        id: '', // Firestore จะ generate ให้
        title: title.trim(),
        description: description?.trim(),
        isDone: initialProgress >= 1.0,
        projectId: projectId,
        userId: currentUserId!,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        priority: priority,
        progress: initialProgress,
        status: _getStatusFromProgress(initialProgress),
        startedAt: initialProgress > 0.0 ? DateTime.now() : null,
        completedAt: initialProgress >= 1.0 ? DateTime.now() : null,
      );

      debugPrint('📋 Task data: ${task.toMap()}');

      // Validate ข้อมูล
      final titleError = _validateTitle(title);
      if (titleError != null) {
        throw Exception(titleError);
      }

      final descriptionError = _validateDescription(description);
      if (descriptionError != null) {
        throw Exception(descriptionError);
      }

      // Validate progress
      if (initialProgress < 0.0 || initialProgress > 1.0) {
        throw Exception('Initial progress must be between 0 and 1');
      }

      // เริ่ม batch write เพื่อ update ทั้ง task และ project count
      final batch = _firestore.batch();

      // สร้าง task document
      final taskDocRef = taskRef.doc();
      batch.set(taskDocRef, task.toMap());

      // อัปเดต task count ใน project
      final projectDocRef = projectRef.doc(projectId);
      batch.update(projectDocRef, {
        'taskCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Execute batch
      await batch.commit();

      debugPrint('✅ Task created successfully with ID: ${taskDocRef.id}');
      return taskDocRef.id;
    } catch (e) {
      debugPrint('❌ Failed to create task: $e');
      rethrow;
    }
  }

  /// สร้าง Task แบบธรรมดา (backward compatibility)
  Future<String> createTask({
    required String title,
    required String projectId,
    String? description,
    DateTime? dueDate,
    int priority = 2,
  }) async {
    return createTaskEnhanced(
      title: title,
      projectId: projectId,
      description: description,
      dueDate: dueDate,
      priority: priority,
      estimatedDuration: null,
      initialProgress: 0.0,
    );
  }

  /// ดึง Tasks ของ Project เฉพาะ (Real-time)
  Stream<List<TaskModel>> getProjectTasks(String projectId) {
    return taskRef
        .where('projectId', isEqualTo: projectId)
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          debugPrint(
            '📦 Received ${snapshot.docs.length} tasks from Firestore',
          );

          final tasks =
              snapshot.docs
                  .map((doc) {
                    try {
                      final data = doc.data() as Map<String, dynamic>;
                      return TaskModel.fromMap(data, doc.id);
                    } catch (e) {
                      debugPrint('❌ Error parsing task ${doc.id}: $e');
                      return null;
                    }
                  })
                  .where((task) => task != null)
                  .cast<TaskModel>()
                  .toList();

          // เรียงลำดับใน Dart แทน
          tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          debugPrint('✅ Successfully parsed ${tasks.length} tasks');
          return tasks;
        });
  }

  /// อัปเดต Task status (Toggle complete)
  Future<void> toggleTaskComplete(String taskId) async {
    try {
      debugPrint('🔄 Toggling task completion: $taskId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get current task data
      final taskDoc = await taskRef.doc(taskId).get();
      if (!taskDoc.exists) {
        throw Exception('Task not found');
      }

      final taskData = taskDoc.data() as Map<String, dynamic>;

      // ตรวจสอบ ownership
      if (taskData['userId'] != currentUserId) {
        throw Exception('Not authorized to update this task');
      }

      final currentStatus = taskData['isDone'] as bool? ?? false;
      final newStatus = !currentStatus;

      // สร้าง update data
      final updateData = <String, dynamic>{
        'isDone': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus) {
        // เมื่อ complete: set progress เป็น 100%, status เป็น completed
        updateData['progress'] = 1.0;
        updateData['status'] = TaskStatus.completed.value;
        updateData['completedAt'] = FieldValue.serverTimestamp();
      } else {
        // เมื่อ uncomplete: reset ค่าต่าง ๆ
        final currentProgress =
            (taskData['progress'] as num?)?.toDouble() ?? 0.0;
        updateData['progress'] =
            currentProgress > 0.0 ? currentProgress : 0.0;
        updateData['status'] =
            currentProgress > 0.0
                ? TaskStatus.inProgress.value
                : TaskStatus.pending.value;
        updateData['completedAt'] = null;
      }

      // อัปเดต task
      await taskRef.doc(taskId).update(updateData);

      debugPrint('✅ Task completion toggled successfully');
    } catch (e) {
      debugPrint('❌ Failed to toggle task: $e');
      rethrow;
    }
  }

  /// อัปเดต Task Progress
  Future<void> updateTaskProgress({
    required String taskId,
    required double progress,
  }) async {
    try {
      debugPrint(
        '🔄 Updating task progress: $taskId to ${(progress * 100).round()}%',
      );

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Validate progress
      final clampedProgress = progress.clamp(0.0, 1.0);

      // Get current task data
      final taskDoc = await taskRef.doc(taskId).get();
      if (!taskDoc.exists) {
        throw Exception('Task not found');
      }

      final taskData = taskDoc.data() as Map<String, dynamic>;

      // ตรวจสอบ ownership
      if (taskData['userId'] != currentUserId) {
        throw Exception('Not authorized to update this task');
      }

      // สร้าง update data
      final updateData = <String, dynamic>{
        'progress': clampedProgress,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // อัปเดต status ตาม progress
      if (clampedProgress >= 1.0) {
        updateData['isDone'] = true;
        updateData['status'] = TaskStatus.completed.value;
        updateData['completedAt'] = FieldValue.serverTimestamp();
      } else if (clampedProgress > 0.0) {
        updateData['isDone'] = false;
        updateData['status'] = TaskStatus.inProgress.value;
        if (taskData['startedAt'] == null) {
          updateData['startedAt'] = FieldValue.serverTimestamp();
        }
      } else {
        updateData['isDone'] = false;
        updateData['status'] = TaskStatus.pending.value;
      }

      // อัปเดต task
      await taskRef.doc(taskId).update(updateData);

      debugPrint('✅ Task progress updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update task progress: $e');
      rethrow;
    }
  }

  /// อัปเดต Task ทั่วไป (Simplified)
  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    Duration? estimatedDuration, // จะถูก ignore
    double? progress,
  }) async {
    try {
      debugPrint('🔄 Updating task: $taskId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // ตรวจสอบ ownership
      final taskDoc = await taskRef.doc(taskId).get();
      if (!taskDoc.exists) {
        throw Exception('Task not found');
      }

      final taskData = taskDoc.data() as Map<String, dynamic>;
      if (taskData['userId'] != currentUserId) {
        throw Exception('Not authorized to update this task');
      }

      // สร้าง update data
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) {
        final titleError = _validateTitle(title);
        if (titleError != null) {
          throw Exception(titleError);
        }
        updateData['title'] = title.trim();
      }

      if (description != null) {
        final descriptionError = _validateDescription(description);
        if (descriptionError != null) {
          throw Exception(descriptionError);
        }
        updateData['description'] =
            description.trim().isEmpty ? null : description.trim();
      }

      if (dueDate != null) {
        updateData['dueDate'] = Timestamp.fromDate(dueDate);
      }

      if (priority != null) {
        if (priority < 1 || priority > 3) {
          throw Exception('Priority must be between 1-3');
        }
        updateData['priority'] = priority;
      }

      if (progress != null) {
        final clampedProgress = progress.clamp(0.0, 1.0);
        updateData['progress'] = clampedProgress;

        // อัปเดต status ตาม progress
        if (clampedProgress >= 1.0) {
          updateData['isDone'] = true;
          updateData['status'] = TaskStatus.completed.value;
          updateData['completedAt'] = FieldValue.serverTimestamp();
        } else if (clampedProgress > 0.0) {
          updateData['status'] = TaskStatus.inProgress.value;
          if (taskData['startedAt'] == null) {
            updateData['startedAt'] = FieldValue.serverTimestamp();
          }
        }
      }

      // อัปเดต task
      await taskRef.doc(taskId).update(updateData);

      debugPrint('✅ Task updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update task: $e');
      rethrow;
    }
  }

  /// ลบ Task
  Future<void> deleteTask(String taskId) async {
    try {
      debugPrint('🔄 Deleting task: $taskId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get task data สำหรับ validation และ project count update
      final taskDoc = await taskRef.doc(taskId).get();
      if (!taskDoc.exists) {
        throw Exception('Task not found');
      }

      final taskData = taskDoc.data() as Map<String, dynamic>;

      // ตรวจสอบ ownership
      if (taskData['userId'] != currentUserId) {
        throw Exception('Not authorized to delete this task');
      }

      final projectId = taskData['projectId'] as String;

      // เริ่ม batch write
      final batch = _firestore.batch();

      // ลบ task
      batch.delete(taskRef.doc(taskId));

      // อัปเดต task count ใน project
      final projectDocRef = projectRef.doc(projectId);
      batch.update(projectDocRef, {
        'taskCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Execute batch
      await batch.commit();

      debugPrint('✅ Task deleted successfully');
    } catch (e) {
      debugPrint('❌ Failed to delete task: $e');
      rethrow;
    }
  }

  /// ลบ Tasks ทั้งหมดของ Project (เมื่อลบ project)
  Future<void> deleteAllProjectTasks(String projectId) async {
    try {
      debugPrint('🔄 Deleting all tasks for project: $projectId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // ดึง tasks ทั้งหมดของ project
      final tasksSnapshot =
          await taskRef
              .where('projectId', isEqualTo: projectId)
              .where('userId', isEqualTo: currentUserId)
              .get();

      if (tasksSnapshot.docs.isEmpty) {
        debugPrint('✅ No tasks to delete');
        return;
      }

      // สร้าง batch delete
      final batch = _firestore.batch();

      for (final doc in tasksSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      debugPrint(
        '✅ Deleted ${tasksSnapshot.docs.length} tasks successfully',
      );
    } catch (e) {
      debugPrint('❌ Failed to delete project tasks: $e');
      rethrow;
    }
  }

  /// ดึง Task statistics
  Future<Map<String, int>> getTaskStats(String projectId) async {
    try {
      final tasksSnapshot =
          await taskRef
              .where('projectId', isEqualTo: projectId)
              .where('userId', isEqualTo: currentUserId)
              .get();

      final tasks =
          tasksSnapshot.docs
              .map(
                (doc) => TaskModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

      final completed = tasks.where((task) => task.isDone).length;
      final pending = tasks.where((task) => !task.isDone).length;
      final overdue = tasks.where((task) => task.isOverdue).length;
      final inProgress =
          tasks
              .where((task) => task.status == TaskStatus.inProgress)
              .length;

      return {
        'total': tasks.length,
        'completed': completed,
        'pending': pending,
        'overdue': overdue,
        'inProgress': inProgress,
      };
    } catch (e) {
      debugPrint('❌ Failed to get task stats: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'overdue': 0,
        'inProgress': 0,
      };
    }
  }

  // ===== Helper Methods =====

  /// กำหนด TaskStatus จาก progress (Simplified)
  TaskStatus _getStatusFromProgress(double progress) {
    if (progress >= 1.0) return TaskStatus.completed;
    if (progress > 0.0) return TaskStatus.inProgress;
    return TaskStatus.pending;
  }

  /// Validate title
  String? _validateTitle(String title) {
    if (title.trim().isEmpty) return 'Task title is required';
    if (title.length > 100)
      return 'Task title is too long (max 100 characters)';
    return null;
  }

  /// Validate description
  String? _validateDescription(String? description) {
    if (description != null && description.length > 500) {
      return 'Description is too long (max 500 characters)';
    }
    return null;
  }

  /// ตรวจสอบว่า Project เป็นของ User หรือไม่
  Future<void> _verifyProjectOwnership(String projectId) async {
    final projectDoc = await projectRef.doc(projectId).get();
    if (!projectDoc.exists) {
      throw Exception('Project not found');
    }

    final projectData = projectDoc.data() as Map<String, dynamic>;
    if (projectData['userId'] != currentUserId) {
      throw Exception('Not authorized to access this project');
    }
  }

  /// ตรวจสอบการเชื่อมต่อ Firestore
  Future<bool> checkConnection() async {
    try {
      debugPrint('🔄 Checking Firestore connection...');
      await _firestore.collection('test').limit(1).get();
      debugPrint('✅ Firestore connection OK');
      return true;
    } catch (e) {
      debugPrint('❌ Firestore connection failed: $e');
      return false;
    }
  }
}
