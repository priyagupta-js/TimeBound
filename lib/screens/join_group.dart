// 📁 join_group_screen.dart
import 'package:flutter/material.dart';
import '../services/firestore_services.dart';
import 'chat_screen.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _groupIdController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void _joinGroup() async {
    final groupId = _groupIdController.text.trim();

    if (groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Group ID')),
      );
      return;
    }

    final doc = await _firestoreService.getGroup(groupId);
    if (doc != null) {
      final groupName = doc['name'];

      final userName = await _promptForName();
      if (userName == null || userName.isEmpty) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            groupId: groupId,
            groupName: groupName,
            userName: userName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group not found')),
      );
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
            decoration: const InputDecoration(hintText: "e.g., Sarah"),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _groupIdController,
            decoration: const InputDecoration(labelText: 'Enter Group ID'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _joinGroup,
            icon: const Icon(Icons.login),
            label: const Text('Join Group'),
          ),
        ],
      ),
    );
  }
}
