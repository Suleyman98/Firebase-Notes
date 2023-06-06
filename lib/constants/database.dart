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
