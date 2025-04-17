import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserName = prefs.getString('username');
    });
  }

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

      if (_currentUserName == null || _currentUserName!.isEmpty) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            groupId: groupId,
            groupName: groupName,
            userName: _currentUserName!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group not found')),
      );
    }
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
