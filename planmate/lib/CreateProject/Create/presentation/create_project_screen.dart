import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planmate/CreateProject/Create/Controller/create_project_controller.dart';
import 'package:planmate/CreateProject/Presentation/project_screen.dart';
import 'package:planmate/Models/project_model.dart';

// --- UI Constants (สีเดิม + ปรับโทน) ---
const _primaryColor = Color(0xFF8B5CF6);
const _backgroundColor = Color(0xFFf9f4ef);
const _textColor = Color(0xFF1F2937);
const _hintColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);
const _errorColor = Color(0xFFEF4444);
const _cardNavy = Color(0xFF232946);

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
      MaterialPageRoute(builder: (_) => ProjectScreenDetail(project: project)),
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

  // ---------- Small UI helpers ----------
  Widget _title(String t, {String? sub}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t,
          style: GoogleFonts.chakraPetch(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF001858),
            height: 1.1,
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 6),
          Text(
            sub,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ],
    );
  }

  Widget _section(String t) {
    return Text(
      t,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0E1B3D),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final name = controller.nameController.text.trim();
    final iconPath = controller.selectedIconPath;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'New Project',
          style: GoogleFonts.inter(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: _textColor),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + insets),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Preview Card ----------
                Container(
                  decoration: BoxDecoration(
                    color: _cardNavy,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _cardNavy.withOpacity(.18),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // left: text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // pill tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white.withOpacity(.22)),
                              ),
                              child: Text(
                                'Preview',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(.95),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name.isEmpty ? 'Project Name' : name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                letterSpacing: .2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose an icon you love. You can change it later.',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFb8c1ec),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // right: icon box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(.25)),
                        ),
                        child: iconPath == null
                            ? Icon(Icons.folder_open_rounded, size: 56, color: Colors.white.withOpacity(.9))
                            : Image.asset(iconPath, width: 56, height: 56, fit: BoxFit.contain),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ---------- Header copy ----------
                _title('Let’s set up your project', sub: 'Name it and pick an icon.'),

                const SizedBox(height: 18),

                // ---------- Project Name ----------
                _section('Project Name'),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.nameController,
                  maxLength: 50,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'e.g., Mobile App Redesign',
                    hintStyle: const TextStyle(color: _hintColor),
                    prefixIcon: const Icon(Icons.edit_outlined, color: _hintColor),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _errorColor, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _errorColor, width: 2),
                    ),
                    errorText: controller.nameError,
                  ),
                  onChanged: (_) {
                    if (controller.nameError != null) {
                      setState(() => controller.nameError = null);
                    } else {
                      setState(() {}); // อัปเดต preview
                    }
                  },
                ),

                const SizedBox(height: 20),

                // ---------- Icon picker ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _section('Choose Icon'),
                    if (controller.iconError != null)
                      Text(
                        controller.iconError!,
                        style: GoogleFonts.inter(color: _errorColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: controller.iconError != null ? _errorColor : _borderColor,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // แถวละ 4 ไอคอน ดูทันสมัยขึ้น
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: controller.iconOptions.length,
                    itemBuilder: (context, index) {
                      final icon = controller.iconOptions[index];
                      final isSelected = controller.selectedIconPath == icon['path'];

                      return InkWell(
                        onTap: () => controller.selectIcon(icon['key']!, icon['path']!),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryColor.withOpacity(.10) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? _primaryColor : _borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _primaryColor.withOpacity(.15),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Image.asset(icon['path']!, width: 28, height: 28, fit: BoxFit.contain),
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
      bottomNavigationBar: _buildCreateButton(), // logic เดิม
    );
  }

  // ---------- Create button (คง logic เดิม) ----------
  Widget _buildCreateButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isLoading ? null : controller.createProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: controller.isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Text('Creating...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  )
                : const Text('Create Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
