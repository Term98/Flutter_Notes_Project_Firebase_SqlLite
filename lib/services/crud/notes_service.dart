import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart' ;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:testapp/services/crud/crud_exceptions.dart';



class NoteService {
  Database ? _db ;

  List<DatabaseNote> _notes = [];

  final _notesStreamController = 
    StreamController<List<DatabaseNote>>.broadcast();

  Future<DatabaseUser> getOrCreateUser({required String email}) async{
    try{
      final user = await getUser(email: email);
      return user;
    }on CouldNotFindUser{
      final createdUser = await createUser(email: email);
      return createdUser;
    }catch(e){
      rethrow;
    }
  }


  Future<void> _cacheNotes() async{
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  } 

  Future<DatabaseNote> updateNote ({
    required DatabaseNote note,
    required String text,
  })async {
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatesCount = await db.update(noteTable,{
        textColumn:text,
        isSyncedWithCloudColumn:0,
        });

    if(updatesCount ==0){
      throw CouldNotUpdateNote();
    }else{
      final updateNote =await getNote(id: note.id);
      _notes.removeWhere((notes) => notes.id == updateNote.id);
      _notes.add(updateNote);
      _notesStreamController.add(_notes);
      return updateNote;
    }

  }

  Future<Iterable<DatabaseNote>> getAllNotes() async{
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
    );
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id})async{
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id:?',
      whereArgs: [id]
    );
    if(notes.isEmpty){
      throw CouldNotFindNotes();
    }else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((notes) => notes.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note; 
    }
  }

  Future<int> deleteAllNote()async{
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await  db.delete(noteTable);
    _notes =[];
    _notesStreamController.add(_notes);
    return await db.delete(noteTable);
  }

  Future<void> deleteNote ({required int id}) async{
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: 'id =?',
      whereArgs: [id]
    );
    if(deleteCount ==0 ){
      throw CouldNotDeleteNote();
    }else {
      _notes.removeWhere((notes) => notes.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNotes ({ required DatabaseUser owner }) async {
    final db = _getDatabaseOrThrow();

    //make sure owner exists in the distance with the correct id 
    final dbUser = await getUser(email: owner.email);
    if(dbUser !=owner ){
      throw CouldNotFindUser();
    }
    const text ='';
    final noteId = await db.insert(noteTable, {
      userIdColumn:owner.id,
      textColumn:text,
      isSyncedWithCloudColumn:1
    });
    final note = DatabaseNote(
      id: noteId, 
      userId: owner.id, 
      text: text, 
      isSynchedWithCloud: 1
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseUser> getUser ({required String email}) async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()]
     );
     if (results.isEmpty){
      throw CouldNotFindUser();
     }else{
      return DatabaseUser.fromRow(results.first);
      }
  }

  Future<DatabaseUser> createUser({required String email})async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()]
     );
     if (result.isNotEmpty){
      throw UserAlreadyExists();
     };

    final userId = await db.insert(userTable,{
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email,);
  }

  Future<void> deleteUser ({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()]
    );
    if(deletedCount !=  1){
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow(){
    final db = _db;
    if (db == null){
      throw DataBaseIsNotOpen();
    }else{
      return db ;
    }
  }

  Future <void>close() async{
    final db = _db;
    if(db != null) {
      throw DataBaseIsNotOpen();
    }else {
      await db?.close();
      _db = null;
    }
  }

  Future <void> open() async {
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path,dbName);
      final db = await openDatabase(dbPath);
      _db = db;      

      await db.execute(createUserTable);
      
      await db.execute(createNoteTable);

      await _cacheNotes();

    }on MissingPlatformDirectoryException{
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class  DatabaseUser  {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id, 
    required this.email});

  DatabaseUser.fromRow(Map<String,Object?> map) 
    : id =map[idColumn] as int ,
      email = map[emailColumn] as String;

  @override 
  String toString() => 'Person , ID : $id  , Email:$email';

  @override
  bool operator == (covariant DatabaseUser other)  =>   id == other.id ;

  @override 
  int get hashcode => id.hashCode;

}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final int isSynchedWithCloud;

  DatabaseNote({required this.id,required this.userId,required this.text,required this.isSynchedWithCloud});
  DatabaseNote.fromRow(Map<String,Object?> map) 
    : id =map[idColumn] as int ,
      text = map[textColumn] as String,
      userId = map[userIdColumn] as int,
      isSynchedWithCloud =
          (map[isSyncedWithCloudColumn] as int)  ;
  @override 
  String toString() => 
      'Note ,Id=$id , userId=$userId , isSynchedWithCloud=$isSynchedWithCloud';
  @override
  bool operator == (covariant DatabaseNote other)  =>   id == other.id ;

  @override 
  int get hashcode => id.hashCode;    
}

const dbName = 'notesDb';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text'; 
const isSyncedWithCloudColumn = 'is_Synced_with_cloud';
const createUserTable = ''' 
      CREATE TABLE IF NOT EXISTS "Users" (
      "id"	INTEGER NOT NULL,
      "email"	TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';
const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS "Notes" (
      "id"	INTEGER NOT NULL,
      " user_id"	INTEGER NOT NULL,
      "text"	TEXT NOT NULL,
      "is_synced_with_cloud"	INTEGER NOT NULL,
      FOREIGN KEY(" user_id") REFERENCES "user"("ID"),
      PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';