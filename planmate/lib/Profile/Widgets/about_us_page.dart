import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF1A1A2E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9F9FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ------------------------
            // Logo / App Identity
            // ------------------------
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFEDE9FE),
                backgroundImage: const AssetImage(
                  'assets/avatar/avatar3.png',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'PlanMate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your smart companion for task planning & tracking',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1.2),
            const SizedBox(height: 24),

            // ------------------------
            // Developer Section
            // ------------------------
            const Text(
              '👩‍💻 Developer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5F3FF), Color(0xFFF9F9FB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    // child: Image.asset(
                    //   'assets/images/dev_photo.jpg',
                    //   width: 70,
                    //   height: 70,
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mark Cnw',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mobile Developper ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Nakhon Ratchasima, Thailand',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ------------------------
            // Credits Section
            // ------------------------
            const Text(
              '⚙️ Powered By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildPowerCard(
                  icon: Symbols.flutter,
                  label: 'Flutter SDK',
                  color: Colors.blue.shade400,
                  url: 'https://flutter.dev',
                ),
                _buildPowerCard(
                  imagePath: 'assets/icons/icons8-dart.svg',
                  label: 'Dart Language',
                  color: Colors.cyan.shade600,
                  url: 'https://dart.dev',
                ),
                _buildPowerCard(
                  imagePath: 'assets/icons/firebase.svg',
                  label: 'Firebase',
                  color: Colors.orange.shade400,
                  url: 'https://firebase.google.com',
                ),
                _buildPowerCard(
                  icon: Symbols.passkey,
                  label: 'Google Auth',
                  color: Colors.redAccent,
                  url: 'https://developers.google.com/identity',
                ),
                _buildPowerCard(
                  imagePath: 'assets/icons/icons8-google-fonts.svg',
                  label: 'Google Fonts',
                  color: Colors.indigo,
                  url: 'https://fonts.google.com',
                ),
                _buildPowerCard(
                  imagePath: 'assets/icons/firestore-hero_2x.png',
                  label: ' Firestore Database',
                  color: Colors.deepPurple.shade400,
                  url: 'https://firebase.google.com/products/firestore',
                ),
                _buildPowerCard(
                  icon: Symbols.cloud,
                  label: 'Cloud Functions',
                  color: Colors.teal.shade400,
                  url: 'https://firebase.google.com/products/functions',
                ),
                _buildPowerCard(
                  imagePath: 'assets/icons/font-awesome-brand.svg',
                  label: 'Font Awesome',
                  color: Colors.black87,
                  url: 'https://fontawesome.com',
                ),
                _buildPowerCard(
                  imagePath: 'assets/icons/pixelture.svg',
                  label: 'PixelTrue UI Kits',
                  color: Colors.pinkAccent,
                  url: 'https://www.pixeltrue.com/free-ui-kits',
                ),
                _buildPowerCard(
                  icon: Symbols.palette,
                  label: 'Happy Hues',
                  color: Colors.deepOrangeAccent,
                  url: 'https://www.happyhues.co/',
                ),
              ],
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 12),

            Text(
              'Made with 💙 by Mark Cnw\n© 2025 All Rights Reserved',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for powered-by cards
  Widget _buildPowerCard({
    IconData? icon,
    String? imagePath,
    required String label,
    required Color color,
    required String url,
  }) {
    return InkWell(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              imagePath.endsWith('.svg')
                  ? SvgPicture.asset(imagePath, width: 32, height: 32)
                  : Image.asset(
                    imagePath,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  )
            else if (icon != null)
              Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
