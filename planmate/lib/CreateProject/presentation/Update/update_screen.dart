// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:planmate/Services/firebase_project_service.dart';

class UpdateProjectSheet extends StatefulWidget {
  final void Function(String name, String iconPath)? onSubmit;
  final String projectId;
  final String currentTitle;
  final String currentIconKey;
  final String currentIconPath;
  const UpdateProjectSheet({
    super.key,
    this.onSubmit,
    required this.projectId,
    required this.currentTitle,
    required this.currentIconKey,
    required this.currentIconPath,
  });

  @override
  State<UpdateProjectSheet> createState() => _UpdateProjectSheetState();
}

class _UpdateProjectSheetState extends State<UpdateProjectSheet> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseProjectServices _projectService =
      FirebaseProjectServices();

  String? _selectedIconPath;
  String? _selectedIconKey;
  bool _isLoading = false;
  String? _nameError;
  String? _iconError;

  final List<Map<String, String>> iconOptions = [
    {'key': 'arrow', 'path': 'assets/icons/arrow.png'},
    {'key': 'book', 'path': 'assets/icons/book.png'},
    {'key': 'check', 'path': 'assets/icons/check.png'},
    {'key': 'check&cal', 'path': 'assets/icons/check&cal.png'},
    {'key': 'Chess', 'path': 'assets/icons/Chess.png'},
    {'key': 'computer', 'path': 'assets/icons/computer.png'},
    {'key': 'crayons', 'path': 'assets/icons/crayons.png'},
    {'key': 'Egg&Bacon', 'path': 'assets/icons/Egg&Bacon.png'},
    {'key': 'esports', 'path': 'assets/icons/esports.png'},
    {'key': 'Football', 'path': 'assets/icons/Football.png'},
    {'key': 'Gymming', 'path': 'assets/icons/Gymming.png'},
    {'key': 'pencil', 'path': 'assets/icons/pencil.png'},
    {'key': 'Pizza', 'path': 'assets/icons/Pizza.png'},
    {'key': 'rocket', 'path': 'assets/icons/rocket.png'},
    {'key': 'ruler', 'path': 'assets/icons/ruler.png'},
  ];

  @override
  void initState() {
    super.initState();
    // ตั้งค่าเริ่มต้น
    _nameController.text = widget.currentTitle;
    _selectedIconPath = widget.currentIconPath;
    _selectedIconKey = widget.currentIconKey;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _nameError = null;
      _iconError = null;
    });

    bool isValid = true;

    // Validate project name
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'Project name is required';
      });
      isValid = false;
    } else if (_nameController.text.trim().length > 50) {
      setState(() {
        _nameError = 'Project name is too long (max 50 characters)';
      });
      isValid = false;
    }

    // Validate icon selection
    if (_selectedIconPath == null) {
      setState(() {
        _iconError = 'Please select an icon';
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> _handleEditProject() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _projectService.editProject(
        _nameController.text.trim(),
        _selectedIconKey!,
        widget.projectId,
      );

      if (mounted) {
        // Call the optional callback
        widget.onSubmit?.call(
          _nameController.text.trim(),
          _selectedIconPath!,
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update project: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Edit Project',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in the details to Edit your project',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Name Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'New Project Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter new project name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF8B5CF6),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            errorText: _nameError,
                          ),
                          onChanged: (value) {
                            if (_nameError != null) {
                              setState(() {
                                _nameError = null;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Icon Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Choose new Icon',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        if (_iconError != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _iconError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  _iconError != null
                                      ? Colors.red
                                      : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                iconOptions.map((icon) {
                                  final isSelected =
                                      _selectedIconPath == icon['path'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedIconPath = icon['path'];
                                        _selectedIconKey = icon['key'];
                                        _iconError = null;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? const Color(
                                                  0xFF8B5CF6,
                                                ).withOpacity(0.1)
                                                : Colors.grey.shade100,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? const Color(0xFF8B5CF6)
                                                  : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Image.asset(
                                        icon['path']!,
                                        width: 32,
                                        height: 32,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Create Button - ย้ายเข้ามาใน ScrollView
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleEditProject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Updating...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                                : const Text(
                                  'Update Project',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
