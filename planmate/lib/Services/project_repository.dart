// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:planmate/Models/project_model.dart';

// // class ProjectRepository {
// //   final FirebaseFirestore _firestore;

// //   ProjectRepository({FirebaseFirestore? firestore})
// //     : _firestore = firestore ?? FirebaseFirestore.instance;
// //   CollectionReference<Map<String, dynamic>> get _projectRef =>
// //       _firestore.collection('projects');

// //   /// Stream โปรเจคของ user (เรียงล่าสุดก่อน)
// //   Stream<List<ProjectModel>> streamUserProjects(String userId) {
// //     return _projectRef
// //         .where('userId', isEqualTo: userId)
// //         .orderBy('createdAt', descending: true)
// //         .snapshots()
// //         .map((snapshot) {
// //           return snapshot.docs.map((doc) {
// //             final data = doc.data();
// //             return ProjectModel.fromMap(data, doc.id);
// //           }).toList();
// //         });
// //   }

// //   /// สร้างโปรเจคใหม่
// //   Future<String> createProject({
// //     required String userId,
// //     required String title,
// //     required String iconKey,
// //     String? description,
// //   }) async {
// //     final project = ProjectModel.create(
// //       title: title,
// //       iconKey: iconKey,
// //       userId: userId,
// //       description: description,
// //     );

// //     // Validate ข้อมูล
// //     if (!project.isValid) {
// //       throw Exception('Invalid project data');
// //     }

// //     final titleError = project.validateTitle();
// //     if (titleError != null) {
// //       throw Exception(titleError);
// //     }

// //     final descriptionError = project.validateDescription();
// //     if (descriptionError != null) {
// //       throw Exception(descriptionError);
// //     }

// //     final docRef = await _projectRef.add(project.toMap());
// //     return docRef.id;
// //   }

// //   /// อัปเดตโปรเจค (ตรวจสอบ ownership)
// //   Future<void> updateProject({
// //     required String userId,
// //     required String projectId,
// //     required String newTitle,
// //     required String newIconKey,
// //     String? newIconPath,
// //     int? newColor,
// //   }) async {
// //     // Validate title
// //     final tempProject = ProjectModel.create(
// //       title: newTitle,
// //       iconKey: newIconKey,
// //       userId: userId,
// //     );

// //     final titleError = tempProject.validateTitle();
// //     if (titleError != null) {
// //       throw Exception(titleError);
// //     }

// //     // ตรวจสอบ ownership
// //     final projectDoc = await _projectRef.doc(projectId).get();
// //     if (!projectDoc.exists) {
// //       throw Exception('Project not found');
// //     }

// //     final projectData = projectDoc.data()!;
// //     if (projectData['userId'] != userId) {
// //       throw Exception('Not authorized to update this project');
// //     }

// //     // Resolve icon metadata ถ้าไม่ได้ส่งมา
// //     String iconPath = newIconPath ?? '';
// //     int color = newColor ?? 0;

// //     if (newIconPath == null || newColor == null) {
// //       final icons = ProjectModel.getIconOptions();
// //       final meta = icons[newIconKey] ?? icons['rocket']!;
// //       iconPath = meta.iconPath;
// //       color = meta.color.value;
// //     }

// //     // อัปเดตข้อมูล
// //     await _projectRef.doc(projectId).update({
// //       'title': newTitle.trim(),
// //       'iconKey': newIconKey,
// //       'iconPath': iconPath,
// //       'color': color,
// //       'updatedAt': FieldValue.serverTimestamp(),
// //     });
// //   }

// //   /// ลบโปรเจค (ตรวจสอบ ownership)
// //   Future<void> deleteProject({
// //     required String userId,
// //     required String projectId,
// //   }) async {
// //     // ตรวจสอบ ownership
// //     final projectDoc = await _projectRef.doc(projectId).get();
// //     if (!projectDoc.exists) {
// //       throw Exception('Project not found');
// //     }

// //     final projectData = projectDoc.data()!;
// //     if (projectData['userId'] != userId) {
// //       throw Exception('Not authorized to delete this project');
// //     }

// //     await _projectRef.doc(projectId).delete();
// //   }

// //   /// ตรวจสอบการเชื่อมต่อ Firestore
// //   Future<bool> checkConnection() async {
// //     try {
// //       await _firestore.collection('test').limit(1).get();
// //       return true;
// //     } catch (e) {
// //       return false;
// //     }
// //   }
// // }


// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:planmate/Models/project_model.dart';
// import 'package:planmate/Services/project_repository.dart';


