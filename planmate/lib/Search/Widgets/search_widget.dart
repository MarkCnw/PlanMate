import 'dart:async';
import 'package:flutter/material.dart';

class ProjectSearchWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onSearchChanged;
  final VoidCallback? onClear;
  final Duration debounceDuration;

  const ProjectSearchWidget({
    super.key,
    this.hintText = 'Search projects...',
    required this.onSearchChanged,
    this.onClear,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<ProjectSearchWidget> createState() => _ProjectSearchWidgetState();
}

class _ProjectSearchWidgetState extends State<ProjectSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }

      // Debounce: ยกเลิกตัวเก่า แล้วเริ่มนับใหม่ทุกครั้งที่พิมพ์
      _debounce?.cancel();
      _debounce = Timer(widget.debounceDuration, () {
        if (!mounted) return;
        widget.onSearchChanged(_controller.text);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _hasText = false);
    // แจ้งค้นหาว่างทันทีหลังเคลียร์ + callback onClear ถ้ามี
    widget.onSearchChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade400,
            size: 22,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF001858),
        ),
      ),
    );
  }
}
