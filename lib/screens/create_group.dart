// 📁 create_group_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_services.dart';
import 'chat_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  String? _selectedDuration;
  bool _isCreating = false;

  final List<String> _durations = ['2 min', '1 hour', '6 hours', '1 day'];

  Duration _getDurationFromString(String duration) {
    switch (duration) {
      case '2 min':
        return const Duration(minutes: 2);
      case '1 hour':
        return const Duration(hours: 1);
      case '6 hours':
        return const Duration(hours: 6);
      case '1 day':
        return const Duration(days: 1);
      default:
        return const Duration(hours: 1);
    }
  }

  Future<String?> _promptForName() async {
    String userName = "";
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter your name"),
          content: TextField(
            onChanged: (value) => userName = value,
            decoration: const InputDecoration(hintText: "e.g., John"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, userName),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _createGroup() async {
    if (_groupNameController.text.isEmpty || _selectedDuration == null) return;

    final userName = await _promptForName();
    if (userName == null || userName.isEmpty) return;

    setState(() => _isCreating = true);

    final expiryTime =
        DateTime.now().add(_getDurationFromString(_selectedDuration!));
    final groupId = await FirestoreService().createGroup(
      groupName: _groupNameController.text.trim(),
      expiryTime: expiryTime,
    );

    setState(() => _isCreating = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          groupId: groupId,
          groupName: _groupNameController.text.trim(),
          userName: userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDuration,
              items: _durations
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDuration = value),
              decoration: const InputDecoration(labelText: 'Expiry Duration'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isCreating ? null : _createGroup,
              child: _isCreating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
