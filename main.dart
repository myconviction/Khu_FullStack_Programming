import 'dart:isolate';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:logging/logging.dart';
import 'db/db_init.dart';
import 'db/seat_init.dart';
import 'db/announcement_init.dart';
import 'handlers/auth_handler.dart';
import 'handlers/user_handler.dart';
import 'handlers/seat_handler.dart';
import 'handlers/qr_handler.dart';
import 'handlers/book_handler.dart';
import 'handlers/announcement_handler.dart';

final Logger _logger = Logger('MyApp');

Future<void> startServer(SendPort sendPort) async {
  // 데이터베이스 연결 
  await initDb();
  var usersCollection = db.collection('users');
  var seatsCollection = db.collection('seats');
  var booksCollection = db.collection('books');
  var qrCodesCollection = db.collection('qrCodes');
  var announcementsCollection = db.collection('announcements');

  // 좌석 초기 데이터 삽입 함수 호출
  await insertInitialSeats(seatsCollection);
  // 공지사항 초기 데이터 삽입 함수 호출
  await insertInitialAnnouncements(announcementsCollection);

  // 하나의 서버객체가 모든 기능을 담당
  final router = Router();
  // 회원 가입
  router.post('/signup', (Request request) => signupHandler(request, usersCollection));
  // 로그인
  router.post('/login', (Request request) => loginHandler(request, usersCollection));
  // 사용자 정보 조회
  router.get('/user/info', (Request request) => userInfoHandler(request, usersCollection));
  // 사용자 정보 업데이트
  router.post('/user/update', (Request request) => updateUserHandler(request, usersCollection));
  // 좌석 정보 조회
  router.get('/seats', (Request request) => getSeatsHandler(request, seatsCollection));
  // 특정 좌석 상태 확인
  router.get('/seat/status', (Request request) => seatStatusHandler(request, seatsCollection));
  // 좌석 예약
  router.post('/reserve', (Request request) => reserveSeatHandler(request, seatsCollection));
  // 좌석 반납
  router.post('/cancel_reservation', (Request request) => cancelReservationHandler(request, seatsCollection));
  // 제 1열람실, 제 2열람실의 남은 좌석 계산
  router.get('/seats/reserved_count', (Request request) => getReservedCountHandler(request, seatsCollection));
  // 도서관 모바일 이용증 클릭시 QR 코드 생성
  router.get('/generate_qr', (Request request) => generateQrHandler(request, usersCollection, qrCodesCollection));
  // 도서 검색
  router.get('/books/search', (Request request) => searchBooksHandler(request, booksCollection));
  // 도서 대여
  router.post('/books/rent', (Request request) => rentBookHandler(request, booksCollection));
  // 도서 반납
  router.post('/books/return', (Request request) => returnBookHandler(request, booksCollection));
  // 책 추가
  router.post('/add_book', (Request request) => addBookHandler(request, booksCollection));
  // 공지사항 목록 조회
  router.get('/announcements', (Request request) => getAnnouncementsHandler(request, announcementsCollection));

  // 서버 시작
  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router.call);
  // 모든 인터페이스에 연결가능 설정.
  final server = await io.serve(handler, '0.0.0.0', 8080, shared: true);
  _logger.info('Serving at http://${server.address.host}:${server.port}');
  sendPort.send(null); // 현재 isolate가 준비되었음을 알리는 신호
}

void main() async {
  Logger.root.onRecord.listen((record) {
    var message = '${record.level.name}: ${record.time}: ${record.message}';
     // vscode의 경고문인 로깅 중복 방지을 위해
    if (!Logger.root.isLoggable(record.level)) {
      _logger.info(message);
    }
  });

  final receivePort = ReceivePort();
  final isolates = <Isolate>[];

  for (int i = 0; i < 4; i++) { // 원하는 isolate 수 4개 설정
    isolates.add(await Isolate.spawn(startServer, receivePort.sendPort));
  }

  int readyIsolates = 0;
  await for (var _ in receivePort) {
    readyIsolates++;
    if (readyIsolates == 4) { // 모든 isolate가 준비되었다. 현재 4개의 서버 thread
      break;
    }
  }

  _logger.info('4 isolates are ready');
}





