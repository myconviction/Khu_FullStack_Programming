import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_info_clinet_have.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});
  @override
  QRCodeScreenState createState() => QRCodeScreenState();
}

class QRCodeScreenState extends State<QRCodeScreen> {
  String _qrCodeUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQRCode();
  }

  Future<void> _fetchQRCode() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.userId;

  if (userId.isNotEmpty) {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/generate_qr?userId=$userId'));

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          _qrCodeUrl = response.body;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load QR code: ${response.body}')),
        );
      }
    }
  } else {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is empty')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final username = userProvider.username;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library QR Code', style: TextStyle(
          fontSize: 20.0, // AppBar 타이틀의 텍스트 크기 설정
          fontWeight: FontWeight.bold, // 글꼴 두께를 bold로 설정
          color: Colors.white, // 타이틀 색상을 흰색으로 설정
        ),
        ),

        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Stack(
          children: [
            // 배경 이미지
            Positioned.fill(
              child: Image.asset(
                'assets/mk5.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // QR 코드
            Column(
              children: [
                const SizedBox(height: 265), // 이미지 위쪽 패딩 조절
                Center(
                  child: Container(
                    width: 130,
                    height: 120,
                    color: Colors.white,
                    child: Image.memory(base64Decode(_qrCodeUrl)),
                  ),
                ),
                const SizedBox(height: 110),
                Positioned(
                  left: 000100,
                  child: Container(
                    width: 250, // 이름 컨테이너의 너비
                    height: 30, // 이름 컨테이너의 높이
                    color: Colors.orange,
                    child: Text(
                      '이름 | $username',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


