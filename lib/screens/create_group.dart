import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timebound/services/firestore_services.dart';
import 'package:timebound/screens/chat_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _groupNameController = TextEditingController();
  String? _selectedDuration;
  bool _isCreating = false;

  final List<String> _durations = ['15 min', '1 hour', '6 hours', '1 day'];

  Duration _getDurationFromString(String duration) {
    switch (duration) {
      case '15 min':
        return Duration(minutes: 15);
      case '1 hour':
        return Duration(hours: 1);
      case '6 hours':
        return Duration(hours: 6);
      case '1 day':
        return Duration(days: 1);
      default:
        return Duration(hours: 1);
    }
  }

  void _createGroup() async {
    if (_groupNameController.text.isEmpty || _selectedDuration == null) return;

    setState(() => _isCreating = true);

    final expiryTime =
        DateTime.now().add(_getDurationFromString(_selectedDuration!));
    final groupId = await FirestoreService().createGroup(
      groupName: _groupNameController.text.trim(),
      creatorName: "user",
      expiryDuration: _getDurationFromString(_selectedDuration!),
    );

    setState(() => _isCreating = false);

    // Navigate to Chat Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          groupId: groupId,
          groupName: _groupNameController.text.trim(),
          userName: 'You', // You can ask for a username input earlier
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Group")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDuration,
              items: _durations
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDuration = value),
              decoration: InputDecoration(labelText: 'Expiry Duration'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isCreating ? null : _createGroup,
              child: _isCreating
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
