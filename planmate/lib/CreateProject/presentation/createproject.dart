import 'package:flutter/material.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Create Something New'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'What would you like to create?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Options for creation
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 2, // จำนวนตัวเลือก (Project, Task)
                itemBuilder: (context, index) {
                  // Mock Data
                  final options = [
                    {
                      'title': 'New Project',
                      'icon': Icons.folder,
                      'color': Colors.blue,
                      'description': 'Organize your work and goals',
                    },
                    {
                      'title': 'New Task',
                      'icon': Icons.task,
                      'color': Colors.green,
                      'description': 'Add a task to your project',
                    },
                  ];

                  return InkWell(
                    onTap: () {
                      // Handle creation based on index
                      if (index == 0) {
                        // Navigate to create project screen
                      } else if (index == 1) {
                        // Navigate to create task screen
                      }
                    },
                    child: Card(
                      color: options[index]['color'] as Color,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              options[index]['icon'] as IconData,
                              size: 40,
                              color: Colors.white,
                            ),
                            Text(
                              options[index]['title'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              options[index]['description'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open create options
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
