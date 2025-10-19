import 'package:flutter/material.dart';
import 'package:planmate/Profile/Widgets/about_us_page.dart';
import 'package:planmate/Profile/Widgets/help_support_page.dart';
import 'package:planmate/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final displayName = context.select<AuthProvider, String>(
      (p) => p.displayName,
    );
    final email = context.select<AuthProvider, String>((p) => p.email);
    final photoURL = context.select<AuthProvider, String?>(
      (p) => p.photoURL,
    );
    final isLoading = context.select<AuthProvider, bool>(
      (p) => p.isLoading,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header with user info
              _UserProfileCard(
                displayName: displayName,
                email: email,
                photoURL: photoURL,
              ),
              const SizedBox(height: 30),

              // Menu Grid
              _MenuGrid(),

              // const SizedBox(height: 30),

              // // Settings Section
              // _SettingsSection(),
              const SizedBox(height: 30),

              // Logout Button
              _LogoutButton(isLoading: isLoading),

              // Error Display
              Selector<AuthProvider, String?>(
                selector: (_, p) => p.error,
                builder: (context, error, _) {
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        error,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.signOut();

    final err = auth.error;
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $err'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      auth.clearError();
    }
  }
}

class _UserProfileCard extends StatelessWidget {
  final String displayName;
  final String email;
  final String? photoURL;

  const _UserProfileCard({
    required this.displayName,
    required this.email,
    this.photoURL,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  (photoURL != null && photoURL!.isNotEmpty)
                      ? NetworkImage(photoURL!)
                      : null,
              child:
                  (photoURL == null || photoURL!.isEmpty)
                      ? Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey.shade600,
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 16),

          // User Info
          if (displayName.isNotEmpty) ...[
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],

          if (email.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.info_outline,
        title: 'About Us',
        color: const Color(0xFF4facfe),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutUsPage()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        color: const Color(0xFF43e97b),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpSupportPage()),
          );
        },
      ),

      _MenuItem(
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy Policy',
        color: const Color(0xFF6c5ce7),
        onTap: () => _showPrivacyPolicy(context),
      ),
      _MenuItem(
        icon: Icons.description_outlined,
        title: 'Terms of Service',
        color: const Color(0xFFfd79a8),
        onTap: () => _showTermsOfService(context),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: menuItems.length,
      itemBuilder:
          (context, index) => _MenuItemCard(item: menuItems[index]),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('About PlanMate'),
            content: const Text(
              'PlanMate is your ultimate planning companion. '
              'Organize your tasks, schedule events, and achieve your goals with ease.\n\n'
              'Version 1.0.0\n'
              'Developed with ❤️ for productivity enthusiasts.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Help & Support'),
            content: const Text(
              'Need help? We\'re here for you!\n\n'
              '• Email: support@planmate.app\n'
              '• FAQ: Available in app settings\n'
              '• Live Chat: Coming soon\n\n'
              'Response time: Within 24 hours',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Privacy Policy'),
            content: const SingleChildScrollView(
              child: Text(
                'We respect your privacy and are committed to protecting your personal data.\n\n'
                'Data Collection:\n'
                '• We only collect necessary information for app functionality\n'
                '• No personal data is shared with third parties\n'
                '• All data is encrypted and stored securely\n\n'
                'For the full privacy policy, visit our website.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Terms of Service'),
            content: const SingleChildScrollView(
              child: Text(
                'By using PlanMate, you agree to these terms:\n\n'
                '• Use the app responsibly and legally\n'
                '• Respect other users and our community guidelines\n'
                '• Do not misuse or attempt to hack the app\n'
                '• We reserve the right to update these terms\n\n'
                'For complete terms, visit our website.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}

class _MenuItemCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool isLoading;

  const _LogoutButton({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFff6b6b), Color(0xFFee5a24)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFff6b6b).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.signOut();

    final err = auth.error;
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $err'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      auth.clearError();
    }
  }
}
