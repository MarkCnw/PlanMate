import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planmate/Selection%20Profile/Models/avatar_data.dart';
import 'package:planmate/Selection%20Profile/Widgets/avatar_widget.dart';
import 'package:planmate/Home/presentation/home.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? selectedAvatar;
  
  // Constants - ย้ายไปไว้ที่ top level หรือ config file
  static const List<AvatarData> _availableAvatars = [
    AvatarData(
      name: "Ironman",
      imagePath: 'assets/avatar/avatar1.png',
    ),
    AvatarData(
      name: "Batman", 
      imagePath: 'assets/avatar/avatar3.png',
    ),
    AvatarData(
      name: "Spiderman",
      imagePath: 'assets/avatar/avatar2.png',
    ),
  ];

  // Colors - ควรย้ายไปไว้ใน theme หรือ constants
  static const Color _primaryColor = Color(0xFFF6874E);
  static const double _spacing = 40.0;

  void _onAvatarSelected(String avatarName) {
    setState(() {
      selectedAvatar = avatarName;
    });
  }

  void _onConfirmPressed() {
    if (selectedAvatar == null) return;
    
    final selectedAvatarData = _availableAvatars.firstWhere(
      (avatar) => avatar.name == selectedAvatar,
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(selectedAvatar: selectedAvatarData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: _spacing),
                    _buildHeaderImage(),
                    const SizedBox(height: 35),
                    _buildAvatarSelection(),
                    const SizedBox(height: 60),
                    _buildConfirmButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "Who is Yoddu?",
      style: GoogleFonts.chakraPetch(
        fontSize: 37,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHeaderImage() {
    return SvgPicture.asset(
      'assets/avatar/team_profile.svg',
      width: 300,
      height: 300,
    );
  }

  Widget _buildAvatarSelection() {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: _availableAvatars.map((avatar) {
        return AvatarItem(
          imagePath: avatar.imagePath,
          name: avatar.name,
          isSelected: selectedAvatar == avatar.name,
          onTap: () => _onAvatarSelected(avatar.name),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmButton() {
    final isEnabled = selectedAvatar != null;
    
    return SizedBox(
      width: 330,
      height: 60,
      child: ElevatedButton(
        onPressed: isEnabled ? _onConfirmPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.black : Colors.grey,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          "Confirm",
          style: GoogleFonts.chakraPetch(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}