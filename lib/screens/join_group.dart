import 'package:flutter/material.dart';
import 'package:timebound/services/firestore_services.dart';
import 'chat_screen.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _groupCodeController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isJoining = false;
  String? _error;

  void _joinGroup() async {
    final groupCode = _groupCodeController.text.trim();
    final name = _nameController.text.trim();

    if (groupCode.isEmpty || name.isEmpty) {
      setState(() => _error = "Please fill all fields.");
      return;
    }

    setState(() {
      _isJoining = true;
      _error = null;
    });

    final group = await FirestoreService().getGroupDetails(groupCode);

    if (group == null) {
      setState(() {
        _error = "Group not found or expired.";
        _isJoining = false;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          groupId: groupCode,
          groupName: group['name'],
          userName: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Join Group")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _groupCodeController,
              decoration: InputDecoration(labelText: 'Group Code'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Your Name'),
            ),
            SizedBox(height: 24),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              onPressed: _isJoining ? null : _joinGroup,
              child: _isJoining
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Join Group'),
            ),
          ],
        ),
      ),
    );
  }
}
