import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_info_clinet_have.dart';
import 'login_screen.dart';
import 'show_just_moment.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Client',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreenHandler(),
    );
  }
}

class SplashScreenHandler extends StatefulWidget {
  const SplashScreenHandler({super.key});

  @override
  SplashScreenHandlerState createState() => SplashScreenHandlerState();
}

class SplashScreenHandlerState extends State<SplashScreenHandler> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    //show_just_moment.dart를 잠깐 호출해서 보여줌.
    return const SplashScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' (구) 경희대 도서관 어플리케이션',
          style: TextStyle(
            fontSize: 20.0, // 글꼴 크기 설정
            fontWeight: FontWeight.bold, // 볼드체 설정
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/first_screen.jpeg'), // 배경 이미지 설정
            fit: BoxFit.cover, // 이미지를 컨테이너 크기에 맞춤
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserScreen()),
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                    fontSize: 16.0, // 버튼 텍스트 글꼴 크기 설정
                    fontWeight: FontWeight.bold, // 버튼 텍스트 볼드체 설정
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


