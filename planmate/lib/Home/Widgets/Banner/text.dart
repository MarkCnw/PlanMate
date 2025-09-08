import 'package:flutter/material.dart';
import 'dart:math' as math;

// 1. 🔥 เอฟเฟกต์ไฟลุกไหม้ (Fire Effect)
class FireText extends StatefulWidget {
  final String text;
  final TextStyle style;
  
  const FireText({super.key, required this.text, required this.style});

  @override
  State<FireText> createState() => _FireTextState();
}

class _FireTextState extends State<FireText> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: const [
                Color(0xFFff4757), // แดง
                Color(0xFFffa502), // ส้ม
                Color(0xFFffd32a), // เหลือง
                Color(0xFFf1c40f), // เหลืองอ่อน
              ],
              stops: [
                0.0,
                (_animation.value * 0.3).clamp(0.0, 1.0),
                (_animation.value * 0.7).clamp(0.0, 1.0),
                1.0,
              ],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(
                  color: const Color(0xFFff4757).withOpacity(0.7),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 2. 🌈 เอฟเฟกต์รุ้ง (Rainbow Effect)
class RainbowText extends StatefulWidget {
  final String text;
  final TextStyle style;
  
  const RainbowText({super.key, required this.text, required this.style});

  @override
  State<RainbowText> createState() => _RainbowTextState();
}

class _RainbowTextState extends State<RainbowText> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final progress = _controller.value;
            return LinearGradient(
              begin: Alignment(-1.0 + progress * 2, 0.0),
              end: Alignment(1.0 + progress * 2, 0.0),
              colors: const [
                Color(0xFFe74c3c), // แดง
                Color(0xFFf39c12), // ส้ม
                Color(0xFFf1c40f), // เหลือง
                Color(0xFF2ecc71), // เขียว
                Color(0xFF3498db), // น้ำเงิน
                Color(0xFF9b59b6), // ม่วง
                Color(0xFFe91e63), // ชมพู
              ],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}

// 3. ⚡ เอฟเฟกต์ฟ้าผ่า (Lightning Effect)
class LightningText extends StatefulWidget {
  final String text;
  final TextStyle style;
  
  const LightningText({super.key, required this.text, required this.style});

  @override
  State<LightningText> createState() => _LightningTextState();
}

class _LightningTextState extends State<LightningText> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Text(
          widget.text,
          style: widget.style.copyWith(
            color: Color.lerp(
              const Color(0xFF00d4ff),
              Colors.white,
              _glowAnimation.value,
            ),
            shadows: [
              Shadow(
                color: const Color(0xFF00d4ff).withOpacity(_glowAnimation.value),
                blurRadius: 20 * _glowAnimation.value,
                offset: const Offset(0, 0),
              ),
              Shadow(
                color: Colors.white.withOpacity(_glowAnimation.value * 0.8),
                blurRadius: 10 * _glowAnimation.value,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 4. 🎭 เอฟเฟกต์ไล่โทน 3D (Gradient 3D Effect)
class Gradient3DText extends StatefulWidget {
  final String text;
  final TextStyle style;
  
  const Gradient3DText({super.key, required this.text, required this.style});

  @override
  State<Gradient3DText> createState() => _Gradient3DTextState();
}

class _Gradient3DTextState extends State<Gradient3DText> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // เงา
            Transform.translate(
              offset: const Offset(3, 3),
              child: Text(
                widget.text,
                style: widget.style.copyWith(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            // ข้อความหลัก
            ShaderMask(
              shaderCallback: (bounds) {
                final progress = _controller.value;
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(const Color(0xFF667eea), const Color(0xFF764ba2), progress)!,
                    Color.lerp(const Color(0xFF764ba2), const Color(0xFFf093fb), progress)!,
                    Color.lerp(const Color(0xFFf093fb), const Color(0xFF667eea), progress)!,
                  ],
                ).createShader(bounds);
              },
              child: Text(
                widget.text,
                style: widget.style.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF667eea).withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// 5. 🌟 เอฟเฟกต์ดาวระยิบระยับ (Starry Effect)
class StarryText extends StatefulWidget {
  final String text;
  final TextStyle style;
  
  const StarryText({super.key, required this.text, required this.style});

  @override
  State<StarryText> createState() => _StarryTextState();
}

class _StarryTextState extends State<StarryText> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    
    _generateStars();
    _controller.repeat();
  }

  void _generateStars() {
    final random = math.Random();
    for (int i = 0; i < 12; i++) {
      _stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        delay: random.nextDouble(),
        size: random.nextDouble() * 3 + 2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // ข้อความหลัก
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFF4a90e2),
                    Color(0xFF7b68ee),
                    Color(0xFFffd700),
                  ],
                ).createShader(bounds);
              },
              child: Text(
                widget.text,
                style: widget.style.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFffd700).withOpacity(0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            
            // ดวงดาว
            ..._stars.map((star) {
              final progress = (_controller.value + star.delay) % 1.0;
              final twinkle = math.sin(progress * math.pi * 4) * 0.5 + 0.5;
              
              return Positioned(
                left: star.x * 280,
                top: star.y * 50,
                child: Transform.rotate(
                  angle: progress * math.pi * 2,
                  child: Opacity(
                    opacity: twinkle,
                    child: Icon(
                      Icons.star,
                      size: star.size,
                      color: const Color(0xFFffd700),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class Star {
  final double x, y, delay, size;
  Star({required this.x, required this.y, required this.delay, required this.size});
}

// 📱 หน้าทดสอบเอฟเฟกต์ทั้งหมด
class TextEffectsDemo extends StatelessWidget {
  const TextEffectsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232946),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FireText(
                text: '🔥 Fire Effect',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              
              const RainbowText(
                text: '🌈 Rainbow Effect',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              
              const LightningText(
                text: '⚡ Lightning Effect',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              
              const Gradient3DText(
                text: '🎭 3D Gradient',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              
              const StarryText(
                text: '🌟 Starry Effect',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}