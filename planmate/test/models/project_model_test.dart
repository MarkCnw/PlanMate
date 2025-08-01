import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planmate/Models/project_model.dart';

void main() {
  group('ProjectModel Unit Tests', () {
    test('create factory creates ProjectModel correctly', () {
      final project = ProjectModel.create(
        title: 'Test Project',
        iconKey: 'arrow',
        userId: 'user123',
        description: 'A test description',
      );

      expect(project.title, 'Test Project');
      expect(project.iconKey, 'arrow');
      expect(project.userId, 'user123');
      expect(project.description, 'A test description');
      expect(project.taskCount, 0);
      expect(project.color, ProjectModel.getIconOptions()['arrow']!.color);
      expect(project.iconPath, ProjectModel.getIconOptions()['arrow']!.iconPath);
      expect(project.isValid, isTrue);
    });

    test('fromMap creates ProjectModel correctly', () {
      final now = DateTime.now();
      final map = {
        'title': 'From Map',
        'taskCount': 5,
        'color': Colors.red.value,
        'iconPath': 'assets/icons/arrow.png',
        'iconKey': 'arrow',
        'userId': 'user456',
        'description': 'Desc',
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      };

      final project = ProjectModel.fromMap(map);

      expect(project.title, 'From Map');
      expect(project.taskCount, 5);
      expect(project.color.value, Colors.red.value);
      expect(project.iconPath, 'assets/icons/arrow.png');
      expect(project.iconKey, 'arrow');
      expect(project.userId, 'user456');
      expect(project.description, 'Desc');
      expect(project.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(project.updatedAt!.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('toMap returns correct map', () {
      final now = DateTime.now();
      final project = ProjectModel(
        id: '1',
        title: 'To Map',
        taskCount: 3,
        color: Colors.blue,
        iconPath: 'path',
        iconKey: 'arrow',
        userId: 'user1',
        description: 'desc',
        createdAt: now,
        updatedAt: now,
      );

      final map = project.toMap();

      expect(map['title'], 'To Map');
      expect(map['taskCount'], 3);
      expect(map['color'], Colors.blue.value);
      expect(map['iconPath'], 'path');
      expect(map['iconKey'], 'arrow');
      expect(map['userId'], 'user1');
      expect(map['description'], 'desc');
      expect(map['createdAt'], now.millisecondsSinceEpoch);
      expect(map['updatedAt'], now.millisecondsSinceEpoch);
    });

    test('validateTitle returns error when title is empty or too long', () {
      final p1 = ProjectModel.create(title: '', iconKey: 'arrow', userId: 'u1');
      expect(p1.validateTitle(), 'Project name is required');

      final longTitle = 'a' * 51;
      final p2 = ProjectModel.create(title: longTitle, iconKey: 'arrow', userId: 'u1');
      expect(p2.validateTitle(), 'Project name is too long (max 50 characters)');

      final p3 = ProjectModel.create(title: 'Valid', iconKey: 'arrow', userId: 'u1');
      expect(p3.validateTitle(), null);
    });

    test('validateDescription returns error when description is too long', () {
      final longDesc = 'a' * 201;
      final p = ProjectModel.create(title: 'Test', iconKey: 'arrow', userId: 'u1', description: longDesc);
      expect(p.validateDescription(), 'Description is too long (max 200 characters)');

      final p2 = ProjectModel.create(title: 'Test', iconKey: 'arrow', userId: 'u1', description: 'ok');
      expect(p2.validateDescription(), null);
    });

    test('copyWith updates properties correctly', () {
      final project = ProjectModel.create(title: 'Original', iconKey: 'arrow', userId: 'u1');
      final updated = project.copyWith(title: 'Updated', taskCount: 5);

      expect(updated.title, 'Updated');
      expect(updated.taskCount, 5);
      expect(updated.iconKey, project.iconKey);
      expect(updated.userId, project.userId);
    });

    test('updateTaskCount updates taskCount and updatedAt', () {
      final project = ProjectModel.create(title: 'Test', iconKey: 'arrow', userId: 'u1');
      final updated = project.updateTaskCount(10);

      expect(updated.taskCount, 10);
      expect(updated.updatedAt, isNotNull);
      expect(updated.updatedAt!.isAfter(project.createdAt), isTrue);
    });

    test('updateInfo updates title, description, icon and color', () {
      final project = ProjectModel.create(title: 'Test', iconKey: 'arrow', userId: 'u1', description: 'desc');
      final updated = project.updateInfo(title: 'New Title', description: 'New Desc', iconKey: 'book');

      expect(updated.title, 'New Title');
      expect(updated.description, 'New Desc');
      expect(updated.iconKey, 'book');
      expect(updated.iconPath, ProjectModel.getIconOptions()['book']!.iconPath);
      expect(updated.color, ProjectModel.getIconOptions()['book']!.color);
      expect(updated.updatedAt, isNotNull);
    });
  });
}
