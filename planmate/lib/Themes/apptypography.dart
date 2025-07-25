import 'dart:ui';

class AppTypography {
  static const String primaryFont = 'Inter';
  static const String secondaryFont =
      'SF Pro Display'; // iOS-style alternative

  // Navigation Typography
  static TextStyle navLabel(bool isSelected) => TextStyle(
    fontSize: 12,
    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
    fontFamily: 'Inter', // Modern, clean font for English
    letterSpacing: 0.3,
  );

  // Other Typography Styles
  static final TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFamily: primaryFont,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static final TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFont,
    letterSpacing: -0.4,
    height: 1.3,
  );

  static final TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFont,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static final TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: primaryFont,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static final TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: primaryFont,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static final TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: primaryFont,
    letterSpacing: 0.4,
    height: 1.3,
  );

  static final TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFont,
    letterSpacing: 0.2,
  );
}
