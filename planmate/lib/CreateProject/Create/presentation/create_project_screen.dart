import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planmate/CreateProject/Create/Controller/create_project_controller.dart';
import 'package:planmate/CreateProject/Presentation/project_screen.dart';
import 'package:planmate/Models/project_model.dart';

// --- UI Constants for consistent design ---
const _primaryColor = Color(0xFF8B5CF6);
const _backgroundColor = Color(0xFFf9f4ef);
const _textColor = Color(0xFF1F2937);
const _hintColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);
const _errorColor = Color(0xFFEF4444);

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
      context: context,
      onStateChanged: () => setState(() {}),
      onSuccess: _onCreateSuccess,
      onError: _onCreateError,
    );
  }

  void _onCreateSuccess(ProjectModel project) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectScreenDetail(project: project),
      ),
    );
  }

  void _onCreateError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to create project. Please try again.'),
        backgroundColor: _errorColor,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // --- Helper widget for section headers for reusability ---
  Widget _buildSectionHeader(String title) {
    return RichText(
      text: TextSpan(
        text: title,
        style: GoogleFonts.chakraPetch(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF001858),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        
        elevation: 0,
        backgroundColor: Colors.transparent, // Make it blend with the body
        iconTheme: const IconThemeData(
          color: _textColor,
        ), // Ensure back arrow is visible
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + insets),
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Project Name Section =====
                _buildSectionHeader('Project Name'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.nameController,
                  maxLength: 50,
                  decoration: InputDecoration(
                    hintText: 'e.g., Mobile App Redesign',
                    hintStyle: const TextStyle(color: _hintColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _primaryColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _errorColor,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _errorColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    errorText: controller.nameError,
                    counterText: '',
                  ),
                  onChanged: (_) {
                    if (controller.nameError != null) {
                      setState(() => controller.nameError = null);
                    }
                  },
                ),
                const SizedBox(height: 28),

                // ===== Icon Picker Section =====
                _buildSectionHeader('Choose Icon'),
                if (controller.iconError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    controller.iconError!,
                    style: const TextStyle(
                      color: _errorColor,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232946),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          controller.iconError != null
                              ? _errorColor
                              : _borderColor,
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              4, // Adjust number of icons per row
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: controller.iconOptions.length,
                    itemBuilder: (context, index) {
                      final icon = controller.iconOptions[index];
                      final isSelected =
                          controller.selectedIconPath == icon['path'];
                      return GestureDetector(
                        onTap:
                            () => controller.selectIcon(
                              icon['key']!,
                              icon['path']!,
                            ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? _primaryColor
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
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildCreateButton(),
    );
  }

  // --- Extracted button widget for cleaner build method ---
  Widget _buildCreateButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed:
                controller.isLoading ? null : controller.createProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
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
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
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
    );
  }
}
