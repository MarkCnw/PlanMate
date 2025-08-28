import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/task_model.dart';

class FirebaseTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get taskRef => _firestore.collection('tasks');
  CollectionReference get projectRef => _firestore.collection('projects');

  // Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// สร้าง Task ใหม่
  Future<String> createTask({
    required String title,
    required String projectId,
    String? description,
    DateTime? dueDate,
    int priority = 2,
  }) async {
    try {
      print('🔄 Creating task...');
      print('📍 User ID: $currentUserId');
      print('📍 Project ID: $projectId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // ตรวจสอบว่า project นี้เป็นของ user หรือไม่
      await _verifyProjectOwnership(projectId);

      // สร้าง TaskModel
      final task = TaskModel.create(
        title: title,
        projectId: projectId,
        userId: currentUserId!,
        description: description,
        dueDate: dueDate,
        priority: priority,
      );

      print('📋 Task data: ${task.toMap()}');

      // Validate ข้อมูล
      if (!task.isValid) {
        throw Exception('Invalid task data');
      }

      final titleError = task.validateTitle();
      if (titleError != null) {
        throw Exception(titleError);
      }

      final descriptionError = task.validateDescription();
      if (descriptionError != null) {
        throw Exception(descriptionError);
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

      print('✅ Task created successfully with ID: ${taskDocRef.id}');
      return taskDocRef.id;
    } catch (e) {
      print('❌ Failed to create task: $e');
      rethrow;
    }
  }

  /// ดึง Tasks ของ Project เฉพาะ (Real-time)
  Stream<List<TaskModel>> getProjectTasks(String projectId) {
    try {
      print('🔄 Getting tasks for project: $projectId');
      print('📍 User ID: $currentUserId');

      if (currentUserId == null) {
        print('⚠️ No user logged in, returning empty stream');
        return Stream.value([]);
      }

      return taskRef
          .where('projectId', isEqualTo: projectId)
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: false) // เก่าก่อน (task order)
          .snapshots()
          .map((snapshot) {
            print('📦 Received ${snapshot.docs.length} tasks from Firestore');

            final tasks = snapshot.docs
                .map((doc) {
                  try {
                    final data = doc.data() as Map<String, dynamic>;
                    return TaskModel.fromMap(data, doc.id);
                  } catch (e) {
                    print('❌ Error parsing task ${doc.id}: $e');
                    return null;
                  }
                })
                .where((task) => task != null)
                .cast<TaskModel>()
                .toList();

            print('✅ Successfully parsed ${tasks.length} tasks');
            return tasks;
          })
          .handleError((error) {
            print('❌ Tasks stream error: $error');
            throw error;
          });
    } catch (e) {
      print('❌ Failed to get project tasks: $e');
      return Stream.error(e);
    }
  }

  /// อัปเดต Task status (Toggle complete)
  Future<void> toggleTaskComplete(String taskId) async {
    try {
      print('🔄 Toggling task completion: $taskId');

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

      // อัปเดต task
      await taskRef.doc(taskId).update({
        'isDone': newStatus,
        'completedAt': newStatus ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Task completion toggled successfully');
    } catch (e) {
      print('❌ Failed to toggle task: $e');
      rethrow;
    }
  }

  /// อัปเดต Task ทั่วไป
  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
  }) async {
    try {
      print('🔄 Updating task: $taskId');

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
        // Validate title
        if (title.trim().isEmpty) {
          throw Exception('Task title is required');
        }
        if (title.length > 100) {
          throw Exception('Task title is too long (max 100 characters)');
        }
        updateData['title'] = title.trim();
      }

      if (description != null) {
        if (description.length > 500) {
          throw Exception('Description is too long (max 500 characters)');
        }
        updateData['description'] = description.trim().isEmpty ? null : description.trim();
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

      // อัปเดต task
      await taskRef.doc(taskId).update(updateData);

      print('✅ Task updated successfully');
    } catch (e) {
      print('❌ Failed to update task: $e');
      rethrow;
    }
  }

  /// ลบ Task
  Future<void> deleteTask(String taskId) async {
    try {
      print('🔄 Deleting task: $taskId');

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

      print('✅ Task deleted successfully');
    } catch (e) {
      print('❌ Failed to delete task: $e');
      rethrow;
    }
  }

  /// ลบ Tasks ทั้งหมดของ Project (เมื่อลบ project)
  Future<void> deleteAllProjectTasks(String projectId) async {
    try {
      print('🔄 Deleting all tasks for project: $projectId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // ดึง tasks ทั้งหมดของ project
      final tasksSnapshot = await taskRef
          .where('projectId', isEqualTo: projectId)
          .where('userId', isEqualTo: currentUserId)
          .get();

      if (tasksSnapshot.docs.isEmpty) {
        print('✅ No tasks to delete');
        return;
      }

      // สร้าง batch delete
      final batch = _firestore.batch();

      for (final doc in tasksSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      print('✅ Deleted ${tasksSnapshot.docs.length} tasks successfully');
    } catch (e) {
      print('❌ Failed to delete project tasks: $e');
      rethrow;
    }
  }

  /// ดึง Task statistics
  Future<Map<String, int>> getTaskStats(String projectId) async {
    try {
      final tasksSnapshot = await taskRef
          .where('projectId', isEqualTo: projectId)
          .where('userId', isEqualTo: currentUserId)
          .get();

      final tasks = tasksSnapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final completed = tasks.where((task) => task.isDone).length;
      final pending = tasks.where((task) => !task.isDone).length;
      final overdue = tasks.where((task) => task.isOverdue).length;

      return {
        'total': tasks.length,
        'completed': completed,
        'pending': pending,
        'overdue': overdue,
      };
    } catch (e) {
      print('❌ Failed to get task stats: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'overdue': 0,
      };
    }
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
      print('🔄 Checking Firestore connection...');
      await _firestore.collection('test').limit(1).get();
      print('✅ Firestore connection OK');
      return true;
    } catch (e) {
      print('❌ Firestore connection failed: $e');
      return false;
    }
  }
}