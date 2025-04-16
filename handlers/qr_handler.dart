import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:qr/qr.dart';
import 'package:image/image.dart';

// 도서관 모바일 이용증 클릭시 QR 코드 생성
Future<Response> generateQrHandler(Request request, DbCollection usersCollection, DbCollection qrCodesCollection) async {
  var userId = request.url.queryParameters['userId'];
  if (userId == null) {
    return Response.badRequest(body: 'User ID is required');
  }
  // ObjectId 포맷 제거(몽고 db에 있는 형식을 맞춰줌)
  var parsedId = userId.replaceAll('ObjectId("', '').replaceAll('")', '');
  if (parsedId.length != 24) {
    return Response.badRequest(body: 'Invalid user ID format');
  }

  var user = await usersCollection.findOne(where.id(ObjectId.fromHexString(parsedId)));
  if (user == null) {
    return Response.notFound('User not found');
  }
  // 유저 정보로 QR 코드 생성 (유저이름과 유저id로 생성. 즉 한번생성되면 변하지않음)
  var qrData = '${user['username']}|${user['_id']}';
  var qrCode = QrCode(4, QrErrorCorrectLevel.L);
  qrCode.addData(qrData);
  // QR 코드를 이미지로 변환
  final qrImage = QrImage(qrCode);
  const size = 200; // 화면에 보이는 이미지 크기
  final moduleSize = (size / qrCode.moduleCount).ceil();
  final image = Image(size, size);
  fill(image, getColor(255, 255, 255));  // 주변을 흰색으로 설정

  for (int x = 0; x < qrCode.moduleCount; x++) {
    for (int y = 0; y < qrCode.moduleCount; y++) {
      if (qrImage.isDark(y, x)) {
        fillRect(image, x * moduleSize, y * moduleSize, (x + 1) * moduleSize, (y + 1) * moduleSize, getColor(0, 0, 0));
      }
    }
  }
   // 이미지를 PNG 형식으로 인코딩
  final png = encodePng(image);
  // Base64 인코딩된 이미지 데이터 반환
  final encoded = base64Encode(png);
 // QR 코드 데이터를 MongoDB에 저장
  await qrCodesCollection.update(
    where.eq('userId', userId),
    modify.set('qrCode', encoded),
    upsert: true,
  );

  return Response.ok(encoded, headers: {'Content-Type': 'image/png'});
}
