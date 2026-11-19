import 'package:flutter/material.dart';
import 'blog_theme.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: blogPaper,
    child: Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (_, size) => Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: size.maxHeight * .42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE9A36B), Color(0xFFD76A35)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    ),
  );
}
