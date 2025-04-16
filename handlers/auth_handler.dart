import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';

// 회원 가입
Future<Response> signupHandler(Request request, DbCollection usersCollection) async {
  var content = await request.readAsString();
  var data = jsonDecode(content);
// 필수 필드 확인
  if (!data.containsKey('username') || !data.containsKey('password')) {
    return Response.badRequest(body: 'Missing username or password');
  }
// 중복된 사용자 이름 확인
  var existingUser = await usersCollection.findOne(where.eq('username', data['username']));

  if (existingUser != null) {
    return Response.forbidden('Username already exists');
  }
 // 비밀번호 해시화. mongo db서버에 비밀번호는 숫자와 영어의 나열로 나타난다.비밀번호 까먹지말자
  var hashedPassword = sha256.convert(utf8.encode(data['password'])).toString();
  data['password'] = hashedPassword;

 // 사용자 정보 저장
  await usersCollection.insert(data);

  return Response.ok('Signup successful');
}
 // 로그인
Future<Response> loginHandler(Request request, DbCollection usersCollection) async {
  var content = await request.readAsString();
  var data = jsonDecode(content);
  var hashedPassword = sha256.convert(utf8.encode(data['password'])).toString();
// 사용자 이름과 비밀번호 검증
  var user = await usersCollection.findOne(
    where.eq('username', data['username']).eq('password', hashedPassword),
  );

  if (user != null) {
    return Response.ok(jsonEncode({'status': 'success', 'userId': user['_id'].toString()}));
  }
  return Response.forbidden('Invalid credentials');
}
