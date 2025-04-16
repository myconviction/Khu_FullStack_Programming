import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:mongo_dart/mongo_dart.dart';

// 공지사항 목록 가져오기
Future<Response> getAnnouncementsHandler(Request request, DbCollection announcementsCollection) async {
  var announcements = await announcementsCollection.find().toList();
  return Response.ok(jsonEncode(announcements));
}
