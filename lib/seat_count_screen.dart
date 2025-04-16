import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'seat_screen.dart';
import 'seat_screen2.dart';
class SeatCountScreen extends StatefulWidget {
  const SeatCountScreen({super.key});
  @override
  SeatCountScreenState createState() => SeatCountScreenState();
}

class SeatCountScreenState extends State<SeatCountScreen> {
  int availableSeatsRoom1 = 0;
  int availableSeatsRoom2 = 0;
  bool isLoading = true;

  // 텍스트 위치 조정을 위한 변수
  double topOffsetRoom1 = 150.0;
  double leftOffsetRoom1 = 0.0;
  double topOffsetRoom2 = 200.0;
  double leftOffsetRoom2 = 0.0;

  @override
  void initState() {
    super.initState();
    fetchSeatCounts();
  }

  Future<void> fetchSeatCounts() async {
  try {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/seats/reserved_count'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          availableSeatsRoom1 = 80 - (data['reservedCountRoom1'] as int);
          availableSeatsRoom2 = 60 - (data['reservedCountRoom2'] as int);
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching seat counts: ${response.body}')),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('경희대학교 도서관 이용증'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/열람실 선택.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 190,
            left: 230,
            child: Text(
              '${80-availableSeatsRoom1}' '              $availableSeatsRoom1',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 235,
            left: 230,
            child: Text(
              '${60-availableSeatsRoom2}' '              $availableSeatsRoom2',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SeatScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // 버튼 배경 투명하게 설정
                shadowColor: Colors.transparent, // 버튼 그림자 투명하게 설정
              ),
              child: const Text(
                '제1열람실',
                style: TextStyle(color: Colors.transparent), // 텍스트 투명하게 설정
              ),
            ),
          ),
          Positioned(
            top: 225,
            left: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SeatScreen2()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // 버튼 배경 투명하게 설정
                shadowColor: Colors.transparent, // 버튼 그림자 투명하게 설정
              ),
              child: const Text(
                '제2열람실',
                style: TextStyle(color: Colors.transparent), // 텍스트 투명하게 설정
              ),
            ),
          ),
        ],
      ),
    );
  }
}

