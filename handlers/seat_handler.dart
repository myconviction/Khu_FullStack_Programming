import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:mongo_dart/mongo_dart.dart';

// 좌석 정보 조회
Future<Response> getSeatsHandler(Request request, DbCollection seatsCollection) async {
  var seats = await seatsCollection.find().toList();
  return Response.ok(jsonEncode(seats));
}
 // 특정 좌석 상태 확인
Future<Response> seatStatusHandler(Request request, DbCollection seatsCollection) async {
  var seatId = request.url.queryParameters['seatId'];
  if (seatId != null) {
    var seat = await seatsCollection.findOne(where.eq('seatId', seatId));
    if (seat != null) {
      return Response.ok(jsonEncode(seat));
    }
  }
  return Response.notFound('Seat not found');
}
 // 좌석 예약
Future<Response> reserveSeatHandler(Request request, DbCollection seatsCollection) async {
  var content = await request.readAsString();
  var data = jsonDecode(content);
// 해당 좌석 찾기
  var seat = await seatsCollection.findOne(where.eq('seatId', data['seatId']));
  if (seat == null) {
    return Response.notFound('Seat not found');
  }
// 이미 예약된 좌석인지 검증 + 편의를 위하여 유저 1명당 좌석 1개만 예약하게 만들지 않고 여러 좌석을 예약하게 만들었음. 그래야 눈이 즐겁다
  if (seat['reserved'] == true) {
    return Response.forbidden('Seat already reserved');
  }
  // 좌석 상태 업데이트
  await seatsCollection.update(
    where.eq('seatId', data['seatId']),
    modify.set('reserved', true).set('reservedBy', data['userId']),
  );
  // 업데이트된 좌석 정보를 다시 몽고 db서버에 잇는 좌석정보와 비교해서 검증.
  var updatedSeat = await seatsCollection.findOne(where.eq('seatId', data['seatId']));
  if (updatedSeat != null && updatedSeat['reserved'] == true && updatedSeat['reservedBy'] == data['userId']) {
    return Response.ok('Seat reserved');
  }
   // 위의 조건을 만족하지 못하면 예약 실패 응답.
  return Response.internalServerError(body: 'Reservation failed');
}

// 좌석 예약 취소
Future<Response> cancelReservationHandler(Request request, DbCollection seatsCollection) async {
  var content = await request.readAsString();
  var data = jsonDecode(content);
  // 해당 좌석 찾기
  var seat = await seatsCollection.findOne(where.eq('seatId', data['seatId']));
  if (seat == null) {
    return Response.notFound('Seat not found');
  }
  // 해당 사용자가 예약했는지 검증. 빌린사람만 해당 좌석을 반납하게 해야지
  if (seat['reservedBy'] != data['userId']) {
    return Response.forbidden('Reservation not owned by user');
  }
  // 좌석 상태를 업데이트및 예약 취소
  await seatsCollection.update(
    where.eq('seatId', data['seatId']).eq('reservedBy', data['userId']),
    modify.set('reserved', false).unset('reservedBy'),
  );
  // 업데이트된 좌석 정보를 다시 몽고 db서버에 잇는 좌석정보와 비교해서 검증.
  var updatedSeat = await seatsCollection.findOne(where.eq('seatId', data['seatId']));
  if (updatedSeat != null && updatedSeat['reserved'] == false && updatedSeat['reservedBy'] == null) {
    return Response.ok('Reservation cancelled');
  }
  // 모든 조건을 만족하지 못한 경우 오류 응답
  return Response.internalServerError(body: 'Cancellation failed');
}

// 제 1열람실, 제 2열람실의 남은 좌석 계산
Future<Response> getReservedCountHandler(Request request, DbCollection seatsCollection) async {
  int reservedCountRoom1 = 0;
  int reservedCountRoom2 = 0;

  var seats = await seatsCollection.find().toList();

  for (int i = 0; i < seats.length; i++) {
    var seat = seats[i];
    int seatNumber = i + 1;
    // 좌석 번호는 1부터 시작하므로 인덱스에 1을 더함 모든 좌석은 1번~140번까지 존재. 
    //reservedCountRoom1은 1 ~ 80번좌석 까지, reservedCountRoom2는 81 ~ 140번 좌석
    if (seatNumber >= 1 && seatNumber <= 80 && seat['reserved'] == true) {
      reservedCountRoom1++;
    } else if (seatNumber >= 81 && seatNumber <= 140 && seat['reserved'] == true) {
      reservedCountRoom2++;
    }
  }
  return Response.ok(jsonEncode({
    'reservedCountRoom1': reservedCountRoom1,
    'reservedCountRoom2': reservedCountRoom2,
  }));
}
