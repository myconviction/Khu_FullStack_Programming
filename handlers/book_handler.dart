import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:mongo_dart/mongo_dart.dart';

// 도서 검색
Future<Response> searchBooksHandler(Request request, DbCollection booksCollection) async {
  var title = request.url.queryParameters['title'];
  var query = where.exists('title');
// 검색시 전체단어가 아니라 첫글자 이상만 일치해도 검색가능
  if (title != null && title.isNotEmpty) {
    query = query.match('title', title);
  }
// 첫 화면에 진입시, 그리고 검색창에 검색단어를 쓰지않고 검색을 누르면 존재하는 모든 책목록이 나옴.
  var books = await booksCollection.find(query).toList();
  return Response.ok(jsonEncode(books));
}

// 도서 대여
Future<Response> rentBookHandler(Request request, DbCollection booksCollection) async {
  var content = await request.readAsString();
  var data = jsonDecode(content);
 // 책 ID 확인
  var book = await booksCollection.findOne(where.id(ObjectId.fromHexString(data['bookId'])));
  if (book == null) {
    return Response.notFound('Book not found');
  }
// 이미 대여된 상태인지 확인
  if (book['rented'] == true) {
    return Response.forbidden('Book is already rented');
  }
// 책 대여 상태 업데이트
  await booksCollection.update(
    where.eq('_id', ObjectId.fromHexString(data['bookId'])),
    modify.set('rented', true).set('rentedBy', data['userId']),
  );

  return Response.ok('Book rented');
}

// 도서 반납
Future<Response> returnBookHandler(Request request, DbCollection booksCollection) async {
  var content = await request.readAsString();
  var data = jsonDecode(content);

// 책 ID 확인
  var book = await booksCollection.findOne(where.eq('_id', ObjectId.fromHexString(data['bookId'])));
  if (book == null) {
    return Response.notFound('Book not found');
  }
// 이 사용자가 대여한 책이 맞는지 확인(빌린사람이 반납해야)
  if (book['rentedBy'] != data['userId']) {
    return Response.forbidden('This user did not rent the book');
  }
// 책 반납 상태 업데이트
  await booksCollection.update(
    where.eq('_id', ObjectId.fromHexString(data['bookId'])),
    modify.set('rented', false).unset('rentedBy'),
  );

  return Response.ok('Book returned');
}

// 책 추가. 원래 유저수준에서는 없어야 하는 기능같지만, 편의상 책을 요청해서 추가하는걸로 하자
Future<Response> addBookHandler(Request request, DbCollection booksCollection) async {
  var content = await request.readAsString();
  var data = jsonDecode(content);

// 값이 채워져야할 필수 필드 확인
  if (!data.containsKey('title') || !data.containsKey('author')) {
    return Response.badRequest(body: 'Missing title or author');
  }

// '책' 객체의 필드, 그리고 데이터베이스에 저장
  var newBook = {
    'title': data['title'],
    'author': data['author'],
    'publishedYear': data.containsKey('publishedYear') ? data['publishedYear'] : null,
    'genre': data.containsKey('genre') ? data['genre'] : null,
    'description': data['description'],
    'image': data['image']
  };
  await booksCollection.insert(newBook);

  return Response.ok('Book added successfully');
}
