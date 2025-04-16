import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:mongo_dart/mongo_dart.dart';

// 사용자 정보 조회
Future<Response> userInfoHandler(Request request, DbCollection usersCollection) async {
  var userId = request.url.queryParameters['userId'];
  if (userId != null) {
    var user = await usersCollection.findOne(where.id(ObjectId.fromHexString(userId)));
    if (user != null) {
      return Response.ok(jsonEncode(user));
    }
  }
  return Response.notFound('User not found');
}
 // 사용자 정보 업데이트
Future<Response> updateUserHandler(Request request, DbCollection usersCollection) async {
  var content = await request.readAsString();
  var data = jsonDecode(content);
  var userId = data['userId'];
  var updateData = data['updateData'];
 // ModifierBuilder를 사용하여 사용자의 각 필드 업데이트
  var modifier = ModifierBuilder();

  if (updateData.containsKey('department')) {
    modifier.set('department', updateData['department']);
  }
  if (updateData.containsKey('age')) {
    modifier.set('age', updateData['age']);
  }
  if (updateData.containsKey('birthplace')) {
    modifier.set('birthplace', updateData['birthplace']);
  }
  if (updateData.containsKey('otherInfo')) {
    modifier.set('otherInfo', updateData['otherInfo']);
  }
//업데이트한 사용자 정보를 진짜 적용해 사용자 정보 업데이트 실행
  await usersCollection.update(
    where.id(ObjectId.fromHexString(userId)),
    modifier,
  );

  return Response.ok('Update successful');
}
