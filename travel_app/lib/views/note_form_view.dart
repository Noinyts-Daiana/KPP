import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 ДОДАНО: Потрібен для UID
import '../bloc/manage_note_bloc.dart';
import '../bloc/note_list_bloc.dart';
// 'note_list_event.dart' тут не потрібен, оскільки ми імпортуємо NoteListBloc
// import '../bloc/note_list_event.dart'; 
import '../models/travel_models.dart';
import '../repositories/notes_repository.dart';
// 'trips_repository.dart' тут не потрібен, оскільки UID береться з Auth
// import '../repositories/trips_repository.dart'; 

const Color primaryColor = Color(0xFF0D47A1); 
const Color accentColor = Color(0xFFF5F5F5); 

class NoteFormView extends StatelessWidget {
  final Note? initialNote;
  // ❌ ВИДАЛЕНО: 'currentUserId' (беремо з FirebaseAuth)

  NoteFormView({super.key, this.initialNote});

  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  void _initControllers() {
    if (initialNote != null) {
      _textController.text = initialNote!.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initControllers();

    return BlocProvider(
      // 👇 ВИПРАВЛЕНО: Тепер передаємо 2 аргументи
      create: (providerContext) {
        final repository = providerContext.read<NotesRepository>();
        final userId = FirebaseAuth.instance.currentUser!.uid; // Отримуємо UID
        return ManageNoteBloc(repository, userId);
      },
      child: BlocListener<ManageNoteBloc, ManageNoteState>(
        listener: (listenerContext, state) {
          if (state is ManageNoteSuccess) {
            ScaffoldMessenger.of(listenerContext).showSnackBar(
              SnackBar(content: Text(initialNote == null ? 'Нотатку створено!' : 'Нотатку оновлено!')),
            );
            listenerContext.read<NoteListBloc>().add(const FetchNotesEvent());
            Navigator.of(listenerContext).pop();
          } else if (state is ManageNoteFailure) {
            ScaffoldMessenger.of(listenerContext).showSnackBar(
              SnackBar(content: Text('Помилка: ${state.error}')),
            );
          }
        },
        child: Builder( 
          builder: (builderContext) {
            return Container(
              height: MediaQuery.of(builderContext).size.height * 0.8, 
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(builderContext).viewInsets.bottom + 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      initialNote == null ? 'НОВА НОТАТКА' : 'РЕДАГУВАННЯ НОТАТКИ',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TextFormField(
                        controller: _textController,
                        maxLines: null, 
                        expands: true, 
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          labelText: 'Текст нотатки',
                          filled: true,
                          fillColor: accentColor.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Обов\'язкове поле';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(builderContext),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bloc = context.read<ManageNoteBloc>();
    final isProcessing = context.select((ManageNoteBloc b) => b.state is ManageNoteProcessing);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isProcessing ? null : () => Navigator.pop(context),
          child: const Text('СКАСУВАТИ', style: TextStyle(color: primaryColor)),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: isProcessing ? null : () {
            if (_formKey.currentState!.validate()) {
              final noteToSave = Note(
                id: initialNote?.id ?? '',
                text: _textController.text,
                creationDate: initialNote?.creationDate ?? DateTime.now(),
              );
              bloc.add(SaveNoteEvent(noteToSave, isNew: initialNote == null));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: isProcessing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(initialNote == null ? 'ДОДАТИ' : 'ЗБЕРЕГТИ'),
        ),
      ],
    );
  }
}