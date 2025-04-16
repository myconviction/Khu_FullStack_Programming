import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'user_info_clinet_have.dart';

class BookDetailsScreen extends StatefulWidget {
  final dynamic book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  BookDetailsScreenState createState() => BookDetailsScreenState();
}

class BookDetailsScreenState extends State<BookDetailsScreen> {
  late Map<String, dynamic> book;
  String selectedAction = "Rent";

  @override
  void initState() {
    super.initState();
    book = widget.book;
  }

  Future<void> manageBook(String bookId) async {
  final userId = Provider.of<UserProvider>(context, listen: false).userId;
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8080/books/$selectedAction'.toLowerCase()),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'bookId': bookId, 'userId': userId}),
  );

  if (response.statusCode == 200) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$selectedAction successful')),
      );
      setState(() {
        book['rented'] = selectedAction == 'Rent';
      });
      Navigator.pop(context, true); // 책 상태가 변경되었음을 전달
    }
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }
}


  void onActionChanged(String action) {
    setState(() {
      selectedAction = action;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isRented = book['rented'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.memory(base64Decode(book['image']), height: 270), 
            const SizedBox(height: 16),
            Text(
              book['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Author: ${book['author']}', 
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Rented: ${isRented ? "Yes" : "No"}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Published Year: ${book['publishedYear']}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Genre: ${book['genre']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
           const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              book['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedAction,
                  items: const [
                    DropdownMenuItem(value: 'Rent', child: Text('Rent')),
                    DropdownMenuItem(value: 'Return', child: Text('Return')),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      onActionChanged(value);
                    }
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => manageBook(book['_id'].toString()),
                  child: const Text('Action'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




