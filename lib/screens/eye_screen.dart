// Windows-safe stub — camera not available
import 'package:flutter/material.dart';

class EyeScreen extends StatelessWidget {
  const EyeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(
        child: Text('📱 모바일 전용 기능입니다.\n안드로이드에서 이용해주세요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(
        child: Text('🃏 TikiTaka',
          style: TextStyle(color: Color(0xFFD4A574), fontSize: 24)),
      ),
    );
  }
}