// class ProjectProvider extends ChangeNotifier {
//   final FirebaseAuth _auth;
//   final ProjectRepository _repo;

//   ProjectProvider({
//     FirebaseAuth? auth,
//     required ProjectRepository repository,
//   })  : _auth = auth ?? FirebaseAuth.instance,
//         _repo = repository {
//     _init();
//   }

//   // ===== State =====
//   List<ProjectModel> _projects = [];
//   bool _isInitialLoading = true;
//   bool _isBusy = false;
//   String? _error;

//   // ===== Getters =====
//   List<ProjectModel> get projects => _projects;
//   bool get isInitialLoading => _isInitialLoading;
//   bool get isBusy => _isBusy;
//   String? get error => _error;

//   StreamSubscription<User?>? _authSub;
//   StreamSubscription<List<ProjectModel>>? _projectsSub;

//   String? get _uid => _auth.currentUser?.uid;

//   void _init() {
//     // start if already signed-in
//     if (_uid != null) _startUserStream(_uid!);

//     // bind to auth state
//     _authSub = _auth.authStateChanges().listen((user) {
//       if (user == null) {
//         _stopUserStream();
//         _projects = [];
//         _isInitialLoading = true;
//         _error = null;
//         notifyListeners();  
//       } else {
//         _startUserStream(user.uid);
//       }
//     });
//   }

//   void _startUserStream(String uid) {
//     _projectsSub?.cancel();
//     _isInitialLoading = true;
//     _error = null;
//     notifyListeners();

//     _projectsSub = _repo.streamUserProjects(uid).listen(
//       (items) {
//         _projects = items;
//         _isInitialLoading = false;
//         _error = null;
//         notifyListeners();
//       },
//       onError: (e) {
//         _isInitialLoading = false;
//         _error = 'Failed to load projects';
//         notifyListeners();
//         debugPrint('❌ stream error: $e');
//       },
//     );
//   }

//   void _stopUserStream() {
//     _projectsSub?.cancel();
//     _projectsSub = null;
//   }

//   // ===== Commands =====
//   Future<String?> createProject({
//     required String title,
//     required String iconKey,
//     String? description,
//   }) async {
//     final uid = _uid;
//     if (uid == null) {
//       _error = 'User not authenticated';
//       notifyListeners();
//       return null;
//     }
//     try {
//       _setBusy(true);
//       _error = null;
//       final id = await _repo.createProject(
//         userId: uid,
//         title: title,
//         iconKey: iconKey,
//         description: description,
//       );
//       return id;
//     } catch (e) {
//       _error = e.toString();
//       return null;
//     } finally {
//       _setBusy(false);
//     }
//   }

//   // 🔥 แก้ไข: เพิ่ม iconPath และ color parameters
//   Future<bool> updateProject({
//     required String projectId,
//     required String title,
//     required String iconKey,
//     String? iconPath,  // ✅ เพิ่ม
//     int? color,        // ✅ เพิ่ม
//   }) async {
//     final uid = _uid;
//     if (uid == null) {
//       _error = 'User not authenticated';
//       notifyListeners();
//       return false;
//     }
//     try {
//       _setBusy(true);
//       _error = null;
//       await _repo.updateProject(
//         userId: uid,
//         projectId: projectId,
//         newTitle: title,
//         newIconKey: iconKey,
//         newIconPath: iconPath,  // ✅ เพิ่ม
//         newColor: color,        // ✅ เพิ่ม
//       );
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _setBusy(false);
//     }
//   }

//   Future<bool> remove(String projectId) async {
//     final uid = _uid;
//     if (uid == null) {
//       _error = 'User not authenticated';
//       notifyListeners();
//       return false;
//     }
//     try {
//       _setBusy(true);
//       _error = null;
//       await _repo.deleteProject(userId: uid, projectId: projectId);
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _setBusy(false);
//     }
//   }

//   ProjectModel? byId(String id) =>
//       _projects.where((p) => p.id == id).cast<ProjectModel?>().firstOrNull;

//   void _setBusy(bool v) {
//     _isBusy = v;
//     notifyListeners();
//   }

//   void refreshProjects() {
//     final uid = _uid;
//     if (uid != null) {
//       _startUserStream(uid);
//     }
//   }

//   @override
//   void dispose() {
//     _projectsSub?.cancel();
//     _authSub?.cancel();
//     super.dispose();
//   }
// }

// extension<T> on Iterable<T> {
//   T? get firstOrNull => isEmpty ? null : first;
// }