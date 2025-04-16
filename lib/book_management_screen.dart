import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'book_detail_screen.dart'; 

class BookManagementScreen extends StatefulWidget {
  final String action;

  const BookManagementScreen({super.key, required this.action});

  @override
  BookManagementScreenState createState() => BookManagementScreenState();
}

class BookManagementScreenState extends State<BookManagementScreen> {
  final TextEditingController _titleController = TextEditingController();
  List<dynamic> books = [];
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    fetchBooks(); // 초기 화면 로드 시 모든 책 가져오기.
  }

  // 도서 검색
  Future<void> fetchBooks() async {
    setState(() => isProcessing = true);

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/books/search?title=${_titleController.text}'),
      );
      if (!mounted) return; // 활성 상태 확인
      if (response.statusCode == 200) {
        setState(() {
          books = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching books: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _refreshBooks() {
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 나타날 때 줌인되어 레이아웃이 변경되지 않도록 설정
      appBar: AppBar(
        title: const Text('Book Management'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/빈칸용2.jpeg', // 
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 70, // 전체 UI를 아래로 내리기 위해 top 위치를 조정
            left: 5,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '책 제목 검색',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchBooks,
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        final bool isRented = book['rented'] == true;

                        return ListTile(
                          title: Text(
                            book['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Rented: ${isRented ? "Yes" : "No"}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookDetailsScreen(book: book),
                                ),
                              );
                              if (result == true) {
                                _refreshBooks(); // 책 상태가 변경되면 정보를 다시 받아옴
                              }
                            },
                            child: const Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}














