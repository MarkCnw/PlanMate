import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/project_model.dart';

class FirebaseProjectServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get projectRef => _firestore.collection('projects');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// สร้างโปรเจคใหม่ (ใช้ Asset Icons)
  Future<String> createProject({
    required String title,
    required String iconKey,
    String? description,
  }) async {
    try {
      // ตรวจสอบว่า user ล็อกอินแล้วหรือไม่
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // สร้าง ProjectModel
      final project = ProjectModel.create(
        title: title,
        iconKey: iconKey,
        userId: currentUserId!,
        description: description,
      );

      // Validate ข้อมูล
      if (!project.isValid) {
        throw Exception('Invalid project data');
      }

      final titleError = project.validateTitle();
      if (titleError != null) {
        throw Exception(titleError);
      }

      final descriptionError = project.validateDescription();
      if (descriptionError != null) {
        throw Exception(descriptionError);
      }

      // สร้างเอกสารใหม่ใน Firestore
      final docRef = await projectRef.add(project.toMap());
      
      print('✅ Project created successfully with ID: ${docRef.id}');
      return docRef.id;
      
    } catch (e) {
      print('❌ Failed to create project: $e');
      rethrow;
    }
  }

  /// อัปเดตโปรเจค
  Future<void> updateProject(ProjectModel project) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // ตรวจสอบว่าเป็นเจ้าของโปรเจคหรือไม่
      if (!project.belongsToUser(currentUserId!)) {
        throw Exception('Unauthorized to update this project');
      }

      await projectRef.doc(project.id).update(project.toMap());
      print('✅ Project updated successfully');
      
    } catch (e) {
      print('❌ Failed to update project: $e');
      rethrow;
    }
  }

  /// ลบโปรเจค
  Future<void> deleteProject(String projectId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // ดึงข้อมูลโปรเจคก่อนลบเพื่อตรวจสอบสิทธิ์
      final doc = await projectRef.doc(projectId).get();
      if (!doc.exists) {
        throw Exception('Project not found');
      }

      final project = ProjectModel.fromMap(
        doc.data() as Map<String, dynamic>, 
        doc.id,
      );

      // ตรวจสอบสิทธิ์
      if (!project.belongsToUser(currentUserId!)) {
        throw Exception('Unauthorized to delete this project');
      }

      await projectRef.doc(projectId).delete();
      print('✅ Project deleted successfully');
      
    } catch (e) {
      print('❌ Failed to delete project: $e');
      rethrow;
    }
  }

  /// ดึงโปรเจคทั้งหมดของ user ปัจจุบัน (Real-time)
  Stream<List<ProjectModel>> getUserProjects() {
    try {
      if (currentUserId == null) {
        return Stream.value([]);
      }

      return projectRef
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ProjectModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      });
      
    } catch (e) {
      print('❌ Failed to get user projects: $e');
      return Stream.error(e);
    }
  }

  /// ดึงโปรเจคทั้งหมดของ user ปัจจุบัน (One-time)
  Future<List<ProjectModel>> getUserProjectsOnce() async {
    try {
      if (currentUserId == null) {
        return [];
      }

      final snapshot = await projectRef
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return ProjectModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
      
    } catch (e) {
      print('❌ Failed to get user projects: $e');
      rethrow;
    }
  }

  /// ดึงโปรเจคเดียว
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final doc = await projectRef.doc(projectId).get();
      
      if (!doc.exists) {
        return null;
      }

      final project = ProjectModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      // ตรวจสอบสิทธิ์การเข้าถึง
      if (currentUserId != null && !project.belongsToUser(currentUserId!)) {
        throw Exception('Unauthorized to access this project');
      }

      return project;
      
    } catch (e) {
      print('❌ Failed to get project: $e');
      rethrow;
    }
  }

  /// อัปเดตจำนวน tasks ในโปรเจค
  Future<void> updateTaskCount(String projectId, int newCount) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await projectRef.doc(projectId).update({
        'taskCount': newCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Task count updated successfully');
      
    } catch (e) {
      print('❌ Failed to update task count: $e');
      rethrow;
    }
  }

  /// ดึงสถิติโปรเจคของ user
  Future<Map<String, dynamic>> getUserProjectStats() async {
    try {
      if (currentUserId == null) {
        return {
          'totalProjects': 0,
          'totalTasks': 0,
          'completedTasks': 0,
        };
      }

      final projects = await getUserProjectsOnce();
      
      int totalProjects = projects.length;
      int totalTasks = projects.fold(0, (sum, project) => sum + project.taskCount);
      
      return {
        'totalProjects': totalProjects,
        'totalTasks': totalTasks,
        'completedTasks': 0, // จะต้องคำนวณจาก tasks collection ภายหลัง
      };
      
    } catch (e) {
      print('❌ Failed to get user stats: $e');
      rethrow;
    }
  }

  /// ตรวจสอบว่า user มีสิทธิ์เข้าถึงโปรเจคหรือไม่
  Future<bool> hasProjectAccess(String projectId) async {
    try {
      final project = await getProject(projectId);
      return project != null;
    } catch (e) {
      return false;
    }
  }
}