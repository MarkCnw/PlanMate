// Example usage of the updated ShowProjectScreen
// This file demonstrates how to use the new ShowProjectScreen widget

import 'package:flutter/material.dart';
import 'package:planmate/CreateProject/presentation/project_screen.dart';
import 'package:planmate/Models/project_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlanMate ShowProjectScreen Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProjectDemoScreen(),
    );
  }
}

class ProjectDemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create a sample project using ProjectModel
    final sampleProject = ProjectModel.create(
      title: 'My Awesome Project',
      iconKey: 'rocket',
      userId: 'user123',
      description: 'This is a sample project to demonstrate the new UI',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Project Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Method 1: Using ProjectModel constructor
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowProjectScreen.fromProject(
                      project: sampleProject,
                    ),
                  ),
                );
              },
              child: Text('Show Project (from ProjectModel)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Method 2: Using direct parameters
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowProjectScreen(
                      title: 'Direct Parameters Project',
                      iconPath: 'assets/icons/book.png',
                      color: Colors.purple,
                    ),
                  ),
                );
              },
              child: Text('Show Project (direct parameters)'),
            ),
          ],
        ),
      ),
    );
  }
}