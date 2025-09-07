import 'package:flutter/material.dart';

class ElegantShimmerTextManual extends StatefulWidget {
  final String headline;
  final String? subtext;
  final TextStyle? headlineStyle;
  final TextStyle? subtextStyle;

  const ElegantShimmerTextManual({
    super.key,
    required this.headline,
    this.subtext,
    this.headlineStyle,
    this.subtextStyle,
  });

  @override
  State<ElegantShimmerTextManual> createState() => _ElegantShimmerTextManualState();
}

class _ElegantShimmerTextManualState extends State<ElegantShimmerTextManual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineCtl;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _shineCtl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(); // วิ่งวน
    _t = CurvedAnimation(parent: _shineCtl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _shineCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseHeadline = TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: .25,
    ).merge(widget.headlineStyle);

    final baseSub = TextStyle(
      color: const Color(0xFFb8c1ec),
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ).merge(widget.subtextStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _t,
          builder: (context, _) {
            // center = 0..1, กระจายประกายเล็กน้อยรอบจุดกลาง
            final center = _t.value;
            const spread = 0.20;
            final start = (center - spread).clamp(0.0, 1.0);
            final end   = (center + spread).clamp(0.0, 1.0);

            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white,
                  Colors.white.withOpacity(0.12),
                ],
                stops: [start, center, end], // ไล่ผ่านตัวอักษร
              ).createShader(rect),
              child: Text(widget.headline, style: baseHeadline),
            );
          },
        ),
        if (widget.subtext != null) ...[
          const SizedBox(height: 10),
          Text(widget.subtext!, style: baseSub),
        ],
      ],
    );
  }
}
