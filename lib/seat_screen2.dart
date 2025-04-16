import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'user_info_clinet_have.dart';

class Seat2 {
  final String seatId;
  final int row;
  final int column;
  final bool reserved;

  Seat2({
    required this.seatId,
    required this.row,
    required this.column,
    required this.reserved,
  });

  factory Seat2.fromJson(Map<String, dynamic> json) {
    return Seat2(
      seatId: json['seatId'],
      row: json['row'],
      column: json['column'],
      reserved: json['reserved'],
    );
  }
}

class SeatScreen2 extends StatefulWidget {
  const SeatScreen2({super.key});
  @override
  SeatScreenState2 createState() => SeatScreenState2();
}

class SeatScreenState2 extends State<SeatScreen2> {
  List<Seat2> seats = [];
  bool isProcessing = false;
  final backgroundImage = 'assets/경희대 좌석2.png'; // 배경 이미지 경로

  // 첫 번째 테이블의 위치 좌표 (기본값 설정)
  double firstTableLeft = 100.0;
  double firstTableTop = 50.0;

  // 좌석 간 가로 및 세로 간격
  double seatHorizontalSpacing = 8.0;
  double seatVerticalSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    fetchSeats();
  }

  Future<void> fetchSeats() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/seats'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Seat2> allSeats = data.map((e) => Seat2.fromJson(e)).toList();
        setState(() {
          seats = allSeats.sublist(80, 140); // 81번째부터 140번째까지의 좌석만 사용
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching seats: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }

  Future<void> reserveSeat(String seatId) async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/reserve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'seatId': seatId, 'userId': userId}),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seat reserved successfully')),
        );
        fetchSeats(); // 예약 후 최신 좌석 정보를 다시 불러옴
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }

    setState(() => isProcessing = false);
  }

  Future<void> cancelReservation(String seatId) async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/cancel_reservation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'seatId': seatId, 'userId': userId}),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation cancelled successfully')),
        );
        fetchSeats(); // 취소 후 최신 좌석 정보를 다시 불러옴
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cancellation error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }

    setState(() => isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Seats'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Center(
            child: Stack(
              children: [
                Container(
                  width: 700, // 가로 스크롤을 위해 적절히 넓게 설정
                  height: 700, // 세로 스크롤을 위해 적절히 높게 설정
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundImage),
                      fit: BoxFit.contain, // 이미지가 화면에 맞게 조정되도록 설정
                      alignment: Alignment.topCenter, // 이미지를 상단 중앙에 정렬
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 177,
                  child: Column(
                    children: [
                      for (var rowGroup = 0; rowGroup < 1; rowGroup++) // 1행 그룹
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0), // 그룹 사이의 세로 간격
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var colGroup = 0; colGroup < 5; colGroup++) // 5열 그룹
                                Padding(
                                  padding: const EdgeInsets.only(right: 56.0), // 그룹 사이의 가로 간격
                                  child: Column(
                                    children: [
                                      for (var row = 0; row < 6; row++) // 각 그룹 내 6행
                                        Row(
                                          children: [
                                            for (var col = 0; col < 2; col++) // 각 그룹 내 2열
                                              GestureDetector(
                                                onTap: () {
                                                  int calculatedIndex = (rowGroup * 6 + row) * 10 + (colGroup * 2 + col);
                                                  if (seats.isNotEmpty && calculatedIndex < seats.length && seats[calculatedIndex].reserved) {
                                                    cancelReservation(seats[calculatedIndex].seatId);
                                                  } else {
                                                    reserveSeat(seats[calculatedIndex].seatId);
                                                  }
                                                },
                                                child: Container(
                                                  margin: const 
                                                  EdgeInsets.symmetric(
                                                    horizontal: 2.7,
                                                    vertical: 4,
                                                  ),
                                                  width: 40.4, // 좌석의 너비
                                                  height: 43.0, // 좌석의 높이
                                                  decoration: BoxDecoration(
                                                    color: seats.isNotEmpty && (rowGroup * 6 + row) * 10 + (colGroup * 2 + col) < seats.length && seats[(rowGroup * 6 + row) * 10 + (colGroup * 2 + col)].reserved
                                                        ? Colors.red[900]
                                                        : Colors.transparent,
                                                    border: Border.all(color: Colors.transparent),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}













