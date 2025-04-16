import 'package:flutter/material.dart';
import 'add_book_screen2.dart';

class AddBookScreen1 extends StatefulWidget {
  const AddBookScreen1({super.key});

  @override
  AddBookScreen1State createState() => AddBookScreen1State();
}

class AddBookScreen1State extends State<AddBookScreen1> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController publishedYearController = TextEditingController();
  final TextEditingController genreController = TextEditingController();

  void _nextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookScreen2(
          title: titleController.text,
          author: authorController.text,
          publishedYear: int.tryParse(publishedYearController.text) ?? 0,
          genre: genreController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 나타날 때 화면이 줌인되서 레이아웃이 변경되지 않도록 설정한다.
      appBar: AppBar(title: const Text('Add Book - Step 1')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/빈칸용2.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned( // 제목 필드의 좌표
            top: 100, 
            left: 50,  
            right: 50,
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          Positioned( // 저자 필드의 좌표
            top: 200, 
            left: 50, 
            right: 50,
            child: TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          Positioned( // 출판 연도 필드의 좌표
            top: 300, 
            left: 50, 
            right: 50,
            child: TextField(
              controller: publishedYearController,
              decoration: const InputDecoration(
                labelText: 'Published Year',
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Positioned( // 장르 필드의 좌표
            top: 400, 
            left: 50, 
            right: 50,
            child: TextField(
              controller: genreController,
              decoration: const InputDecoration(
                labelText: 'Genre',
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          Positioned( // 버튼의 좌표
            top: 500, 
            left: 50, 
            right: 50,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}










