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
      print('🔄 Creating project...');
      print('📍 User ID: $currentUserId');

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

      print('📋 Project data: ${project.toMap()}');

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

  /// ดึงโปรเจคทั้งหมดของ user ปัจจุบัน (Real-time)
  Stream<List<ProjectModel>> getUserProjects() {
    try {
      print('🔄 Getting user projects...');
      print('📍 User ID: $currentUserId');

      if (currentUserId == null) {
        print('⚠️ No user logged in, returning empty stream');
        return Stream.value([]);
      }

      return projectRef
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            print(
              '📦 Received ${snapshot.docs.length} projects from Firestore',
            );

            final projects =
                snapshot.docs
                    .map((doc) {
                      try {
                        final data = doc.data() as Map<String, dynamic>;
                        print('📄 Project data: $data');

                        return ProjectModel.fromMap(data, doc.id);
                      } catch (e) {
                        print('❌ Error parsing project ${doc.id}: $e');
                        return null;
                      }
                    })
                    .where((project) => project != null)
                    .cast<ProjectModel>()
                    .toList();

            print('✅ Successfully parsed ${projects.length} projects');
            return projects;
          })
          .handleError((error) {
            print('❌ Stream error: $error');
            throw error;
          });
    } catch (e) {
      print('❌ Failed to get user projects: $e');
      return Stream.error(e);
    }
  }

  /// ดึงโปรเจคทั้งหมดของ user ปัจจุบัน (One-time) - แบบไม่มี orderBy
  Future<List<ProjectModel>> getUserProjectsOnceSimple() async {
    try {
      print('🔄 Getting user projects (simple)...');
      print('📍 User ID: $currentUserId');

      if (currentUserId == null) {
        print('⚠️ No user logged in, returning empty list');
        return [];
      }

      final snapshot =
          await projectRef.where('userId', isEqualTo: currentUserId).get();

      print('📦 Received ${snapshot.docs.length} projects from Firestore');

      final projects =
          snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  print('📄 Project data: $data');

                  return ProjectModel.fromMap(data, doc.id);
                } catch (e) {
                  print('❌ Error parsing project ${doc.id}: $e');
                  return null;
                }
              })
              .where((project) => project != null)
              .cast<ProjectModel>()
              .toList();

      print('✅ Successfully parsed ${projects.length} projects');
      return projects;
    } catch (e) {
      print('❌ Failed to get user projects: $e');
      rethrow;
    }
  }

  /// Stream แบบง่าย ๆ ไม่มี orderBy
  Stream<List<ProjectModel>> getUserProjectsSimple() {
    try {
      print('🔄 Getting user projects (simple stream)...');
      print('📍 User ID: $currentUserId');

      if (currentUserId == null) {
        print('⚠️ No user logged in, returning empty stream');
        return Stream.value([]);
      }

      return projectRef
          .where('userId', isEqualTo: currentUserId)
          .snapshots()
          .map((snapshot) {
            print(
              '📦 Received ${snapshot.docs.length} projects from Firestore',
            );

            final projects =
                snapshot.docs
                    .map((doc) {
                      try {
                        final data = doc.data() as Map<String, dynamic>;
                        print('📄 Project data: $data');

                        return ProjectModel.fromMap(data, doc.id);
                      } catch (e) {
                        print('❌ Error parsing project ${doc.id}: $e');
                        return null;
                      }
                    })
                    .where((project) => project != null)
                    .cast<ProjectModel>()
                    .toList();

            print('✅ Successfully parsed ${projects.length} projects');
            return projects;
          })
          .handleError((error) {
            print('❌ Stream error: $error');
            throw error;
          });
    } catch (e) {
      print('❌ Failed to get user projects: $e');
      return Stream.error(e);
    }
  }

  /// ตรวจสอบสถานะการเชื่อมต่อ
  Future<bool> checkConnection() async {
    try {
      print('🔄 Checking Firestore connection...');

      // ลองดึงข้อมูล 1 document เพื่อทดสอบการเชื่อมต่อ
      await _firestore.collection('test').limit(1).get();

      print('✅ Firestore connection OK');
      return true;
    } catch (e) {
      print('❌ Firestore connection failed: $e');
      return false;
    }
  }

  /// ตรวจสอบสถานะ user
  void checkUserStatus() {
    final user = _auth.currentUser;
    print('👤 Current user: ${user?.uid}');
    print('📧 User email: ${user?.email}');
    print('📱 User name: ${user?.displayName}');
    print('🔐 User signed in: ${user != null}');
  }

  Future<void> deleteProject(String projectId) async {
    try {
      print('Deleting your project $projectId');
      await projectRef.doc(projectId).delete();
      print('✅ Project deleted successfully');
    } catch (e) {
      print('❌ Failed to delete project: $e');
      rethrow;
    }
  }

  Future<void> updateProject({
    required String projectId,
    required String newTitle,
    required String newIconKey,
    required String newIconPath,
    required int newColor, // เพิ่ม parameter สำหรับสี
  }) async {
    print('📌 Received Title: $newTitle');
    print('📌 Received IconKey: $newIconKey');
    print('📌 Received IconPath: $newIconPath');
    print('📌 Received Color: $newColor');
    print('📌 Received ProjectId: $projectId');

    try {
      print('🔄 Editing project...');
      print('📍 Project ID: $projectId');
      print('📍 User ID: $currentUserId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Validation
      final tempProject = ProjectModel.create(
        title: newTitle,
        iconKey: newIconKey,
        userId: currentUserId!,
      );

      final titleError = tempProject.validateTitle();
      if (titleError != null) {
        throw Exception(titleError);
      }

      // ตรวจสอบว่า project นี้เป็นของ user ปัจจุบันหรือไม่
      final projectDoc = await projectRef.doc(projectId).get();
      if (!projectDoc.exists) {
        throw Exception('Project not found');
      }

      final projectData = projectDoc.data() as Map<String, dynamic>;
      if (projectData['userId'] != currentUserId) {
        throw Exception('Not authorized to update this project');
      }

      // อัพเดทข้อมูล - เพิ่ม iconPath และ color
      final updateData = {
        'title': newTitle.trim(),
        'iconKey': newIconKey,
        'iconPath': newIconPath, // 🔥 เพิ่ม iconPath
        'color': newColor, // 🔥 เพิ่ม color
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('📤 Update data: $updateData');

      await projectRef.doc(projectId).update(updateData);
      print('✅ Project updated successfully');
    } catch (e) {
      print('❌ Failed to update project: $e');
      rethrow;
    }
  }
}
