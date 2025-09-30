import 'package:flutter/material.dart';
import '../state/app_state.dart';

class AddNoteDialog extends StatefulWidget {
  final String eventId;
  const AddNoteDialog({Key? key, required this.eventId}) : super(key: key);

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final TextEditingController _noteC = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final doctor = AppState.instance.currentUser.value?['name'] ?? 'Clinician';
    return AlertDialog(
      title: Text('Add note (${doctor})'),
      content: TextField(
          controller: _noteC,
          decoration: const InputDecoration(labelText: 'Note')),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    AppState.instance.addNoteToEvent(
                        widget.eventId, doctor, _noteC.text.trim());
                    await Future.delayed(const Duration(milliseconds: 200));
                    setState(() => _saving = false);
                    Navigator.pop(context);
                    if (ScaffoldMessenger.maybeOf(context) != null)
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Note saved')));
                  },
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save')),
      ],
    );
  }
}
