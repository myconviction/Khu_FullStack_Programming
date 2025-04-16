import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'user_info_clinet_have.dart';

class Seat {
  final String seatId;
  final int row;
  final int column;
  final bool reserved;

  Seat({
    required this.seatId,
    required this.row,
    required this.column,
    required this.reserved,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatId: json['seatId'],
      row: json['row'],
      column: json['column'],
      reserved: json['reserved'],
    );
  }
}

class SeatScreen extends StatefulWidget {
  const SeatScreen({super.key});
  @override
  SeatScreenState createState() => SeatScreenState();
}

class SeatScreenState extends State<SeatScreen> {
  List<Seat> seats = [];
  bool isProcessing = false;
  final backgroundImage = 'assets/경희대 좌석1.png'; // 배경 이미지 경로

  // 첫 번째 테이블의 위치 좌표 (기준)
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
        setState(() {
          seats = data.map((e) => Seat.fromJson(e)).toList();
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
                  width: 700, 
                  height: 700, 
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundImage),
                      fit: BoxFit.contain, // 이미지를 화면에 맞게 조정 
                      alignment: Alignment.center, 
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 233,
                  child: Column(
                    children: [
                      for (var rowGroup = 0; rowGroup < 2; rowGroup++) // 2행 그룹
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0), // 그룹 사이의 세로 간격
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var colGroup = 0; colGroup < 5; colGroup++) // 5열 그룹
                                Padding(
                                  padding: const EdgeInsets.only(right: 56.7), // 그룹 사이의 가로 간격
                                  child: Column(
                                    children: [
                                      for (var row = 0; row < 4; row++) // 각 그룹 내 4행
                                        Row(
                                          children: [
                                            for (var col = 0; col < 2; col++) // 각 그룹 내 2열
                                              GestureDetector(
                                                onTap: () {
                                                  int index = (rowGroup * 4 + row) * 10 + (colGroup * 2 + col);
                                                  if (seats.isNotEmpty && seats[index].reserved) {
                                                    cancelReservation(seats[index].seatId);
                                                  } else {
                                                    reserveSeat(seats[index].seatId);
                                                  }
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 2.8,
                                                    vertical: seatVerticalSpacing / 2,
                                                  ),
                                                  width: 39.4, // 좌석의 너비
                                                  height: 43.0, // 좌석의 높이
                                                  decoration: BoxDecoration(
                                                    color: seats.isNotEmpty && seats[(rowGroup * 4 + row) * 10 + (colGroup * 2 + col)].reserved ? Colors.red[900] : Colors.transparent,
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



























