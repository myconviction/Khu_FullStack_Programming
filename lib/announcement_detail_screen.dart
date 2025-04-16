import 'package:flutter/material.dart';
import 'announcement_screen.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항 세부 정보'),
      ),
      body: Center(
        child: Stack(
          children: [
            // 배경 이미지
            Positioned.fill(
              child: Image.asset(
                'assets/announcement_detail.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            // 공지사항 세부 내용
            Positioned(
              top: 160,
              left: 25,
              right: 32,
              bottom: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              announcement.title,
                              style:const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
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
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // 제목과 본문 사이 간격 넓히기
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        announcement.content,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 20, // 최대 20줄
                        overflow: TextOverflow.ellipsis, // 줄이 넘어가면 '...'로 표시 될것
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



