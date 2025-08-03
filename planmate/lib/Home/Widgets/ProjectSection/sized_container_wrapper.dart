// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SizedContainerWrapper extends StatelessWidget {
  final double height;
  final Widget child;
  const SizedContainerWrapper({
    super.key,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: child);
  }
}
