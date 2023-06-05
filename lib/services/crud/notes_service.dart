import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    //make sure owner exists in the database with the correct id
    if (dbUser != owner) {
      throw throw CouldNotFindUser();
    }
    const text = '';
    final noteId = await db.insert(notesTable,
        {userIdColumn: owner.id, textColumn: text, isSyncedWithCloudColumn: 1});
    return DatabaseNote(
        id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);
  }

  Future<List<DatabaseNote>> fetchAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);
    return notes.map((note) => DatabaseNote.fromRow(note)).toList();
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatedCount = await db.update(
        notesTable,
        {
          textColumn: text,
          isSyncedWithCloudColumn: 0,
        },
        where: 'id = ?',
        whereArgs: [note.id]);
    if (updatedCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return getNote(id: note.id);
    }
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes =
        await db.query(notesTable, limit: 1, where: 'id = ?', whereArgs: [id]);
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount =
        await db.delete(notesTable, where: 'id=?', whereArgs: [id]);
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(notesTable);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(createUserTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(email: email, id: userId);
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createUserTable);
      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final String email;
  final int id;

  const DatabaseUser({required this.email, required this.id});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : email = map[emailColumn] as String,
        id = map[idColumn] as int;

  @override
  String toString() {
    return 'Person, id: $id, email: $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() {
    return 'Note, id: $id, userId: $userId, text : $text, is_synced_with_cloud: $isSyncedWithCloud';
  }

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const notesTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createNotesTable = '''CREATE TABLE IF NOT EXISTS "note" (
	  "id"	INTEGER NOT NULL,
	  "userId"	INTEGER NOT NULL,
	  "text"	TEXT,
	  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	  PRIMARY KEY("id" AUTOINCREMENT),
	  FOREIGN KEY("userId") REFERENCES "user"("id"));''';

const createUserTable = '''CREATE TABLE  IF NOT EXISTS "user" (
	  "id"	INTEGER NOT NULL,
	  "email"	TEXT NOT NULL UNIQUE,
	  PRIMARY KEY("id" AUTOINCREMENT)); 
    ''';
