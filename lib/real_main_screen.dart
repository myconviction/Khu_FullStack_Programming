import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'dart:developer' as developer;
import 'user_info_screen.dart';
import 'book_management_screen.dart';
import 'add_book_screen1.dart';
import 'empty_screen.dart';
import 'user_info_clinet_have.dart';
import 'login_screen.dart';
import 'qr_code_screen.dart';
import 'announcement_screen.dart';
import 'seat_count_screen.dart';
import 'my_seat_screen.dart';

class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // 배경 이미지
              Positioned.fill(
                child: Image.asset(
                  'assets/메인화면 예비3.png',
                  fit: BoxFit.contain,
                ),
              ),
              //  아까 로그인 단계에서 입력한 user 이름출력.' 클릭x 이름만 print되서 나옴
              Positioned(
                top: screenHeight * 0.143,
                left: screenWidth * 0.1,
                width: screenWidth * 0.3,
                height: screenHeight * 0.045,
                child: Container(
              //    color: Colors.pink.withOpacity(0.5),
                  alignment: Alignment.centerLeft, // 텍스트를 왼쪽 정렬
                  padding: const EdgeInsets.only(left: 8.0), // 텍스트를 왼쪽으로 이동
                  child: Text(
                    '${userProvider.username} 님',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // 'user_info' 클릭 영역. (정보수정) 
              Positioned(
                top: screenHeight * 0.143,
                left: screenWidth * 0.5,
                width: screenWidth * 0.25,
                height: screenHeight * 0.045,
                child: GestureDetector(
                  onTap: () {
                    developer.log('정보수정 clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserInfoScreen()),
                    );
                  },
                  child: Container(
                 //   color: Colors.pink.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: const Text(
                      '정보수정',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // logout 버튼. main.dart로 이동
              Positioned(
                top: screenHeight * 0.149,
                left: screenWidth * 0.79,
                width: screenWidth * 0.17,
                height: screenHeight * 0.03,
                child: GestureDetector(
                  onTap: () {
                    developer.log('특정 영역 clicked');
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const UserScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: Container(
                    color: Colors.transparent, 
                  ),
                ),
              )


              ,
              // '좌석예약' 영역
              Positioned(
                top: screenHeight * 0.28,
                left: screenWidth * 0.04,
                width: screenWidth * 0.605,
                height: screenHeight * 0.155,
                child: GestureDetector(
                  onTap: () {
                    developer.log('좌석예약 clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SeatCountScreen()),
                    );
                  },
                  child: Container(
                    color: Colors.red.withOpacity(0.3), 
                  ),
                ),
              ),
              // '메시지' 영역  (미구현, 빈 화면으로 이동)
              Positioned(
                top: screenHeight * 0.28,
                left: screenWidth * 0.66,
                width: screenWidth * 0.3,
                height: screenHeight * 0.155,
                child: GestureDetector(
                  onTap: () {
                    developer.log('메시지 clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmptyScreen()),
                    );
                  },
                  child: Container(
                    color: Colors.green.withOpacity(0.3), 
                  ),
                ),
              ),
              // '내 자리' 영역
              Positioned(
                top: screenHeight * 0.444,
                left: screenWidth * 0.04,
                width: screenWidth * 0.3,
                height: screenHeight * 0.156,
                child: GestureDetector(
                  onTap: () {
                    developer.log('내 자리 clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MySeatScreen()),
                    );
                  },
                  child: Container(
                    color: Colors.blue.withOpacity(0.3), 
                  ),
                ),
              ),
              // '그룹 스터디실' 영역 (미구현, 빈 화면으로 이동)
              Positioned(
                top: screenHeight * 0.444,
                left: screenWidth * 0.356,
                width: screenWidth * 0.605,
                height: screenHeight * 0.156,
                child: GestureDetector(
                  onTap: () {
                    developer.log('그룹 스터디실 clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmptyScreen()),
                    );
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.1), 
                  ),
                ),
              ),
              // '도서 추가' 영역 
              Positioned(
                top: screenHeight * 0.604,
                left: screenWidth * 0.04,
                width: screenWidth * 0.3,
                height: screenHeight * 0.156,
                child: GestureDetector(
                  onTap: () {
                    developer.log('도서관 SNS clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddBookScreen1()),
                    );
                  },
                  child: Container(
                    color: Colors.purple.withOpacity(0.3), 
                  ),
                ),
              ),
              // '도서관 홈페이지' 클릭 영역 (책을 예약하고 정보를 볼수 있는 영역으로 이동)
              Positioned(
                top: screenHeight * 0.604,
                left: screenWidth * 0.356,
                width: screenWidth * 0.605,
                height: screenHeight * 0.156,
                child: GestureDetector(
                  onTap: () {
                    developer.log('도서관 홈페이지 clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BookManagementScreen(action: 'Manage Books')),
                    );
                  },
                  child: Container(
                    color: Colors.red.withOpacity(0.3), 
                  ),
                ),
              ),
              // '도서관 모바일 이용증' 영역
              Positioned(
                top: screenHeight * 0.768,
                left: screenWidth * 0.04,
                width: screenWidth * 0.3,
                height: screenHeight * 0.156,
                child: GestureDetector(
                  onTap: () {
                    developer.log('도서관 모바일 이용증 clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QRCodeScreen()),
                    );
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.1), 
                  ),
                ),
              ),
              // '공지사항' 영역
              Positioned(
                top: screenHeight * 0.768,
                left: screenWidth * 0.35,
                width: screenWidth * 0.3,
                height: screenHeight * 0.156,
                child: GestureDetector(
                  onTap: () {
                    developer.log('공지사항 clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnnouncementsScreen()),
                    );
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.1), 
                  ),
                ),
              ),
              // '이용안내' 영역 (미구현, 빈 화면으로 이동)
              Positioned(
                top: screenHeight * 0.768,
                left: screenWidth * 0.659,
                width: screenWidth * 0.3,
                height: screenHeight * 0.156,
                child: GestureDetector(
                  onTap: () {
                    developer.log('이용안내 clicked');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmptyScreen()),
                    );
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.1), 
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}




















