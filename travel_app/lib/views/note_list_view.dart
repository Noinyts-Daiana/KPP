// lib/views/note_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/note_list_bloc.dart';
import '../bloc/note_list_state.dart';
import '../models/travel_models.dart';
import '../repositories/notes_repository.dart';
import 'note_form_view.dart';

const Color primaryColor = Color(0xFF0D47A1);

class NoteListView extends StatelessWidget {
  final String userId;

  const NoteListView({super.key, required this.userId});

  void _showNoteForm(BuildContext context, {Note? note}) {
    final notesRepository = context.read<NotesRepository>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return RepositoryProvider.value(
          value: notesRepository,
          child: NoteFormView(initialNote: note),
        );
      },
    );
  }

  Widget _buildNoteListItem(BuildContext context, Note note) {
    final dateFormat = DateFormat('d MMM, HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 0),
        title: Text(
          note.text.length > 50 ? '${note.text.substring(0, 50)}...' : note.text,
          style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        subtitle: Text(dateFormat.format(note.creationDate),
            style: const TextStyle(color: Colors.grey)),
        onTap: () => _showNoteForm(context, note: note),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit, color: primaryColor),
                onPressed: () => _showNoteForm(context, note: note)),
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Імітація видалення нотатки')));
                }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteListBloc>(
      create: (context) => NoteListBloc(
        context.read<NotesRepository>(),
        userId,
      )..add(const FetchNotesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NOTES', style: TextStyle(color: Colors.white)),
          backgroundColor: primaryColor,
          actions: [
            IconButton(
                icon: const Icon(Icons.add_box_outlined),
                onPressed: () => _showNoteForm(context)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/HomeScreenBack.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
            ),
          ),
          child: BlocBuilder<NoteListBloc, NoteState>(
            builder: (context, state) {
              if (state is NoteLoadingState && state.data.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: primaryColor));
              }

              if (state is NoteErrorState && state.data.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Помилка завантаження нотаток!',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Text(state.error),
                      ElevatedButton(
                        onPressed: () => context.read<NoteListBloc>().add(const FetchNotesEvent()),
                        child: const Text('СПРОБУВАТИ ЩЕ'),
                      ),
                    ],
                  ),
                );
              }

              if (state.data.isNotEmpty) {
                return ListView.builder(
                  itemCount: state.data.length,
                  itemBuilder: (context, index) => _buildNoteListItem(context, state.data[index]),
                );
              }

              return const Center(
                  child: Text('Нотатки відсутні.',
                      style: TextStyle(color: Colors.white, fontSize: 16)));
            },
          ),
        ),
      ),
    );
  }
}
