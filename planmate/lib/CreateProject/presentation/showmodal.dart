import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreateProjectSheet extends StatefulWidget {
  final void Function(String name, IconData icon) onSubmit;

  const CreateProjectSheet({super.key, required this.onSubmit});

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  final TextEditingController _nameController = TextEditingController();
  IconData? _selectedIcon;

  final List<IconData> _icons = [
    FontAwesomeIcons.basketball,
    FontAwesomeIcons.paintBrush,
    FontAwesomeIcons.music,
    FontAwesomeIcons.code,
    FontAwesomeIcons.book,
    FontAwesomeIcons.camera,
    FontAwesomeIcons.rocket,
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
            children: _icons.map((icon) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: _selectedIcon == icon
                      ? Colors.blue.shade100
                      : Colors.grey.shade200,
                  child: FaIcon(
                    icon,
                    color: _selectedIcon == icon
                        ? Colors.blue
                        : Colors.grey.shade700,
                    size: 20,
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
                    _selectedIcon != null) {
                  widget.onSubmit(_nameController.text, _selectedIcon!);
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
