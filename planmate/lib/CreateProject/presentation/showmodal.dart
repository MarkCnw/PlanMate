import 'package:flutter/material.dart';

class CreateProjectSheet extends StatefulWidget {
  final void Function(String name, String iconPath) onSubmit;

  const CreateProjectSheet({super.key, required this.onSubmit});

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedIconPath;

  final List<String> iconPath = [
    'assets/icons/arrow.png',
    'assets/icons/book.png',
    'assets/icons/check.png',
    'assets/icons/check&cal.png',
    'assets/icons/Chess.png',
    'assets/icons/computer.png',
    'assets/icons/crayons.png',
    'assets/icons/Egg&Bacon.png',
    'assets/icons/esports.png',
    'assets/icons/Football.png',
    'assets/icons/Gymming.png',
    'assets/icons/pencil.png',
    'assets/icons/Pizza.png',
    'assets/icons/rocket.png',
    'assets/icons/ruler.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Create New Project',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Project Name Input
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Project Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Icon Picker
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose Icon',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                iconPath.map((path) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIconPath = path;
                      });
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          _selectedIconPath == path
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                      child: Image.asset(
                        path,
                        width: 65,
                        height: 65,
                        // color:
                        //     _selectedIconPath == path
                        //         ? Colors.blue
                        //         : Colors.grey.shade700,
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _selectedIconPath != null) {
                  widget.onSubmit(
                    _nameController.text,
                    _selectedIconPath!,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ),
        ],
      ),
    );
  }
}
