import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'user_info_clinet_have.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  UserInfoScreenState createState() => UserInfoScreenState();
}

class UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController birthplaceController = TextEditingController();
  final TextEditingController otherInfoController = TextEditingController();

  late String username;
  

  @override
  void initState() {
    super.initState();
    username = Provider.of<UserProvider>(context, listen: false).username;
    
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
   final userId = //'663a4417b8b766e8f4000000';
  Provider.of<UserProvider>(context, listen: false).userId;
  String temp = userId.replaceAll('ObjectId("', '').replaceAll('")', '');
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/user/info?userId=$temp')
      );
      if (!mounted) return; // 활성 상태 확인
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          departmentController.text = data['department'] ?? '';
          ageController.text = data['age']?.toString() ?? '';
          birthplaceController.text = data['birthplace'] ?? '';
          otherInfoController.text = data['otherInfo'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user info: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }

  Future<void> updateUserInfo() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    String temp = userId.replaceAll('ObjectId("', '').replaceAll('")', '');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/user/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': //userId
          temp
          ,
          'updateData': {
            'department': departmentController.text,
            'age': int.tryParse(ageController.text),
            'birthplace': birthplaceController.text,
            'otherInfo': otherInfoController.text,
          },
        }),
      );
      if (!mounted) return; // 활성 상태 확인
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User info updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user info: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: username),
              decoration: const InputDecoration(labelText: 'Username'),
              enabled: false, // 읽기 전용 필드
            ),
            TextField(
              controller: departmentController,
              decoration: const InputDecoration(labelText: 'Department'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: birthplaceController,
              decoration: const InputDecoration(labelText: 'Birthplace'),
            ),
            TextField(
              controller: otherInfoController,
              decoration: const InputDecoration(labelText: 'Other Info'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUserInfo,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}



