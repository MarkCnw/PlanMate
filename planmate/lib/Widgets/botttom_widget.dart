import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:planmate/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double? swordSize;
  final double? widthButton;
  final double? heightButton;

  const CustomButton({
    super.key,
    required this.onPressed,
    this.backgroundColor,
    required this.swordSize,
    required this.widthButton,
    required this.heightButton,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: backgroundColor ?? AppColors.backgroundOnboarding,
      shape: const CircleBorder(),
      constraints: BoxConstraints.tightFor(
        width: widthButton ?? 56,
        height: heightButton ?? 56,
      ),
      child: SvgPicture.asset(
        'assets/button_onboarding.svg',
        width: swordSize ?? 20,
        height: swordSize ?? 20,
      ),
    );
  }
}
