import 'package:flutter/material.dart';
import 'package:planmate/CreateProject/Create/Controller/create_project_controller.dart';
import 'package:planmate/CreateProject/Presentation/project_screen.dart';
import 'package:planmate/Models/project_model.dart';

class CreateProjectSheet extends StatefulWidget {
  final void Function(String name, String iconPath)? onSubmit;

  const CreateProjectSheet({super.key, this.onSubmit});

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  late CreateProjectController controller;

  @override
  void initState() {
    super.initState();
    controller = CreateProjectController(
      context: context, // ✅ ส่ง context
      onStateChanged: () => setState(() {}),
      onSuccess: _onCreateSuccess,
      onError: _onCreateError,
    );
  }

  void _onCreateSuccess(ProjectModel project) {
    // ✅ UI จัดการ navigation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectScreenDetail(project: project),
      ),
    );
  }

  void _onCreateError() {
    // ✅ UI จัดการ error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to create project')),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      appBar: AppBar(
        title: const Text('Create New Project'),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + insets),
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Project Name =====
                RichText(
                  text: TextSpan(
                    text: 'Project Name',
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
                  controller: controller.nameController,
                  maxLength: 50,
                  decoration: InputDecoration(
                    hintText: 'Enter project name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF8B5CF6),
                        width: 2,
                      ),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    errorText: controller.nameError,
                    counterText: '',
                  ),
                  onChanged: (_) {
                    if (controller.nameError != null)
                      setState(() => controller.nameError = null);
                  },
                ),
                const SizedBox(height: 24),

                // ===== Icon Picker =====
                RichText(
                  text: TextSpan(
                    text: 'Choose Icon',
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
                if (controller.iconError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    controller.iconError!,
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
                          controller.iconError != null
                              ? Colors.red
                              : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        controller.iconOptions.map((icon) {
                          final isSelected =
                              controller.selectedIconPath == icon['path'];
                          return GestureDetector(
                            onTap:
                                () => controller.selectIcon(
                                  icon['key']!,
                                  icon['path']!,
                                ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(
                                          0xFF8B5CF6,
                                        ).withOpacity(0.1)
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
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

                const SizedBox(height: 120), // เว้นที่ให้ปุ่มล่าง
              ],
            ),
          ),
        ),
      ),

      // ===== ปุ่ม Create ตรึงล่าง =====
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading ? null : controller.createProject,
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
                  controller.isLoading
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            'Creating...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                      : const Text(
                        'Create Project',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
