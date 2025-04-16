
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/잠깐_보여주는_화면.jpg',
          fit: BoxFit.cover, // 이미지를 전체 화면에 꽉 채우기
          width: double.infinity, 
          height: double.infinity, 
        ),
      ),
    );
  }
}

