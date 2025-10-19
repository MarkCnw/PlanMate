// lib/Profile/Widgets/terms_of_service_page.dart

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
                      Symbols.description,
                      size: 48,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Effective date: ${_getEffectiveDate()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Agreement to Terms
            _buildSection(
              icon: Symbols.handshake,
              title: 'Agreement to Terms',
              content:
                  'By accessing or using PlanMate, you agree to be bound by these Terms of Service and all applicable laws and regulations. If you do not agree with any of these terms, you are prohibited from using or accessing this application.',
            ),

            // Description of Service
            _buildSection(
              icon: Symbols.app_registration,
              title: 'Description of Service',
              content:
                  'PlanMate is a task and project management application that helps users organize their work and track progress. The service includes:',
              children: [
                _buildBulletPoint('Project creation and management'),
                _buildBulletPoint('Task tracking and completion'),
                _buildBulletPoint('Progress monitoring'),
                _buildBulletPoint('Activity history'),
                _buildBulletPoint('Push notifications'),
              ],
            ),

            // User Accounts
            _buildSection(
              icon: Symbols.account_circle,
              title: 'User Accounts',
              children: [
                _buildSubSection(
                  'Account Creation',
                  'You must create an account using Google Sign-In to use PlanMate. You are responsible for maintaining the confidentiality of your account credentials.',
                ),
                _buildSubSection(
                  'Account Responsibilities',
                  'You are responsible for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
                ),
                _buildSubSection(
                  'Account Termination',
                  'We reserve the right to terminate or suspend your account at any time for violations of these Terms of Service.',
                ),
              ],
            ),

            // Acceptable Use
            _buildSection(
              icon: Symbols.check_circle,
              title: 'Acceptable Use',
              content: 'You agree NOT to:',
              children: [
                _buildBulletPoint('Use the service for any illegal purpose'),
                _buildBulletPoint('Violate any laws in your jurisdiction'),
                _buildBulletPoint('Infringe upon intellectual property rights'),
                _buildBulletPoint('Upload malicious code or viruses'),
                _buildBulletPoint('Attempt to gain unauthorized access'),
                _buildBulletPoint('Interfere with the proper working of the service'),
                _buildBulletPoint('Use the service to harass or harm others'),
              ],
            ),

            // Intellectual Property
            _buildSection(
              icon: Symbols.copyright,
              title: 'Intellectual Property',
              content:
                  'The service and its original content, features, and functionality are owned by Widenex Studio and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
            ),

            // User Content
            _buildSection(
              icon: Symbols.folder,
              title: 'User Content',
              children: [
                _buildSubSection(
                  'Your Content',
                  'You retain all rights to the content you create in PlanMate (projects, tasks, notes). By using the service, you grant us a license to store and process this content to provide the service.',
                ),
                _buildSubSection(
                  'Content Responsibility',
                  'You are solely responsible for your content. We do not review, verify, or approve user content.',
                ),
                _buildSubSection(
                  'Content Removal',
                  'We reserve the right to remove content that violates these terms or is otherwise objectionable.',
                ),
              ],
            ),

            // Service Availability
            _buildSection(
              icon: Symbols.cloud_sync,
              title: 'Service Availability',
              content:
                  'We strive to provide a reliable service, but we do not guarantee that:',
              children: [
                _buildBulletPoint('The service will be uninterrupted'),
                _buildBulletPoint('The service will be error-free'),
                _buildBulletPoint('Defects will be corrected immediately'),
                _buildBulletPoint('The service will be available at all times'),
              ],
            ),

            // Disclaimers
            _buildSection(
              icon: Symbols.warning,
              title: 'Disclaimers',
              content:
                  'THE SERVICE IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. We do not warrant that:',
              children: [
                _buildBulletPoint('The service will meet your requirements'),
                _buildBulletPoint('Results obtained will be accurate'),
                _buildBulletPoint('Quality of service will meet expectations'),
                _buildBulletPoint('Errors will be corrected'),
              ],
            ),

            // Limitation of Liability
            _buildSection(
              icon: Symbols.shield,
              title: 'Limitation of Liability',
              content:
                  'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.',
            ),

            // Data Backup
            _buildSection(
              icon: Symbols.backup,
              title: 'Data Backup',
              content:
                  'While we take reasonable measures to protect your data, you are responsible for maintaining backup copies of your content. We are not liable for any loss or corruption of data.',
            ),

            // Modifications to Service
            _buildSection(
              icon: Symbols.edit,
              title: 'Modifications to Service',
              content:
                  'We reserve the right to modify or discontinue the service at any time with or without notice. We shall not be liable to you or any third party for any modification, suspension, or discontinuance.',
            ),

            // Updates to Terms
            _buildSection(
              icon: Symbols.update,
              title: 'Updates to Terms',
              content:
                  'We may revise these Terms of Service at any time. By continuing to use PlanMate after changes become effective, you agree to be bound by the revised terms.',
            ),

            // Governing Law
            _buildSection(
              icon: Symbols.gavel,
              title: 'Governing Law',
              content:
                  'These Terms shall be governed by and construed in accordance with the laws of Thailand, without regard to its conflict of law provisions.',
            ),

            // Dispute Resolution
            _buildSection(
              icon: Symbols.balance,
              title: 'Dispute Resolution',
              content:
                  'Any disputes arising from these Terms or your use of the service shall be resolved through good faith negotiation. If negotiation fails, disputes shall be resolved in the courts of Bangkok, Thailand.',
            ),

            // Severability
            _buildSection(
              icon: Symbols.rule,
              title: 'Severability',
              content:
                  'If any provision of these Terms is held to be invalid or unenforceable, the remaining provisions shall continue in full force and effect.',
            ),

            // Contact Information
            _buildSection(
              icon: Symbols.contact_mail,
              title: 'Contact Information',
              content:
                  'For questions about these Terms of Service, please contact:',
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
                child: Column(
                  children: [
                    Text(
                      'By using PlanMate, you acknowledge that you have read and understood these Terms of Service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '© 2025 PlanMate. All rights reserved.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
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
                child: Icon(icon, color: const Color(0xFF8B5CF6), size: 24),
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
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEffectiveDate() {
    return 'January 19, 2025';
  }
}