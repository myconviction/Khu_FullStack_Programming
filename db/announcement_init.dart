import 'package:mongo_dart/mongo_dart.dart';
 // 공지사항용 데이터 삽입용 함수. 
Future<void> insertInitialAnnouncements(DbCollection announcementsCollection) async {
  var initialAnnouncements = <Map<String, dynamic>>[
    {
      'title': '첫 번째 공지사항',
      'date': '2024-01-01',
      'content': '첫 번째 공지사항의 본문 내용입니다. 반갑습니다. 저는 2020105637 컴퓨터공학과 학생 우상혁이라고 합니다 지금 이 문장은 연습용 텍스트입니다.'
    },
    {
      'title': '두 번째 공지사항',
      'date': '2024-02-01',
      'content': '두 번째 공지사항의 본문 내용입니다. 안녕하세요 반가워요 잘가세요 스마트폰'
    },
    // 더 많은 공지사항을 추가 가능
  ];
  //처음 앱을 시작하고, 몽고 db에 데이터가 없다면 삽입.
  var existingAnnouncements = await announcementsCollection.find().toList();
  if (existingAnnouncements.isEmpty) {
    await announcementsCollection.insertAll(initialAnnouncements);
  }
}
