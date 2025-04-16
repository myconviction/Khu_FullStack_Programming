import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddBookScreen2 extends StatefulWidget {
  final String title;
  final String author;
  final int publishedYear;
  final String genre;

  const AddBookScreen2({
    super.key,
    required this.title,
    required this.author,
    required this.publishedYear,
    required this.genre,
  });

  @override
  AddBookScreen2State createState() => AddBookScreen2State();
}

class AddBookScreen2State extends State<AddBookScreen2> {
  final TextEditingController descriptionController = TextEditingController();
  String selectedImage = '';
  String imageA = 'assets/imageA.jpg'; 
  String imageB = 'assets/imageB.jpg'; 
  int maxLines = 3; // 최대 줄 수를 설정해서 더이상 설명란을 쓰지 못하게 함.

  @override
  void initState() {
    super.initState();
    descriptionController.addListener(() {
      setState(() {
        // 최대 줄 수를 넘으면 키보드를 자동으로 닫음 이게 아니면 수동으로 키보드 내려야함.
        if (descriptionController.text.split('\n').length > maxLines) {
          FocusScope.of(context).unfocus();
        }
      });
    });
  }

  Future<void> addBook() async {
    if (selectedImage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    try {
      final imageBytes = await DefaultAssetBundle.of(context).load(selectedImage);
      final base64Image = base64Encode(imageBytes.buffer.asUint8List());

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/add_book'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': widget.title,
          'author': widget.author,
          'publishedYear': widget.publishedYear,
          'genre': widget.genre,
          'description': descriptionController.text,
          'image': base64Image,
        }),
      );

      if (!mounted) return; // 활성 상태 확인 vscode 오류 제거용
      if (response.statusCode == 200) {
        // 책 추가 성공 시 필드에 적혀있던 데이터 지우기
        descriptionController.clear();
        setState(() {
          selectedImage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added successfully')),
        );
        Navigator.pop(context); // 이전 화면으로 이동
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding book: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }

  void _showImageSelector(String imagePath) async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageSelectorScreen(imagePath: imagePath),
      ),
    );

    if (selected != null && selected) {
      setState(() {
        selectedImage = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 나타날 때 화면이 줌인되서 레이아웃이 변경되지 않도록 설정한다
      appBar: AppBar(title: const Text('Add Book - Step 2')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/빈칸용2.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned( // Description 필드의 좌표
            top: 100, 
            left: 50, 
            right: 50,
            child: SingleChildScrollView(
              child: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                maxLines: null, // 줄 수 무제한
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          Positioned( // 버튼의 좌표
            top: 250, 
            left: 50, 
            right: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showImageSelector('assets/sample_book1.jpg'),
                  child: const Text('Select Image A'),
                ),
                ElevatedButton(
                  onPressed: () => _showImageSelector('assets/sample_book2.jpg'),
                  child: const Text('Select Image B'),
                ),
              ],
            ),
          ),
          Positioned( // 이미지 미리보기 좌표
            top: 350, 
            left: 50, 
            right: 50,
            child: selectedImage.isNotEmpty
                ? Image.asset(
              selectedImage,
              height: 100, 
            )
                : Container(), // 이미지가 선택되지 않았을 때의 상태. 빈 컨테이너 표시
          ),
          Positioned( // Add Book 버튼 좌표
            top: 500, 
            left: 50, 
            right: 50,
            child: ElevatedButton(
              onPressed: addBook,
              child: const Text('Add Book'),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageSelectorScreen extends StatelessWidget {
  final String imagePath;

  const ImageSelectorScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Image'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context, true),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}








