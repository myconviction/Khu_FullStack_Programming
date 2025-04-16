import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'announcement_detail_screen.dart';

class Announcement {
  final String title;
  final String date;
  final String content;

  Announcement({required this.title, required this.date, required this.content});

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json['title'],
      date: json['date'],
      content: json['content'],
    );
  }
}

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  AnnouncementsScreenState createState() => AnnouncementsScreenState();
}

class AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Announcement> announcements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8080/announcements'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    if (mounted) {
      setState(() {
        announcements = data.map((e) => Announcement.fromJson(e)).toList();
        isLoading = false;
      });
    }
  } else {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load announcements: ${response.body}')),
      );
    }
  }
}

  void _showAnnouncementDetail(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailScreen(
          announcement: announcement,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항',
          style: TextStyle(
            fontSize: 20.0, // AppBar 제목의 텍스트 크기
            fontWeight: FontWeight.bold, // 글꼴 두께를 bold로 설정
            color: Colors.white, // 텍스트 색깔을 흰색으로 설정
          ),),
        backgroundColor: Colors.blue, //배경 색을 파랑으로 설정
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Stack(
                children: [
                  // 배경 이미지
                  Positioned.fill(
                    child: Image.asset(
                      'assets/announcement1.jpeg',

                      fit: BoxFit.cover,
                    ),
                  ),
                  // 공지사항 목록
                  Positioned(
                    top: 160,
                    left: 25,
                    right: 32,
                    bottom: 50,
                    child: ListView.builder(
                      itemCount: announcements.length > 10 ? 10 : announcements.length,
                      itemBuilder: (context, index) {
                        final announcement = announcements[index];
                        return GestureDetector(
                          onTap: () => _showAnnouncementDetail(announcement),
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      announcement.title.length > 15
                                          ? '${announcement.title.substring(0, 15)}...'
                                          : announcement.title,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold, // 가시성을 위한 bold체
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 3),
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      announcement.date,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold, // 가시성을 위한 bold체
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}





