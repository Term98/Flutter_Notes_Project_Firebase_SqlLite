import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote ? _note;
  late final NoteService _noteService;
  late final TextEditingController _textController;

  @override
  void initState(){
    _noteService  = NoteService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async{
    final note = _note;
    if (note == null){
      return;
    }
    final text = _textController.text;
    await _noteService.updateNote(
      note: note, 
      text: text);
  }

  void _setupTextControllerListner(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async{
    final existingNote = _note;
    if (existingNote != null ){
      return existingNote;
    }
    final currentUser  = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteService.getUser(email: email);
    return await _noteService.createNotes(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty(){
    final note =  _note;
    if (_textController.text.isEmpty && note != null){
      _noteService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty()  async{
    final note = _note;
    final text = _textController.text;
    if(note != null && text.isNotEmpty ){
      await _noteService.updateNote(
        note: note, 
        text: text);
    }
  }

  @override
  void dispose(){
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Notes'),
      ),
      body: FutureBuilder(
        future: createNewNote() ,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote?;
              _setupTextControllerListner();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline ,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText:'Start typing in here ...'
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      )
    );
  }
}