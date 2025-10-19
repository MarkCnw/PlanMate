import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  Future<void> _submitSupportRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      await FirebaseFirestore.instance.collection('support_messages').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Your message has been sent successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to send message: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _launchEmail() async {
    final Uri email = Uri(
      scheme: 'mailto',
      path: 'chinnawong554@gmail.com',
      query: 'subject=PlanMate Support Request',
    );
    if (await canLaunchUrl(email)) await launchUrl(email);
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9F9FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📨 Contact Support',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'If you have any issues or feedback, please fill out the form below.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),
            const SizedBox(height: 24),

            // =============== FORM ===============
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    icon: Symbols.person,
                    label: 'Full Name',
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Please enter your name'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    icon: Symbols.mail,
                    label: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'Please enter your email';
                      if (!val.contains('@'))
                        return 'Invalid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _messageController,
                    icon: Symbols.chat,
                    label: 'Message',
                    maxLines: 5,
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Please enter a message'
                                : null,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _submitSupportRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child:
                          _isSending
                              ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                              : const Text(
                                'Send Message',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Divider(thickness: 1.2),
            const SizedBox(height: 20),

            // Alternative contact options
            _buildSupportCard(
              icon: Symbols.mail,
              color: const Color(0xFF6366F1),
              title: 'Contact Email',
              subtitle: 'chinnawong554@gmail.com',
              onTap: _launchEmail,
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                'Made with 💙 by Mark Cnw\n© 2025 All Rights Reserved',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============== UI HELPERS ===============

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6)),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
      ),
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
