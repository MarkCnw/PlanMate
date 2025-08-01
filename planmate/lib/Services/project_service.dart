import 'dart:io';

import 'package:planmate/Models/project_model.dart';

abstract class ProjectService {
  Future<void> createProject(ProjectModel project, File? iconFile);
  Future<void> updateProject(ProjectModel project, File? newIconFile);
  Future<void> deleteProject(String id);
  Stream<List<ProjectModel>> getProjects();
}
