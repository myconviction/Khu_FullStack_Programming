import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'user_info_clinet_have.dart';

class MySeatScreen extends StatefulWidget {
  const MySeatScreen({super.key});
  @override
  MySeatScreenState createState() => MySeatScreenState();
}

class MySeatScreenState extends State<MySeatScreen> {
  String readingRoom = '';
  String seatNumber = '';
  bool isLoading = true;

  // 텍스트 위치 조정을 위한 변수
  double readingRoomTop = 30;
  double readingRoomLeft = 50.0;
  double seatNumberTop = 150.0;
  double seatNumberLeft = 50.0;

  @override
  void initState() {
    super.initState();
    fetchReservedSeat();
  }

  Future<void> fetchReservedSeat() async {
  try {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/seats?userId=$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      bool found = false;

      for (var seat in data) {
        if (seat['reservedBy'] == userId) {
          int seatId = (seat['row'] - 1) * 10 + seat['column'];
          if (seatId >= 1 && seatId <= 140) {
            if (mounted) {
              setState(() {
                if (seatId <= 80) {
                  readingRoom = '제1열람실';
                } else {
                  readingRoom = '제2열람실';
                }
                seatNumber = '$seatId번 발권 대기 중';
                isLoading = false;
              });
            }
            found = true;
            break;
          }
        }
      }

      if (!found) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching seat information: ${response.body}')),
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
              'assets/내 자리표.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 194,
            left: 40,
            child: Text(
              '             $readingRoom',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 224,
            left: 80,
            child: Text(
              '     $seatNumber',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


