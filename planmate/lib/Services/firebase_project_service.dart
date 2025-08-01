import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../Models/project_model.dart';

class FirebaseProjectServices {
  CollectionReference get projectRef =>
      FirebaseFirestore.instance.collection('Project');

  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  Future<void> createProject(ProjectModel project, File iconFile) async {
    try {
      final iconRef =
          firebaseStorage.ref().child('ProjectIcons/${project.id}.jpg');
      await iconRef.putFile(iconFile);
      final iconUrl = await iconRef.getDownloadURL();

      final projectWithIcon = project.copyWith(iconPath: iconUrl);
      await projectRef.doc(project.id).set(projectWithIcon.toMap());
    } catch (e) {
      print('❌ Failed to create project: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(ProjectModel project) async {
    try {
      // ลบไฟล์ไอคอนใน Storage
      final iconRef =
          firebaseStorage.ref().child('ProjectIcons/${project.id}.jpg');
      await iconRef.delete();

      // ลบเอกสารจาก Firestore
      await projectRef.doc(project.id).delete();
    } catch (e) {
      print('❌ Failed to delete project: $e');
      rethrow;
    }
  }

  Stream<List<ProjectModel>> getProjects() {
    try {
      return projectRef.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return ProjectModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      print('❌ Failed to get projects: $e');
      rethrow;
    }
  }

  Future<void> updateProject(ProjectModel project, {File? newIconFile}) async {
    try {
      String updatedIconUrl = project.iconPath;

      // ถ้ามีการอัปเดตไฟล์ไอคอนใหม่
      if (newIconFile != null) {
        final iconRef =
            firebaseStorage.ref().child('ProjectIcons/${project.id}.jpg');
        await iconRef.putFile(newIconFile);
        updatedIconUrl = await iconRef.getDownloadURL();
      }

      final updatedProject = project.copyWith(iconPath: updatedIconUrl);
      await projectRef.doc(project.id).update(updatedProject.toMap());
    } catch (e) {
      print('❌ Failed to update project: $e');
      rethrow;
    }
  }
}
