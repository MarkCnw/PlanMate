import 'package:flutter/material.dart';

class ProjectSectionConfig {
  // Heights
  static const double emptyStateHeight = 250.0;
  static const double projectListHeight = 180.0;
  static const double loadingErrorHeight = 180.0;
  
  // Empty State
  static const double emptyStateSvgHeight = 150.0;
  static const EdgeInsets emptyStatePadding = EdgeInsets.all(20);
  static const double emptyStateContainerHeightFactor = 0.4;
  
  // Project List
  static const double cardWidth = 2.0;
  static const double cardHeight = 160.0;
  static const EdgeInsets projectListPadding = EdgeInsets.symmetric(horizontal: 10);
  static const double cardSpacing = 12.0;
  
  // Styling
  static const BorderRadius containerBorderRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(16));
  
  // Colors
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color emptyStateGradientStart = Color(0xFFF6F0FF);
  static const Color emptyStateGradientEnd = Colors.white;
}