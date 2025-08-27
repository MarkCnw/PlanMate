import 'package:flutter/material.dart';
import 'package:planmate/provider/auth_provider.dart';
import 'package:provider/provider.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ฟังเฉพาะค่าแต่ละตัวด้วย select เพื่อลดการรีบิลด์
    final displayName = context.select<AuthProvider, String>((p) => p.displayName);
    final email       = context.select<AuthProvider, String>((p) => p.email);
    final photoURL    = context.select<AuthProvider, String?>((p) => p.photoURL);
    final isLoading   = context.select<AuthProvider, bool>((p) => p.isLoading);

    return Scaffold(
      backgroundColor: const Color(0xFFf9f4ef),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _WelcomeText(),
              const SizedBox(height: 30),
              _UserInfoSection(
                displayName: displayName,
                email: email,
                photoURL: photoURL,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _handleLogout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              // แสดง error ถ้ามี (ฟังเฉพาะ error)
              Selector<AuthProvider, String?>(
                selector: (_, p) => p.error,
                builder: (context, error, _) {
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(error, style: const TextStyle(color: Colors.red)),
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

    // ถ้ามี error ให้แจ้งและเคลียร์
    final err = auth.error;
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $err'), backgroundColor: Colors.red),
      );
      auth.clearError();
    }
    // ไม่ต้อง navigate เอง ให้ AuthWrapper จัดการ
  }
}

class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Congratulations!\nYou have successfully logged in",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  final String displayName;
  final String email;
  final String? photoURL;

  const _UserInfoSection({
    required this.displayName,
    required this.email,
    this.photoURL,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (photoURL != null && photoURL!.isNotEmpty) ...[
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(photoURL!)),
          const SizedBox(height: 10),
        ],
        if (displayName.isNotEmpty) ...[
          Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
        ],
        if (email.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              email,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
