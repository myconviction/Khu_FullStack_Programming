import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '해당 기능은 제거되었습니다.',
          style: TextStyle(
            fontSize: 20.0, // AppBar 타이틀의 텍스트 크기 
            fontWeight: FontWeight.bold, //  bold체
            color: Colors.white, // 타이틀 색상을 흰색
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 버튼을 누를 때 이전 화면으로 돌아가도록 설정
          },
        ),
        backgroundColor: Colors.blue, // AppBar의 배경색 파란색
      ),
      body: const Center(
        child: Text(
          '해당 기능은 제거되었습니다.',
          style: TextStyle(
            fontSize: 24.0, // 본문 텍스트 크기
            color: Colors.black, // 텍스트 색상을 검은색
          ),
        ),
      ),
    );
  }
}
