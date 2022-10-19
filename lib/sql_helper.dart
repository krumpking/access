// import 'package:flutter/foundation.dart';
// import 'package:sqflite/sqflite.dart' as sql;

// class SQLHelper {
//   static Future<void> createTables(sql.Database database) async {
//     await database.execute("""CREATE TABLE items(
//         designation TEXT,
//         first TEXT,
//         last TEXT,
//         phone TEXT,
//         email TEXT,
//         chapter TEXT,
//         paid TEXT,
//         receipt TEXT,
//         date TEXT,
//       )
//       """);
//   }
// // id: the id of a item
// // title, description: name and description of your activity
// // created_at: the time that the item was created. It will be automatically handled by SQLite

//   static Future<sql.Database> db() async {
//     return sql.openDatabase(
//       'registration.db',
//       version: 1,
//       onCreate: (sql.Database database, int version) async {
//         await createTables(database);
//       },
//     );
//   }

//   // Create new item (journal)
//   static Future<int> createItem(
//       String designation,
//       String first,
//       String last,
//       String phone,
//       String email,
//       String chapter,
//       String paid,
//       String receipt,
//       String date) async {
//     final db = await SQLHelper.db();

//     final data = {
//       'designation': designation,
//       'first': first,
//       'last': last,
//       'phone': phone,
//       'email': email,
//       'chapter': chapter,
//       'paid': paid,
//       'receipt': receipt,
//       'date': date
//     };
//     final id = await db.insert('registrations', data,
//         conflictAlgorithm: sql.ConflictAlgorithm.replace);
//     return id;
//   }

//   // Read all items (journals)
//   static Future<List<Map<String, dynamic>>> getItems() async {
//     final db = await SQLHelper.db();
//     return db.query('registrations', orderBy: "date");
//   }

//   // Read a single item by id
//   // The app doesn't use this method but I put here in case you want to see it
//   static Future<List<Map<String, dynamic>>> getItem(String receipt) async {
//     final db = await SQLHelper.db();
//     return db
//         .query('registrations', where: "receipt = ?", whereArgs: [receipt]);
//   }

//   // Create new item (journal)
//   static Future<int> saveItem(
//       String designation,
//       String first,
//       String last,
//       String phone,
//       String email,
//       String chapter,
//       String paid,
//       String receipt,
//       String date) async {
//     final db = await SQLHelper.db();

//     final data = {
//       'designation': designation,
//       'first': first,
//       'last': last,
//       'phone': phone,
//       'email': email,
//       'chapter': chapter,
//       'paid': paid,
//       'receipt': receipt,
//       'date': date
//     };
//     final id = await db.insert('session', data,
//         conflictAlgorithm: sql.ConflictAlgorithm.replace);
//     return id;
//   }
// }
