import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    elevation: 6,
    shadowColor: const Color(0x223C2115),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: SizedBox(width: 360, child: child),
    ),
  );
}
