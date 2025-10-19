  import 'package:flutter/material.dart';
  import 'package:material_symbols_icons/symbols.dart';

  class PrivacyPolicyPage extends StatelessWidget {
    const PrivacyPolicyPage({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Policy'),
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
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.shield_lock,
                        size: 48,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: ${_getLastUpdateDate()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Introduction
              _buildSection(
                icon: Symbols.info,
                title: 'Introduction',
                content:
                    'At PlanMate, we take your privacy seriously. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.',
              ),

              // Information We Collect
              _buildSection(
                icon: Symbols.database,
                title: 'Information We Collect',
                content:
                    'We collect information that you provide directly to us when you:',
                children: [
                  _buildBulletPoint(
                    'Create an account using Google Sign-In',
                  ),
                  _buildBulletPoint('Create projects and tasks'),
                  _buildBulletPoint('Use features of the application'),
                  _buildBulletPoint('Contact our support team'),
                ],
              ),

              // Types of Data Collected
              _buildSection(
                icon: Symbols.person_outline,
                title: 'Types of Data Collected',
                children: [
                  _buildSubSection(
                    'Personal Information',
                    'Name, email address, profile picture (from Google account)',
                  ),
                  _buildSubSection(
                    'Usage Data',
                    'Projects, tasks, completion status, and activity logs',
                  ),
                  _buildSubSection(
                    'Device Information',
                    'Device type, operating system, and unique device identifiers',
                  ),
                  _buildSubSection(
                    'Notification Data',
                    'FCM tokens for push notifications',
                  ),
                ],
              ),

              // How We Use Your Information
              _buildSection(
                icon: Symbols.settings,
                title: 'How We Use Your Information',
                content: 'We use the information we collect to:',
                children: [
                  _buildBulletPoint('Provide and maintain our services'),
                  _buildBulletPoint('Personalize your experience'),
                  _buildBulletPoint(
                    'Send you notifications about your tasks',
                  ),
                  _buildBulletPoint('Improve our application'),
                  _buildBulletPoint('Communicate with you about updates'),
                  _buildBulletPoint('Ensure security and prevent fraud'),
                ],
              ),

              // Data Security
              _buildSection(
                icon: Symbols.security,
                title: 'Data Security',
                content:
                    'We implement appropriate technical and organizational security measures to protect your personal information. Your data is encrypted and stored securely using Firebase services. However, no method of transmission over the Internet is 100% secure.',
              ),

              // Data Sharing
              _buildSection(
                icon: Symbols.share,
                title: 'Data Sharing and Disclosure',
                content:
                    'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:',
                children: [
                  _buildBulletPoint('With your consent'),
                  _buildBulletPoint('To comply with legal obligations'),
                  _buildBulletPoint('To protect our rights and safety'),
                  _buildBulletPoint(
                    'With service providers (e.g., Firebase, Google)',
                  ),
                ],
              ),

              // Your Rights
              _buildSection(
                icon: Symbols.verified_user,
                title: 'Your Rights',
                content: 'You have the right to:',
                children: [
                  _buildBulletPoint('Access your personal data'),
                  _buildBulletPoint('Correct inaccurate data'),
                  _buildBulletPoint('Request deletion of your data'),
                  _buildBulletPoint('Export your data'),
                  _buildBulletPoint('Opt-out of notifications'),
                ],
              ),

              // Data Retention
              _buildSection(
                icon: Symbols.schedule,
                title: 'Data Retention',
                content:
                    'We retain your personal information for as long as your account is active or as needed to provide you services. You can request deletion of your account and data at any time through the app settings.',
              ),

              // Children\'s Privacy
              _buildSection(
                icon: Symbols.child_care,
                title: 'Children\'s Privacy',
                content:
                    'PlanMate is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately.',
              ),

              // Changes to Policy
              _buildSection(
                icon: Symbols.update,
                title: 'Changes to This Privacy Policy',
                content:
                    'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date. You are advised to review this Privacy Policy periodically.',
              ),

              // Contact
              _buildSection(
                icon: Symbols.mail,
                title: 'Contact Us',
                content:
                    'If you have any questions about this Privacy Policy, please contact us:',
                children: [
                  _buildContactInfo('Email', 'chinnawong554@gmail.com'),
                  _buildContactInfo('Developer', 'Widenex Studio'),
                  _buildContactInfo('Location', 'Bangkok, Thailand'),
                ],
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '© 2025 PlanMate. All rights reserved.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildSection({
      required IconData icon,
      required String title,
      String? content,
      List<Widget>? children,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF8B5CF6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),
            if (content != null) ...[
              const SizedBox(height: 12),
              Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ],
            if (children != null) ...[
              const SizedBox(height: 12),
              ...children,
            ],
          ],
        ),
      );
    }

    Widget _buildBulletPoint(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildSubSection(String title, String content) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildContactInfo(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 16),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                '$label:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      );
    }

    String _getLastUpdateDate() {
      return 'January 19, 2025';
    }
  }
