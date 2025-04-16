import 'package:mongo_dart/mongo_dart.dart';

// 도서관 좌석의 초기 데이터 삽입용 함수. 먼저 140개의 좌석을 만든다. 열이 10, 행이 14인데, 각 행당 좌석이 10개인것은, 모든 열람실이 동일하다.
Future<void> insertInitialSeats(DbCollection seatsCollection) async {
  var initialSeats = <Map<String, dynamic>>[];

  for (int row = 1; row <= 14; row++) {
    for (int col = 1; col <= 10; col++) {
      initialSeats.add({
        'seatId': 'row${row}_col$col',
        'row': row,
        'column': col,
        'reserved': false,
      });
    }
  }
  //처음 앱을 시작하고, 몽고 db에 데이터가 없다면 삽입.
  var existingSeats = await seatsCollection.find().toList();
  if (existingSeats.isEmpty) {
    await seatsCollection.insertAll(initialSeats);
  }
}
