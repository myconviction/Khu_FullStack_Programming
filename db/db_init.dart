import 'package:mongo_dart/mongo_dart.dart';

late final Db db;

Future<void> initDb() async {
   // MongoDB  연결
  db = Db('mongodb://localhost:27017/libraryApp');
  await db.open();
}
