import 'package:flutter/material.dart';

class GradientColors {
  // Instagram Style Gradients
  static const LinearGradient instagramClassic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF833AB4), // Purple
      Color(0xFFFD1D1D), // Red
      Color(0xFFFCB045), // Orange
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient instagramStory = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF58529), // Orange
      Color(0xFFDD2A7B), // Pink
      Color(0xFF8134AF), // Purple
      Color(0xFF515BD4), // Blue
    ],
  );

  static const LinearGradient instagramModern = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE1306C), // Pink
      Color(0xFFFD1D1D), // Red
      Color(0xFFF77737), // Orange
    ],
  );

  // Spotify Style Gradients
  static const LinearGradient spotifyGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1DB954), // Spotify Green
      Color(0xFF1ED760), // Light Green
      Color(0xFF17A2B8), // Teal
    ],
  );

  static const LinearGradient spotifyDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF121212), // Dark
      Color(0xFF1DB954), // Spotify Green
      Color(0xFF191414), // Spotify Black
    ],
  );

  static const LinearGradient spotifyPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9D4EDD), // Purple
      Color(0xFF7209B7), // Dark Purple
      Color(0xFF1DB954), // Spotify Green
    ],
  );

  // Trendy Modern Gradients
  static const LinearGradient sunsetVibes = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF9A9E), // Light Pink
      Color(0xFFFECAB0), // Peach
      Color(0xFFFFA726), // Orange
    ],
  );

  static const LinearGradient oceanBlue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF667EEA), // Light Blue
      Color(0xFF764BA2), // Purple Blue
    ],
  );

  static const LinearGradient neonGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00F5FF), // Cyan
      Color(0xFF00C9FF), // Light Blue
      Color(0xFF92FE9D), // Light Green
    ],
  );

  static const LinearGradient pinkPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF006E), // Hot Pink
      Color(0xFF8338EC), // Purple
      Color(0xFF3A86FF), // Blue
    ],
  );

  static const LinearGradient fireOrange = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF512F), // Red Orange
      Color(0xFFDD2476), // Pink Red
    ],
  );

  // Radial Gradients
  static const RadialGradient spotifyRadial = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      Color(0xFF1DB954), // Spotify Green
      Color(0xFF121212), // Dark
    ],
  );

  static const RadialGradient instagramRadial = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFFFD1D1D), // Red
      Color(0xFF833AB4), // Purple
      Color(0xFF121212), // Dark
    ],
  );
}

// Example usage widget
class GradientExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gradient Examples'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientColors.instagramClassic,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildGradientCard('Instagram Classic', GradientColors.instagramClassic),
          _buildGradientCard('Instagram Story', GradientColors.instagramStory),
          _buildGradientCard('Spotify Green', GradientColors.spotifyGreen),
          _buildGradientCard('Sunset Vibes', GradientColors.sunsetVibes),
          _buildGradientCard('Ocean Blue', GradientColors.oceanBlue),
          _buildGradientCard('Neon Glow', GradientColors.neonGlow),
          _buildGradientCard('Pink Purple', GradientColors.pinkPurple),
          _buildGradientCard('Fire Orange', GradientColors.fireOrange),
        ],
      ),
    );
  }

  Widget _buildGradientCard(String title, Gradient gradient) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      height: 120,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// How to use in your widgets:

// Container with gradient background
class GradientContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: GradientColors.instagramClassic,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          'Instagram Style',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Button with gradient
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: GradientColors.spotifyGreen,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// App Bar with gradient
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GradientAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: GradientColors.instagramModern,
      ),
      child: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}