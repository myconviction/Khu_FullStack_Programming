import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'real_main_screen.dart';
import 'user_info_clinet_have.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  UserScreenState createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLogin = true;

  Future<void> authenticate(String path) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (!mounted) return;
          Provider.of<UserProvider>(context, listen: false)
              .setUserInfo(data['userId'], _usernameController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_isLogin ? "Login" : "Signup"} successful',
              ),
            ),
          );

          if (_isLogin && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NextScreen()),
            );
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_isLogin ? "Login" : "Signup"} successful')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 나타날 때 화면이 확대되지 않도록 설정
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/login.screen.jpeg', // 사용하고자 하는 이미지의 경로
              fit: BoxFit.cover,
            ),
          ),
          // 숨겨진 학번 입력 필드
          Positioned(
            top: screenHeight * 0.329,
            left: screenWidth * 0.26,
            width: screenWidth * 0.55,
            height: screenHeight * 0.063,
            child: Visibility(
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              visible: false,
              child: TextField(
                focusNode: _usernameFocusNode,
                controller: _usernameController,
                cursorColor: Colors.black, // 커서 색상 설정
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: '학 번',
                  hintStyle: const TextStyle(color: Colors.transparent),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          // 숨겨진 패스워드 입력 필드
          Positioned(
            top: screenHeight * 0.395,
            left: screenWidth * 0.26,
            width: screenWidth * 0.55,
            height: screenHeight * 0.063,
            child: Visibility(
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              visible: false,
              child: TextField(
                focusNode: _passwordFocusNode,
                controller: _passwordController,
                cursorColor: Colors.black, // 커서 색상 설정
                style: const TextStyle(color: Colors.black),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '패스워드',
                  hintStyle: const TextStyle(color: Colors.transparent),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          // 학번 텍스트 표시 영역
          Positioned(
            top: screenHeight * 0.329,
            left: screenWidth * 0.26,
            width: screenWidth * 0.55,
            height: screenHeight * 0.063,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(_usernameFocusNode);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  _usernameController.text.isEmpty
                      ? '이름'
                      : _usernameController.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: _usernameController.text.isEmpty
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // 패스워드 텍스트 표시 영역
          Positioned(
            top: screenHeight * 0.395,
            left: screenWidth * 0.26,
            width: screenWidth * 0.55,
            height: screenHeight * 0.063,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  _passwordController.text.isEmpty
                      ? '패스워드'
                      : '*' * _passwordController.text.length,
                  style: TextStyle(
                    fontSize: 16,
                    color: _passwordController.text.isEmpty
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // 회원가입 전환 버튼
          Positioned(
            top: screenHeight * 0.48,
            left: screenWidth * 0.14,
            width: screenWidth * 0.35,
            height: screenHeight * 0.055,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // 배경색 설정
                foregroundColor: Colors.black, // 글자색 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                _isLogin ? '회원가입 전환' : '로그인 전환',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          // 로그인/회원가입 버튼
          Positioned(
            top: screenHeight * 0.48,
            left: screenWidth * 0.49,
            width: screenWidth * 0.35,
            height: screenHeight * 0.055,
            child: ElevatedButton(
              onPressed: () => authenticate(_isLogin ? 'login' : 'signup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // 배경색 설정
                foregroundColor: Colors.black, // 글자색 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                _isLogin ? '로그인' : '회원가입',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




















