import 'package:flutter/material.dart';

class SkeletonLoadingScreen extends StatefulWidget {
  const SkeletonLoadingScreen({super.key});

  @override
  State<SkeletonLoadingScreen> createState() => _SkeletonLoadingScreenState();
}

class _SkeletonLoadingScreenState extends State<SkeletonLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  late final Animation<double> _opacity =
  Tween<double>(begin: 0.4, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bone({double width = double.infinity, double height = 16, double radius = 8}) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bone(width: 140, height: 20),
              const SizedBox(height: 24),
              _bone(height: 90, radius: 16),
              const SizedBox(height: 16),
              _bone(width: 200, height: 16),
              const SizedBox(height: 12),
              _bone(width: 260, height: 16),
              const SizedBox(height: 32),
              _bone(height: 60, radius: 12),
              const SizedBox(height: 12),
              _bone(height: 60, radius: 12),
            ],
          ),
        ),
      ),
    );
  }
}